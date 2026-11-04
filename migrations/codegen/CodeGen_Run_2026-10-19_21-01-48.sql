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
         '02892041-b070-475d-9486-5570486ddbec',
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
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '02892041-b070-475d-9486-5570486ddbec', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Notes for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('02892041-b070-475d-9486-5570486ddbec' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('02892041-b070-475d-9486-5570486ddbec' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Notes for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('02892041-b070-475d-9486-5570486ddbec' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('02892041-b070-475d-9486-5570486ddbec' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Notes for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('02892041-b070-475d-9486-5570486ddbec' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('02892041-b070-475d-9486-5570486ddbec' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
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
         '3418e742-27e0-4df9-9030-84ee319851f2',
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
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '3418e742-27e0-4df9-9030-84ee319851f2', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Links for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('3418e742-27e0-4df9-9030-84ee319851f2' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('3418e742-27e0-4df9-9030-84ee319851f2' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Links for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('3418e742-27e0-4df9-9030-84ee319851f2' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('3418e742-27e0-4df9-9030-84ee319851f2' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Links for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('3418e742-27e0-4df9-9030-84ee319851f2' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('3418e742-27e0-4df9-9030-84ee319851f2' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
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
         '79634853-b251-4dd5-b1d3-35001e4a0824',
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
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '79634853-b251-4dd5-b1d3-35001e4a0824', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Video Providers for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('79634853-b251-4dd5-b1d3-35001e4a0824' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('79634853-b251-4dd5-b1d3-35001e4a0824' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Video Providers for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('79634853-b251-4dd5-b1d3-35001e4a0824' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('79634853-b251-4dd5-b1d3-35001e4a0824' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Video Providers for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('79634853-b251-4dd5-b1d3-35001e4a0824' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('79634853-b251-4dd5-b1d3-35001e4a0824' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
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
         '6aaf3feb-ac7f-4b1a-ac08-a9aa43ae5aa4',
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
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '6aaf3feb-ac7f-4b1a-ac08-a9aa43ae5aa4', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Types for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('6aaf3feb-ac7f-4b1a-ac08-a9aa43ae5aa4' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('6aaf3feb-ac7f-4b1a-ac08-a9aa43ae5aa4' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Types for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('6aaf3feb-ac7f-4b1a-ac08-a9aa43ae5aa4' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('6aaf3feb-ac7f-4b1a-ac08-a9aa43ae5aa4' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Types for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('6aaf3feb-ac7f-4b1a-ac08-a9aa43ae5aa4' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('6aaf3feb-ac7f-4b1a-ac08-a9aa43ae5aa4' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
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
         'c625aae9-906f-4056-90ac-c655886d3f69',
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
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'c625aae9-906f-4056-90ac-c655886d3f69', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Agenda Item Types for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('c625aae9-906f-4056-90ac-c655886d3f69' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('c625aae9-906f-4056-90ac-c655886d3f69' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Agenda Item Types for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('c625aae9-906f-4056-90ac-c655886d3f69' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('c625aae9-906f-4056-90ac-c655886d3f69' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Agenda Item Types for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('c625aae9-906f-4056-90ac-c655886d3f69' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('c625aae9-906f-4056-90ac-c655886d3f69' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
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
         '02b53c81-832e-428a-8ce8-493189ee4b28',
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
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '02b53c81-832e-428a-8ce8-493189ee4b28', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Series for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('02b53c81-832e-428a-8ce8-493189ee4b28' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('02b53c81-832e-428a-8ce8-493189ee4b28' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Series for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('02b53c81-832e-428a-8ce8-493189ee4b28' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('02b53c81-832e-428a-8ce8-493189ee4b28' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Series for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('02b53c81-832e-428a-8ce8-493189ee4b28' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('02b53c81-832e-428a-8ce8-493189ee4b28' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
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
         'd8b37817-4eb1-414c-9273-5977ab80db63',
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
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'd8b37817-4eb1-414c-9273-5977ab80db63', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meetings for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('d8b37817-4eb1-414c-9273-5977ab80db63' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('d8b37817-4eb1-414c-9273-5977ab80db63' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meetings for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('d8b37817-4eb1-414c-9273-5977ab80db63' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('d8b37817-4eb1-414c-9273-5977ab80db63' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meetings for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('d8b37817-4eb1-414c-9273-5977ab80db63' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('d8b37817-4eb1-414c-9273-5977ab80db63' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
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
         'e4283e35-10e3-41ac-aa30-d28890a55d62',
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
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'e4283e35-10e3-41ac-aa30-d28890a55d62', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Series Attendees for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('e4283e35-10e3-41ac-aa30-d28890a55d62' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('e4283e35-10e3-41ac-aa30-d28890a55d62' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Series Attendees for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('e4283e35-10e3-41ac-aa30-d28890a55d62' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('e4283e35-10e3-41ac-aa30-d28890a55d62' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Series Attendees for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('e4283e35-10e3-41ac-aa30-d28890a55d62' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('e4283e35-10e3-41ac-aa30-d28890a55d62' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
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
         '87ef481f-8e24-4863-b5de-1e31b17e89f3',
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
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '87ef481f-8e24-4863-b5de-1e31b17e89f3', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Attendees for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('87ef481f-8e24-4863-b5de-1e31b17e89f3' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('87ef481f-8e24-4863-b5de-1e31b17e89f3' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Attendees for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('87ef481f-8e24-4863-b5de-1e31b17e89f3' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('87ef481f-8e24-4863-b5de-1e31b17e89f3' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Attendees for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('87ef481f-8e24-4863-b5de-1e31b17e89f3' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('87ef481f-8e24-4863-b5de-1e31b17e89f3' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
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
         '9c171f1d-86f9-4630-8548-1dc6163272ca',
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
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '9c171f1d-86f9-4630-8548-1dc6163272ca', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Agenda Items for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('9c171f1d-86f9-4630-8548-1dc6163272ca' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('9c171f1d-86f9-4630-8548-1dc6163272ca' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Agenda Items for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('9c171f1d-86f9-4630-8548-1dc6163272ca' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('9c171f1d-86f9-4630-8548-1dc6163272ca' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Meeting Agenda Items for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('9c171f1d-86f9-4630-8548-1dc6163272ca' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('9c171f1d-86f9-4630-8548-1dc6163272ca' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL text to update existing entities from schema */
EXEC [${mjSchema}].[spUpdateExistingEntitiesFromSchema] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

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

/* SQL text to insert 144 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '85f2793a-4930-4265-bd01-fb35e75fcdb5' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '85f2793a-4930-4265-bd01-fb35e75fcdb5',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1f36c7fb-f776-4d69-9e39-021e3aa51d91' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'MeetingID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1f36c7fb-f776-4d69-9e39-021e3aa51d91',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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
            'D8B37817-4EB1-414C-9273-5977AB80DB63',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3b19ad0b-10cf-4248-8036-c185cef7d16a' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'ParentID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3b19ad0b-10cf-4248-8036-c185cef7d16a',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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
            '9C171F1D-86F9-4630-8548-1DC6163272CA',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e15c61bd-503c-433d-ac50-c13ed65c9358' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'Sequence')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e15c61bd-503c-433d-ac50-c13ed65c9358',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'dbe46fef-60cf-48c3-9fb5-d1bc4d396021' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'Name')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'dbe46fef-60cf-48c3-9fb5-d1bc4d396021',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3c9636c5-2f50-46b3-854c-a92273b4adbc' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'Description')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3c9636c5-2f50-46b3-854c-a92273b4adbc',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '65c28e8b-d16c-4f3f-a48e-02a18c5f18f7' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'TypeID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '65c28e8b-d16c-4f3f-a48e-02a18c5f18f7',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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
            'C625AAE9-906F-4056-90AC-C655886D3F69',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a62402cb-1548-41c0-bcee-2602a6a23f44' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'PresenterPersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a62402cb-1548-41c0-bcee-2602a6a23f44',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9869fd8c-4e3d-447e-aa13-3a9901e8e620' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'DurationMinutes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9869fd8c-4e3d-447e-aa13-3a9901e8e620',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd54a48c4-278a-471d-b4c8-9a5b4c2ccd14' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'Status')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd54a48c4-278a-471d-b4c8-9a5b4c2ccd14',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd33b105f-f47d-4741-9a9f-e6b686a15ae1' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'StartedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd33b105f-f47d-4741-9a9f-e6b686a15ae1',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1da31e5d-06bb-4b93-88ed-c6f598c5f150' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'EndedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1da31e5d-06bb-4b93-88ed-c6f598c5f150',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8e21e156-aaa4-471c-a160-07fb7c5a75aa' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'Outcome')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8e21e156-aaa4-471c-a160-07fb7c5a75aa',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '467e00ed-f642-4f09-b316-fa6159f7392c' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'DeferredToMeetingID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '467e00ed-f642-4f09-b316-fa6159f7392c',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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
            'D8B37817-4EB1-414C-9273-5977AB80DB63',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c9d5e112-69d9-4681-bf82-e55ea4a7f30a' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c9d5e112-69d9-4681-bf82-e55ea4a7f30a',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '49334216-6610-4517-b03d-e3e82ce3c9c7' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '49334216-6610-4517-b03d-e3e82ce3c9c7',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '10ea6d37-2ee3-4233-b36b-0f57da1cb6a4' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '10ea6d37-2ee3-4233-b36b-0f57da1cb6a4',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0e80d78d-2a5f-4c54-88ae-e18959df40d6' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = 'MeetingID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0e80d78d-2a5f-4c54-88ae-e18959df40d6',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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
            'D8B37817-4EB1-414C-9273-5977AB80DB63',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '73883756-7863-4284-8cbf-d406d435d7d1' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = 'PersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '73883756-7863-4284-8cbf-d406d435d7d1',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '251f26f7-3d9f-4b1a-aa82-66c121d54f1e' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = 'UserID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '251f26f7-3d9f-4b1a-aa82-66c121d54f1e',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c29fa445-e38e-490a-b9bb-7f2f5325499a' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = 'Email')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c29fa445-e38e-490a-b9bb-7f2f5325499a',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ec2e8ebc-62d2-4208-8235-bd489de3a2e2' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = 'DisplayName')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ec2e8ebc-62d2-4208-8235-bd489de3a2e2',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c0ace054-8f8b-4e8a-9130-279ba291a5d6' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = 'Role')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c0ace054-8f8b-4e8a-9130-279ba291a5d6',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'beead1d3-223d-44e7-b3c6-f4ec0b41ef1b' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = 'ResponseStatus')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'beead1d3-223d-44e7-b3c6-f4ec0b41ef1b',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9904b87b-bd2f-49ae-858f-07a394947d1b' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = 'RespondedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9904b87b-bd2f-49ae-858f-07a394947d1b',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '54779b4a-7ee4-4d06-ac1f-1af4eda94ee4' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = 'AttendanceStatus')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '54779b4a-7ee4-4d06-ac1f-1af4eda94ee4',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '22f7dd31-2b44-465b-94ef-0545af885761' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = 'JoinedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '22f7dd31-2b44-465b-94ef-0545af885761',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '911315d1-d38b-4068-82b7-f519c993b437' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = 'LeftAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '911315d1-d38b-4068-82b7-f519c993b437',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'deaa2ee8-3331-4276-8a42-e00d952d432d' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = 'Notes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'deaa2ee8-3331-4276-8a42-e00d952d432d',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b90cf994-7123-416f-a74a-8315bb66670e' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b90cf994-7123-416f-a74a-8315bb66670e',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'cfaf43ab-cea6-4505-ba48-3c679a01599c' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'cfaf43ab-cea6-4505-ba48-3c679a01599c',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8d9fdbbc-67bd-427d-83df-9cbf6b51b62a' OR (EntityID = '79634853-B251-4DD5-B1D3-35001E4A0824' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8d9fdbbc-67bd-427d-83df-9cbf6b51b62a',
            '79634853-B251-4DD5-B1D3-35001E4A0824', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '79634853-B251-4DD5-B1D3-35001E4A0824'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8becb11a-bf8b-436c-8774-52dc88bc86db' OR (EntityID = '79634853-B251-4DD5-B1D3-35001E4A0824' AND Name = 'Name')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8becb11a-bf8b-436c-8774-52dc88bc86db',
            '79634853-B251-4DD5-B1D3-35001E4A0824', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '79634853-B251-4DD5-B1D3-35001E4A0824'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '38020ad6-cc04-4cd0-9591-30b60b56bc9e' OR (EntityID = '79634853-B251-4DD5-B1D3-35001E4A0824' AND Name = 'Code')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '38020ad6-cc04-4cd0-9591-30b60b56bc9e',
            '79634853-B251-4DD5-B1D3-35001E4A0824', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '79634853-B251-4DD5-B1D3-35001E4A0824'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7374798d-a1e8-407b-a690-5fecc9dd7859' OR (EntityID = '79634853-B251-4DD5-B1D3-35001E4A0824' AND Name = 'DriverClass')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7374798d-a1e8-407b-a690-5fecc9dd7859',
            '79634853-B251-4DD5-B1D3-35001E4A0824', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '79634853-B251-4DD5-B1D3-35001E4A0824'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '25a17241-c9a9-4d92-bacd-55c8e4381f4d' OR (EntityID = '79634853-B251-4DD5-B1D3-35001E4A0824' AND Name = 'Description')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '25a17241-c9a9-4d92-bacd-55c8e4381f4d',
            '79634853-B251-4DD5-B1D3-35001E4A0824', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '79634853-B251-4DD5-B1D3-35001E4A0824'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '39fd3d31-d1e5-418b-a2aa-e43fd88d7a2e' OR (EntityID = '79634853-B251-4DD5-B1D3-35001E4A0824' AND Name = 'IconClass')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '39fd3d31-d1e5-418b-a2aa-e43fd88d7a2e',
            '79634853-B251-4DD5-B1D3-35001E4A0824', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '79634853-B251-4DD5-B1D3-35001E4A0824'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '38c035de-701c-4b03-920c-dbcfc6b753d3' OR (EntityID = '79634853-B251-4DD5-B1D3-35001E4A0824' AND Name = 'CredentialID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '38c035de-701c-4b03-920c-dbcfc6b753d3',
            '79634853-B251-4DD5-B1D3-35001E4A0824', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '79634853-B251-4DD5-B1D3-35001E4A0824'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '858e1979-a67d-47ac-a180-8b138e9b0263' OR (EntityID = '79634853-B251-4DD5-B1D3-35001E4A0824' AND Name = 'Configuration')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '858e1979-a67d-47ac-a180-8b138e9b0263',
            '79634853-B251-4DD5-B1D3-35001E4A0824', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '79634853-B251-4DD5-B1D3-35001E4A0824'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fd65d80f-3ed8-41b2-a038-75d939eddbea' OR (EntityID = '79634853-B251-4DD5-B1D3-35001E4A0824' AND Name = 'SupportsTranscripts')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'fd65d80f-3ed8-41b2-a038-75d939eddbea',
            '79634853-B251-4DD5-B1D3-35001E4A0824', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '79634853-B251-4DD5-B1D3-35001E4A0824'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '67aa8309-1039-4554-b846-a9d3bda3fd9d' OR (EntityID = '79634853-B251-4DD5-B1D3-35001E4A0824' AND Name = 'IsDefault')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '67aa8309-1039-4554-b846-a9d3bda3fd9d',
            '79634853-B251-4DD5-B1D3-35001E4A0824', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '79634853-B251-4DD5-B1D3-35001E4A0824'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f14d6d39-a920-47f9-8efd-938b927f0226' OR (EntityID = '79634853-B251-4DD5-B1D3-35001E4A0824' AND Name = 'IsActive')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f14d6d39-a920-47f9-8efd-938b927f0226',
            '79634853-B251-4DD5-B1D3-35001E4A0824', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '79634853-B251-4DD5-B1D3-35001E4A0824'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '73992a53-7b55-4b63-870f-01003c93ee00' OR (EntityID = '79634853-B251-4DD5-B1D3-35001E4A0824' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '73992a53-7b55-4b63-870f-01003c93ee00',
            '79634853-B251-4DD5-B1D3-35001E4A0824', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '79634853-B251-4DD5-B1D3-35001E4A0824'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e771d1ac-5e39-4d19-b801-d1b30e3de0e4' OR (EntityID = '79634853-B251-4DD5-B1D3-35001E4A0824' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e771d1ac-5e39-4d19-b801-d1b30e3de0e4',
            '79634853-B251-4DD5-B1D3-35001E4A0824', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '79634853-B251-4DD5-B1D3-35001E4A0824'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '867df080-f43e-4003-91c1-1dd75f11d8bf' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '867df080-f43e-4003-91c1-1dd75f11d8bf',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '72f2680c-de45-4d9d-a086-21d7377f93e2' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'Name')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '72f2680c-de45-4d9d-a086-21d7377f93e2',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6d31218a-f58c-4c5d-a5e8-7d7c5101a4ec' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'Description')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6d31218a-f58c-4c5d-a5e8-7d7c5101a4ec',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5899cc1b-c4ac-44b6-97f4-7f7816fb6276' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'TypeID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5899cc1b-c4ac-44b6-97f4-7f7816fb6276',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c3ce03e6-250d-4cb3-a6c1-9ba1f1fa3a68' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'OrganizerPersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c3ce03e6-250d-4cb3-a6c1-9ba1f1fa3a68',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4ac13fdc-d885-48de-b34a-264ba046045a' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'RecurrenceRule')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4ac13fdc-d885-48de-b34a-264ba046045a',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '76c10f3f-5f56-41c8-b304-17bb0520d8f0' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'TimeZone')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '76c10f3f-5f56-41c8-b304-17bb0520d8f0',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a14b6777-c8c4-405a-99f8-f91cfc998c64' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'FirstStartsAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a14b6777-c8c4-405a-99f8-f91cfc998c64',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '02ffe107-954e-4ca4-b4e9-e2a03649bbcc' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'DurationMinutes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '02ffe107-954e-4ca4-b4e9-e2a03649bbcc',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1eb94d6a-4b9f-4d56-b3bc-de310b093445' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'LocationType')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1eb94d6a-4b9f-4d56-b3bc-de310b093445',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '71673110-eff4-456f-997f-e4187a7c7764' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'Location')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '71673110-eff4-456f-997f-e4187a7c7764',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'cfb8d479-8d27-4c4d-a97d-02b3954e21a7' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'VideoProviderID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'cfb8d479-8d27-4c4d-a97d-02b3954e21a7',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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
            '79634853-B251-4DD5-B1D3-35001E4A0824',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0241843f-271f-4ec4-88bf-0dd8d7aaca46' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'Visibility')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0241843f-271f-4ec4-88bf-0dd8d7aaca46',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a0f5f602-1388-4c16-9b16-2b597449c880' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'Status')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a0f5f602-1388-4c16-9b16-2b597449c880',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c7086030-6755-48a2-a7f8-826811f510f2' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'MaterializedThrough')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c7086030-6755-48a2-a7f8-826811f510f2',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '099563e0-aeb7-4eef-871e-9f2eb3b0cb38' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'CreatedByPersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '099563e0-aeb7-4eef-871e-9f2eb3b0cb38',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd7bc4213-305e-457a-a4dc-437c8d10e72f' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd7bc4213-305e-457a-a4dc-437c8d10e72f',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a23eff1c-364d-4e45-b4c8-5f1959a10eb2' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a23eff1c-364d-4e45-b4c8-5f1959a10eb2',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '097e582b-9cd6-40bb-a382-152ff2eab44d' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '097e582b-9cd6-40bb-a382-152ff2eab44d',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8db670a7-1316-4eea-99b4-91d32aa896ff' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = 'MeetingID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8db670a7-1316-4eea-99b4-91d32aa896ff',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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
            'D8B37817-4EB1-414C-9273-5977AB80DB63',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0dd12734-ca7b-42e5-b658-b2bf2b210658' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = 'AgendaItemID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0dd12734-ca7b-42e5-b658-b2bf2b210658',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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
            '9C171F1D-86F9-4630-8548-1DC6163272CA',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '621dace8-6b57-4a39-9a9f-25be8ea57a5c' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = 'Kind')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '621dace8-6b57-4a39-9a9f-25be8ea57a5c',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '584d7f39-3018-4e33-b20c-3f1b41de3216' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = 'Title')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '584d7f39-3018-4e33-b20c-3f1b41de3216',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'cbdbef95-4aec-471e-84a8-3c403e82c15d' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = 'Body')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'cbdbef95-4aec-471e-84a8-3c403e82c15d',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'cb39f3e7-be6e-453c-a089-409076e50d53' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = 'Source')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'cb39f3e7-be6e-453c-a089-409076e50d53',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1290adba-e74c-4c38-9bd1-3fc468fc343e' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = 'Status')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1290adba-e74c-4c38-9bd1-3fc468fc343e',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0278feae-9f92-43c6-afbd-e19ef9712866' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = 'AuthorPersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0278feae-9f92-43c6-afbd-e19ef9712866',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'de0e4d3f-a983-4d85-9c30-7d4a033b72af' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = 'AIPromptRunID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'de0e4d3f-a983-4d85-9c30-7d4a033b72af',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '88ab7aaa-a69b-4ca8-8571-a416cede1679' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = 'ProposedTasks')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '88ab7aaa-a69b-4ca8-8571-a416cede1679',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '09b812dc-a948-450e-af69-232fc3dad0b9' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '09b812dc-a948-450e-af69-232fc3dad0b9',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '66191676-5c79-4949-a4fe-1bc88a9d7893' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '66191676-5c79-4949-a4fe-1bc88a9d7893',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c83afdd2-03d6-4b09-9ae7-6a3e806b254e' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c83afdd2-03d6-4b09-9ae7-6a3e806b254e',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8517d073-ec64-4264-9ab5-6f5413ac101a' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'Name')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8517d073-ec64-4264-9ab5-6f5413ac101a',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7bb6181e-197d-4389-b38e-ad88c9563206' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'Description')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7bb6181e-197d-4389-b38e-ad88c9563206',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e74a1a70-6545-48b6-939d-dcff634c18e3' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'TypeID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e74a1a70-6545-48b6-939d-dcff634c18e3',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '15e79801-5cb1-463a-b7f3-dc95c99d58e8' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'SeriesID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '15e79801-5cb1-463a-b7f3-dc95c99d58e8',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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
            '02B53C81-832E-428A-8CE8-493189EE4B28',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a5dfb76c-7839-474a-b9da-a7e5ec9080e6' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'OccurrenceStartsAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a5dfb76c-7839-474a-b9da-a7e5ec9080e6',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1aff37cd-ace0-4e81-858f-e099a19914f6' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'Status')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1aff37cd-ace0-4e81-858f-e099a19914f6',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '93543486-cccd-4b20-b1ea-705a3451ceab' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'StartsAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '93543486-cccd-4b20-b1ea-705a3451ceab',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'eb21d424-cd26-4468-9229-5fd0d175e5e4' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'EndsAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'eb21d424-cd26-4468-9229-5fd0d175e5e4',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a7858cf2-6858-4dca-b9c1-d8e23b6d89db' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'TimeZone')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a7858cf2-6858-4dca-b9c1-d8e23b6d89db',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '31d45b39-d108-48f8-b956-c938d098d85f' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'LocationType')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '31d45b39-d108-48f8-b956-c938d098d85f',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a549bc06-0747-4dfc-ba4e-25b13bb8efd7' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'Location')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a549bc06-0747-4dfc-ba4e-25b13bb8efd7',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd9e32e66-93d9-4689-b94c-81886e712a85' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'VideoProviderID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd9e32e66-93d9-4689-b94c-81886e712a85',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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
            '79634853-B251-4DD5-B1D3-35001E4A0824',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0d331233-eae1-41b5-a90a-ea93be501746' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'VideoMeetingID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0d331233-eae1-41b5-a90a-ea93be501746',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6f3b5624-4123-42a8-9964-a8c6879785df' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'VideoJoinURL')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6f3b5624-4123-42a8-9964-a8c6879785df',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '30df75b4-6ea5-4ad9-b1b3-daab362b3351' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'DialInDetails')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '30df75b4-6ea5-4ad9-b1b3-daab362b3351',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '764c5e86-ec9e-4a51-be4a-c9fb68bff4ab' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'OrganizerPersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '764c5e86-ec9e-4a51-be4a-c9fb68bff4ab',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd2e8257e-a25b-4db2-ad31-11580e9c4f95' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'Visibility')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd2e8257e-a25b-4db2-ad31-11580e9c4f95',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'be29ff1b-3721-4890-b006-cb9685cee890' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'ActualStartedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'be29ff1b-3721-4890-b006-cb9685cee890',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '524fc57d-1d9b-4b8c-b40a-e4cb626655e2' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'ActualEndedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '524fc57d-1d9b-4b8c-b40a-e4cb626655e2',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0a9c4788-753e-4b2d-b58a-8c0575be15c0' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'CancelledAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0a9c4788-753e-4b2d-b58a-8c0575be15c0',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '00a41aee-58e6-4f2d-9801-054cffb23657' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'CancellationReason')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '00a41aee-58e6-4f2d-9801-054cffb23657',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '926c73ac-9ec3-4274-ac60-00834b3996e7' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'VideoRecordingURL')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '926c73ac-9ec3-4274-ac60-00834b3996e7',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a8457025-454c-4428-8c0c-bdc5ad82af69' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'TranscriptFileID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a8457025-454c-4428-8c0c-bdc5ad82af69',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '974d8b4d-a629-442f-b2ed-f257bed9a76d' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'CreatedByPersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '974d8b4d-a629-442f-b2ed-f257bed9a76d',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f8ee6d49-aaa1-4fb5-b4e0-af4bd9d4f09b' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f8ee6d49-aaa1-4fb5-b4e0-af4bd9d4f09b',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4bf8690f-ae26-493a-a206-d1c3fa8261ca' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4bf8690f-ae26-493a-a206-d1c3fa8261ca',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a8f459de-0ed1-4c98-9545-2070ad4c5028' OR (EntityID = '3418E742-27E0-4DF9-9030-84EE319851F2' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a8f459de-0ed1-4c98-9545-2070ad4c5028',
            '3418E742-27E0-4DF9-9030-84EE319851F2', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '3418E742-27E0-4DF9-9030-84EE319851F2'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd5566483-0ff3-4062-b3e9-1b49b4f31487' OR (EntityID = '3418E742-27E0-4DF9-9030-84EE319851F2' AND Name = 'MeetingID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd5566483-0ff3-4062-b3e9-1b49b4f31487',
            '3418E742-27E0-4DF9-9030-84EE319851F2', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '3418E742-27E0-4DF9-9030-84EE319851F2'),
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
            'D8B37817-4EB1-414C-9273-5977AB80DB63',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '18e983f3-aea7-455f-9553-ecf122cd946d' OR (EntityID = '3418E742-27E0-4DF9-9030-84EE319851F2' AND Name = 'SeriesID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '18e983f3-aea7-455f-9553-ecf122cd946d',
            '3418E742-27E0-4DF9-9030-84EE319851F2', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '3418E742-27E0-4DF9-9030-84EE319851F2'),
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
            '02B53C81-832E-428A-8CE8-493189EE4B28',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2444dba8-3236-4f5c-92c3-9ff53e182466' OR (EntityID = '3418E742-27E0-4DF9-9030-84EE319851F2' AND Name = 'EntityID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2444dba8-3236-4f5c-92c3-9ff53e182466',
            '3418E742-27E0-4DF9-9030-84EE319851F2', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '3418E742-27E0-4DF9-9030-84EE319851F2'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4ec6eb44-e01f-4858-a80f-0533c9cff85a' OR (EntityID = '3418E742-27E0-4DF9-9030-84EE319851F2' AND Name = 'RecordID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4ec6eb44-e01f-4858-a80f-0533c9cff85a',
            '3418E742-27E0-4DF9-9030-84EE319851F2', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '3418E742-27E0-4DF9-9030-84EE319851F2'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '23551b79-f7f5-4dab-b325-8f94be73e655' OR (EntityID = '3418E742-27E0-4DF9-9030-84EE319851F2' AND Name = 'Description')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '23551b79-f7f5-4dab-b325-8f94be73e655',
            '3418E742-27E0-4DF9-9030-84EE319851F2', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '3418E742-27E0-4DF9-9030-84EE319851F2'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0cea2dc5-f008-4847-bc4b-96698537b8bc' OR (EntityID = '3418E742-27E0-4DF9-9030-84EE319851F2' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0cea2dc5-f008-4847-bc4b-96698537b8bc',
            '3418E742-27E0-4DF9-9030-84EE319851F2', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '3418E742-27E0-4DF9-9030-84EE319851F2'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e0db3351-a2d2-4dcb-a0e4-f892e5467c71' OR (EntityID = '3418E742-27E0-4DF9-9030-84EE319851F2' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e0db3351-a2d2-4dcb-a0e4-f892e5467c71',
            '3418E742-27E0-4DF9-9030-84EE319851F2', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '3418E742-27E0-4DF9-9030-84EE319851F2'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7d4d4b41-8187-46d6-87b0-a34caaa744a7' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7d4d4b41-8187-46d6-87b0-a34caaa744a7',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8d1bd6aa-fac2-424d-a25c-24f0d2f965d4' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = 'Name')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8d1bd6aa-fac2-424d-a25c-24f0d2f965d4',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a1f409b1-5577-4b03-981e-7cc316c09853' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = 'Code')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a1f409b1-5577-4b03-981e-7cc316c09853',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd79aa204-f0a9-4e54-9eaf-cab02f3ff6f2' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = 'Description')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd79aa204-f0a9-4e54-9eaf-cab02f3ff6f2',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8f3d8cf6-82d9-4625-b382-823030b592d5' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = 'IconClass')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8f3d8cf6-82d9-4625-b382-823030b592d5',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ebf2516a-17e9-4b60-a3d9-eb0d8e009074' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = 'DefaultDurationMinutes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ebf2516a-17e9-4b60-a3d9-eb0d8e009074',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3030c13c-e3df-45f7-bf41-5237c6d30717' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = 'DefaultLocationType')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3030c13c-e3df-45f7-bf41-5237c6d30717',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '62354bb6-0e02-41ee-97e7-f402febb9eed' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = 'DefaultVideoProviderID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '62354bb6-0e02-41ee-97e7-f402febb9eed',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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
            '79634853-B251-4DD5-B1D3-35001E4A0824',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '17e6ce8c-7e00-4637-aca6-32d507c97096' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = 'DefaultVisibility')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '17e6ce8c-7e00-4637-aca6-32d507c97096',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2b28fddc-8e97-443f-a032-92c94d873ee0' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = 'AgendaTemplate')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2b28fddc-8e97-443f-a032-92c94d873ee0',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd5cb2596-c53e-411d-a198-8c71dbbf8745' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = 'NotesPromptID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd5cb2596-c53e-411d-a198-8c71dbbf8745',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '59fba2d7-f9b8-4c6d-91d8-e4afa37bc6b3' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = 'IsActive')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '59fba2d7-f9b8-4c6d-91d8-e4afa37bc6b3',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7b72f1d6-1f42-4378-8bae-64d7fa084b11' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = 'Sequence')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7b72f1d6-1f42-4378-8bae-64d7fa084b11',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '80489c76-e5cf-4593-a052-894bb60bb21a' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '80489c76-e5cf-4593-a052-894bb60bb21a',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2ea79d59-51fd-4f88-a27a-4474078b2b02' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2ea79d59-51fd-4f88-a27a-4474078b2b02',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fa6cbf53-2a76-4a3f-9b1a-ae765e74cdff' OR (EntityID = 'C625AAE9-906F-4056-90AC-C655886D3F69' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'fa6cbf53-2a76-4a3f-9b1a-ae765e74cdff',
            'C625AAE9-906F-4056-90AC-C655886D3F69', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C625AAE9-906F-4056-90AC-C655886D3F69'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '678f782d-06c0-45f6-88a8-d2e762610cb1' OR (EntityID = 'C625AAE9-906F-4056-90AC-C655886D3F69' AND Name = 'Name')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '678f782d-06c0-45f6-88a8-d2e762610cb1',
            'C625AAE9-906F-4056-90AC-C655886D3F69', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C625AAE9-906F-4056-90AC-C655886D3F69'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '331177a0-9b29-4aa3-8940-6edf14aa1048' OR (EntityID = 'C625AAE9-906F-4056-90AC-C655886D3F69' AND Name = 'Code')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '331177a0-9b29-4aa3-8940-6edf14aa1048',
            'C625AAE9-906F-4056-90AC-C655886D3F69', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C625AAE9-906F-4056-90AC-C655886D3F69'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fb08bad8-fd5c-4b1b-9607-177de661dd4f' OR (EntityID = 'C625AAE9-906F-4056-90AC-C655886D3F69' AND Name = 'Description')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'fb08bad8-fd5c-4b1b-9607-177de661dd4f',
            'C625AAE9-906F-4056-90AC-C655886D3F69', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C625AAE9-906F-4056-90AC-C655886D3F69'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd40111f9-8cb7-4b43-87f4-bd83290d1523' OR (EntityID = 'C625AAE9-906F-4056-90AC-C655886D3F69' AND Name = 'IconClass')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd40111f9-8cb7-4b43-87f4-bd83290d1523',
            'C625AAE9-906F-4056-90AC-C655886D3F69', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C625AAE9-906F-4056-90AC-C655886D3F69'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1a9c19a7-0ec7-4661-b2b0-b8eeeb2f2ade' OR (EntityID = 'C625AAE9-906F-4056-90AC-C655886D3F69' AND Name = 'DefaultDurationMinutes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1a9c19a7-0ec7-4661-b2b0-b8eeeb2f2ade',
            'C625AAE9-906F-4056-90AC-C655886D3F69', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C625AAE9-906F-4056-90AC-C655886D3F69'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd983a9ff-1a2f-4fb7-b18a-216980b1b585' OR (EntityID = 'C625AAE9-906F-4056-90AC-C655886D3F69' AND Name = 'IsActive')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd983a9ff-1a2f-4fb7-b18a-216980b1b585',
            'C625AAE9-906F-4056-90AC-C655886D3F69', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C625AAE9-906F-4056-90AC-C655886D3F69'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a2d8d518-0bab-4089-b629-78d0814d79c8' OR (EntityID = 'C625AAE9-906F-4056-90AC-C655886D3F69' AND Name = 'Sequence')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a2d8d518-0bab-4089-b629-78d0814d79c8',
            'C625AAE9-906F-4056-90AC-C655886D3F69', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C625AAE9-906F-4056-90AC-C655886D3F69'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'cb135a37-ed73-4369-89d4-95a9035031fc' OR (EntityID = 'C625AAE9-906F-4056-90AC-C655886D3F69' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'cb135a37-ed73-4369-89d4-95a9035031fc',
            'C625AAE9-906F-4056-90AC-C655886D3F69', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C625AAE9-906F-4056-90AC-C655886D3F69'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f2004f38-c174-48a1-ba93-b905f2c9acbe' OR (EntityID = 'C625AAE9-906F-4056-90AC-C655886D3F69' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f2004f38-c174-48a1-ba93-b905f2c9acbe',
            'C625AAE9-906F-4056-90AC-C655886D3F69', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Item Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C625AAE9-906F-4056-90AC-C655886D3F69'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '267ef6c9-58b0-4271-b942-e68b732e0bbd' OR (EntityID = 'E4283E35-10E3-41AC-AA30-D28890A55D62' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '267ef6c9-58b0-4271-b942-e68b732e0bbd',
            'E4283E35-10E3-41AC-AA30-D28890A55D62', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E4283E35-10E3-41AC-AA30-D28890A55D62'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9d7dc0dd-ded6-4ef1-ab1e-9e64b20ba454' OR (EntityID = 'E4283E35-10E3-41AC-AA30-D28890A55D62' AND Name = 'SeriesID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9d7dc0dd-ded6-4ef1-ab1e-9e64b20ba454',
            'E4283E35-10E3-41AC-AA30-D28890A55D62', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E4283E35-10E3-41AC-AA30-D28890A55D62'),
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
            '02B53C81-832E-428A-8CE8-493189EE4B28',
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c729c24f-edcb-4a72-ae37-c5b3399d1126' OR (EntityID = 'E4283E35-10E3-41AC-AA30-D28890A55D62' AND Name = 'PersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c729c24f-edcb-4a72-ae37-c5b3399d1126',
            'E4283E35-10E3-41AC-AA30-D28890A55D62', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E4283E35-10E3-41AC-AA30-D28890A55D62'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '27389469-cc0e-4958-af50-e3c7181545fe' OR (EntityID = 'E4283E35-10E3-41AC-AA30-D28890A55D62' AND Name = 'UserID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '27389469-cc0e-4958-af50-e3c7181545fe',
            'E4283E35-10E3-41AC-AA30-D28890A55D62', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E4283E35-10E3-41AC-AA30-D28890A55D62'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '45db4ce2-68bf-41e7-ad0c-65b44bc5ce97' OR (EntityID = 'E4283E35-10E3-41AC-AA30-D28890A55D62' AND Name = 'Email')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '45db4ce2-68bf-41e7-ad0c-65b44bc5ce97',
            'E4283E35-10E3-41AC-AA30-D28890A55D62', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E4283E35-10E3-41AC-AA30-D28890A55D62'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ff48168b-3546-4af8-9ffd-b57cf0489a58' OR (EntityID = 'E4283E35-10E3-41AC-AA30-D28890A55D62' AND Name = 'DisplayName')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ff48168b-3546-4af8-9ffd-b57cf0489a58',
            'E4283E35-10E3-41AC-AA30-D28890A55D62', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E4283E35-10E3-41AC-AA30-D28890A55D62'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c1d21aa8-11e7-4a36-879e-5055da726fe0' OR (EntityID = 'E4283E35-10E3-41AC-AA30-D28890A55D62' AND Name = 'Role')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c1d21aa8-11e7-4a36-879e-5055da726fe0',
            'E4283E35-10E3-41AC-AA30-D28890A55D62', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E4283E35-10E3-41AC-AA30-D28890A55D62'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '7fb35e6b-2063-4d30-ac2b-a487e0c9e325' OR (EntityID = 'E4283E35-10E3-41AC-AA30-D28890A55D62' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '7fb35e6b-2063-4d30-ac2b-a487e0c9e325',
            'E4283E35-10E3-41AC-AA30-D28890A55D62', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E4283E35-10E3-41AC-AA30-D28890A55D62'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a81dd882-0e62-4022-a913-775d1dfb9513' OR (EntityID = 'E4283E35-10E3-41AC-AA30-D28890A55D62' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a81dd882-0e62-4022-a913-775d1dfb9513',
            'E4283E35-10E3-41AC-AA30-D28890A55D62', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E4283E35-10E3-41AC-AA30-D28890A55D62'),
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

/* SQL text to insert entity field value with ID fcd49d08-e972-435a-9ea4-ef726cd1d422 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('fcd49d08-e972-435a-9ea4-ef726cd1d422', 'D54A48C4-278A-471D-B4C8-9A5B4C2CCD14', 1, 'Deferred', 'Deferred', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 8883fc1e-19fe-43d1-8e43-a9fae0318729 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('8883fc1e-19fe-43d1-8e43-a9fae0318729', 'D54A48C4-278A-471D-B4C8-9A5B4C2CCD14', 2, 'Done', 'Done', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID a24c53f8-a0af-407a-aee7-50424364e1f6 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a24c53f8-a0af-407a-aee7-50424364e1f6', 'D54A48C4-278A-471D-B4C8-9A5B4C2CCD14', 3, 'InProgress', 'InProgress', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 7debe633-32ca-46e0-b65a-cb7e8be63bf7 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7debe633-32ca-46e0-b65a-cb7e8be63bf7', 'D54A48C4-278A-471D-B4C8-9A5B4C2CCD14', 4, 'Planned', 'Planned', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID a8e1256f-c5e8-46c8-8b2e-55616f2f031f */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a8e1256f-c5e8-46c8-8b2e-55616f2f031f', 'D54A48C4-278A-471D-B4C8-9A5B4C2CCD14', 5, 'Skipped', 'Skipped', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID D54A48C4-278A-471D-B4C8-9A5B4C2CCD14 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='D54A48C4-278A-471D-B4C8-9A5B4C2CCD14';

/* SQL text to insert entity field value with ID 2d7a9b0c-e48a-4a35-9b5f-fe92f168171b */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('2d7a9b0c-e48a-4a35-9b5f-fe92f168171b', '621DACE8-6B57-4A39-9A9F-25BE8EA57A5C', 1, 'Decision', 'Decision', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID f0a5281c-6269-42f2-be2d-e763567893c9 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f0a5281c-6269-42f2-be2d-e763567893c9', '621DACE8-6B57-4A39-9A9F-25BE8EA57A5C', 2, 'Notes', 'Notes', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID c5c8b4a6-2214-4fa7-b641-2550fec393e7 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c5c8b4a6-2214-4fa7-b641-2550fec393e7', '621DACE8-6B57-4A39-9A9F-25BE8EA57A5C', 3, 'Summary', 'Summary', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 621DACE8-6B57-4A39-9A9F-25BE8EA57A5C */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='621DACE8-6B57-4A39-9A9F-25BE8EA57A5C';

/* SQL text to insert entity field value with ID 55ab7578-485e-4125-a0a4-e4b05fd4b007 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('55ab7578-485e-4125-a0a4-e4b05fd4b007', 'CB39F3E7-BE6E-453C-A089-409076E50D53', 1, 'AI', 'AI', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 2eef9420-3dad-43d2-b122-d8ac6d1549c3 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('2eef9420-3dad-43d2-b122-d8ac6d1549c3', 'CB39F3E7-BE6E-453C-A089-409076E50D53', 2, 'Manual', 'Manual', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID CB39F3E7-BE6E-453C-A089-409076E50D53 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='CB39F3E7-BE6E-453C-A089-409076E50D53';

/* SQL text to insert entity field value with ID 47e4d1bd-7bd4-4eea-b491-ee480370c889 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('47e4d1bd-7bd4-4eea-b491-ee480370c889', '1290ADBA-E74C-4C38-9BD1-3FC468FC343E', 1, 'Draft', 'Draft', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 23f19b93-bb7c-4637-ad81-1a47609ae446 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('23f19b93-bb7c-4637-ad81-1a47609ae446', '1290ADBA-E74C-4C38-9BD1-3FC468FC343E', 2, 'Final', 'Final', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 1290ADBA-E74C-4C38-9BD1-3FC468FC343E */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='1290ADBA-E74C-4C38-9BD1-3FC468FC343E';

/* SQL text to insert entity field value with ID bd23d982-0c79-4e11-8552-ba0509571200 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('bd23d982-0c79-4e11-8552-ba0509571200', '3030C13C-E3DF-45F7-BF41-5237C6D30717', 1, 'Hybrid', 'Hybrid', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID c98fdd7a-6662-4473-8c89-c9d9874d5a06 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c98fdd7a-6662-4473-8c89-c9d9874d5a06', '3030C13C-E3DF-45F7-BF41-5237C6D30717', 2, 'InPerson', 'InPerson', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 5bc312ab-4363-4ada-b72b-ad2ecf152b0e */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('5bc312ab-4363-4ada-b72b-ad2ecf152b0e', '3030C13C-E3DF-45F7-BF41-5237C6D30717', 3, 'Phone', 'Phone', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 29903903-4000-4571-ae77-320eda42aada */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('29903903-4000-4571-ae77-320eda42aada', '3030C13C-E3DF-45F7-BF41-5237C6D30717', 4, 'Virtual', 'Virtual', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 3030C13C-E3DF-45F7-BF41-5237C6D30717 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='3030C13C-E3DF-45F7-BF41-5237C6D30717';

/* SQL text to insert entity field value with ID a4808995-38fb-4ab3-96cf-1dc4fcc5649a */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a4808995-38fb-4ab3-96cf-1dc4fcc5649a', '17E6CE8C-7E00-4637-ACA6-32D507C97096', 1, 'Private', 'Private', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 67b20b88-c4b2-40a9-8738-a86af50a7620 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('67b20b88-c4b2-40a9-8738-a86af50a7620', '17E6CE8C-7E00-4637-ACA6-32D507C97096', 2, 'Standard', 'Standard', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 17E6CE8C-7E00-4637-ACA6-32D507C97096 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='17E6CE8C-7E00-4637-ACA6-32D507C97096';

/* SQL text to insert entity field value with ID 1013d846-3ba0-4500-b372-0638e49ef333 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1013d846-3ba0-4500-b372-0638e49ef333', '1EB94D6A-4B9F-4D56-B3BC-DE310B093445', 1, 'Hybrid', 'Hybrid', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID df535442-3010-427b-b71a-f934e066ef84 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('df535442-3010-427b-b71a-f934e066ef84', '1EB94D6A-4B9F-4D56-B3BC-DE310B093445', 2, 'InPerson', 'InPerson', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 1ed12bf3-a046-49fd-8139-c5c6d0753464 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1ed12bf3-a046-49fd-8139-c5c6d0753464', '1EB94D6A-4B9F-4D56-B3BC-DE310B093445', 3, 'Phone', 'Phone', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 7c330526-0a41-448c-bcfe-4859a63c81eb */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7c330526-0a41-448c-bcfe-4859a63c81eb', '1EB94D6A-4B9F-4D56-B3BC-DE310B093445', 4, 'Virtual', 'Virtual', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 1EB94D6A-4B9F-4D56-B3BC-DE310B093445 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='1EB94D6A-4B9F-4D56-B3BC-DE310B093445';

/* SQL text to insert entity field value with ID 2df122c5-5621-497a-b62c-1e010c2ef5ba */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('2df122c5-5621-497a-b62c-1e010c2ef5ba', '0241843F-271F-4EC4-88BF-0DD8D7AACA46', 1, 'Private', 'Private', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 12c1c28d-b126-4ac7-b948-f19d345abdbd */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('12c1c28d-b126-4ac7-b948-f19d345abdbd', '0241843F-271F-4EC4-88BF-0DD8D7AACA46', 2, 'Standard', 'Standard', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 0241843F-271F-4EC4-88BF-0DD8D7AACA46 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='0241843F-271F-4EC4-88BF-0DD8D7AACA46';

/* SQL text to insert entity field value with ID 9c0a4c95-6d8b-4d1f-8240-4429dd75e3cb */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9c0a4c95-6d8b-4d1f-8240-4429dd75e3cb', 'A0F5F602-1388-4C16-9B16-2B597449C880', 1, 'Active', 'Active', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID e4c86fb0-c3a7-4fbe-9268-291708734252 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('e4c86fb0-c3a7-4fbe-9268-291708734252', 'A0F5F602-1388-4C16-9B16-2B597449C880', 2, 'Cancelled', 'Cancelled', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID f0590c92-348c-40dc-8ab9-7b3991a433ca */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f0590c92-348c-40dc-8ab9-7b3991a433ca', 'A0F5F602-1388-4C16-9B16-2B597449C880', 3, 'Ended', 'Ended', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID A0F5F602-1388-4C16-9B16-2B597449C880 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='A0F5F602-1388-4C16-9B16-2B597449C880';

/* SQL text to insert entity field value with ID 50b0d32f-7dde-427a-a8a9-a33b7956a8db */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('50b0d32f-7dde-427a-a8a9-a33b7956a8db', '1AFF37CD-ACE0-4E81-858F-E099A19914F6', 1, 'Cancelled', 'Cancelled', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID bee1f983-aa89-459f-9387-7b379e40907f */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('bee1f983-aa89-459f-9387-7b379e40907f', '1AFF37CD-ACE0-4E81-858F-E099A19914F6', 2, 'Completed', 'Completed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID fbd039af-fc15-4feb-b4c3-087fbfc7b346 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('fbd039af-fc15-4feb-b4c3-087fbfc7b346', '1AFF37CD-ACE0-4E81-858F-E099A19914F6', 3, 'Draft', 'Draft', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 16aeb99a-f2b2-408b-9a3c-3d24d1e7b18e */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('16aeb99a-f2b2-408b-9a3c-3d24d1e7b18e', '1AFF37CD-ACE0-4E81-858F-E099A19914F6', 4, 'InProgress', 'InProgress', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 13b75feb-9c24-4866-a6c2-080b682ae086 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('13b75feb-9c24-4866-a6c2-080b682ae086', '1AFF37CD-ACE0-4E81-858F-E099A19914F6', 5, 'Postponed', 'Postponed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 8efbc57c-d2ba-448f-a614-155303f719c9 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('8efbc57c-d2ba-448f-a614-155303f719c9', '1AFF37CD-ACE0-4E81-858F-E099A19914F6', 6, 'Scheduled', 'Scheduled', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 1AFF37CD-ACE0-4E81-858F-E099A19914F6 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='1AFF37CD-ACE0-4E81-858F-E099A19914F6';

/* SQL text to insert entity field value with ID 1397ca30-2ded-4b59-9735-fe6e9b726447 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1397ca30-2ded-4b59-9735-fe6e9b726447', '31D45B39-D108-48F8-B956-C938D098D85F', 1, 'Hybrid', 'Hybrid', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 31fe8ba0-b102-4c9f-866b-a2d7c7ffd16b */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('31fe8ba0-b102-4c9f-866b-a2d7c7ffd16b', '31D45B39-D108-48F8-B956-C938D098D85F', 2, 'InPerson', 'InPerson', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 55af678c-5fbe-4947-b659-d446b4af7938 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('55af678c-5fbe-4947-b659-d446b4af7938', '31D45B39-D108-48F8-B956-C938D098D85F', 3, 'Phone', 'Phone', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 4ab9ab95-3864-4f02-82bb-a58192fe0309 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('4ab9ab95-3864-4f02-82bb-a58192fe0309', '31D45B39-D108-48F8-B956-C938D098D85F', 4, 'Virtual', 'Virtual', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 31D45B39-D108-48F8-B956-C938D098D85F */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='31D45B39-D108-48F8-B956-C938D098D85F';

/* SQL text to insert entity field value with ID a49cb6b4-a540-4871-a898-48bf5def1f53 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a49cb6b4-a540-4871-a898-48bf5def1f53', 'D2E8257E-A25B-4DB2-AD31-11580E9C4F95', 1, 'Private', 'Private', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 01cab17d-6aba-4b75-afb4-cb616449451d */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('01cab17d-6aba-4b75-afb4-cb616449451d', 'D2E8257E-A25B-4DB2-AD31-11580E9C4F95', 2, 'Standard', 'Standard', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID D2E8257E-A25B-4DB2-AD31-11580E9C4F95 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='D2E8257E-A25B-4DB2-AD31-11580E9C4F95';

/* SQL text to insert entity field value with ID 75b27acb-b3d0-4c96-a4e1-a043a2ca4f4a */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('75b27acb-b3d0-4c96-a4e1-a043a2ca4f4a', 'C1D21AA8-11E7-4A36-879E-5055DA726FE0', 1, 'Optional', 'Optional', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID c2c19a9c-99b5-4658-810b-827d54514b5b */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c2c19a9c-99b5-4658-810b-827d54514b5b', 'C1D21AA8-11E7-4A36-879E-5055DA726FE0', 2, 'Required', 'Required', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID C1D21AA8-11E7-4A36-879E-5055DA726FE0 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='C1D21AA8-11E7-4A36-879E-5055DA726FE0';

/* SQL text to insert entity field value with ID 13887626-90f9-4655-b663-7ad1873618c0 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('13887626-90f9-4655-b663-7ad1873618c0', 'C0ACE054-8F8B-4E8A-9130-279BA291A5D6', 1, 'Optional', 'Optional', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID a7d7dc55-ab4b-4589-a46d-14ebbb4b48ed */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a7d7dc55-ab4b-4589-a46d-14ebbb4b48ed', 'C0ACE054-8F8B-4E8A-9130-279BA291A5D6', 2, 'Organizer', 'Organizer', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 0be05059-2f86-43b8-b6e4-d0a0222b4492 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0be05059-2f86-43b8-b6e4-d0a0222b4492', 'C0ACE054-8F8B-4E8A-9130-279BA291A5D6', 3, 'Required', 'Required', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID C0ACE054-8F8B-4E8A-9130-279BA291A5D6 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='C0ACE054-8F8B-4E8A-9130-279BA291A5D6';

/* SQL text to insert entity field value with ID 0dc579f4-9344-4965-b699-b7aa3dfe79fd */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0dc579f4-9344-4965-b699-b7aa3dfe79fd', 'BEEAD1D3-223D-44E7-B3C6-F4EC0B41EF1B', 1, 'Accepted', 'Accepted', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID ff694a0b-2075-4723-bdd4-686445f3ab62 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ff694a0b-2075-4723-bdd4-686445f3ab62', 'BEEAD1D3-223D-44E7-B3C6-F4EC0B41EF1B', 2, 'Declined', 'Declined', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b885b238-08ed-4d80-b4a5-f2c5da8228b3 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b885b238-08ed-4d80-b4a5-f2c5da8228b3', 'BEEAD1D3-223D-44E7-B3C6-F4EC0B41EF1B', 3, 'None', 'None', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 5953629f-82aa-46ff-9f8c-a8083abde96d */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('5953629f-82aa-46ff-9f8c-a8083abde96d', 'BEEAD1D3-223D-44E7-B3C6-F4EC0B41EF1B', 4, 'Tentative', 'Tentative', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID BEEAD1D3-223D-44E7-B3C6-F4EC0B41EF1B */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='BEEAD1D3-223D-44E7-B3C6-F4EC0B41EF1B';

/* SQL text to insert entity field value with ID 1a7f4605-2041-4832-b910-6f4d406792d0 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1a7f4605-2041-4832-b910-6f4d406792d0', '54779B4A-7EE4-4D06-AC1F-1AF4EDA94EE4', 1, 'Absent', 'Absent', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 36fd3591-fc42-4bd8-bddf-68780cbb7af8 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('36fd3591-fc42-4bd8-bddf-68780cbb7af8', '54779B4A-7EE4-4D06-AC1F-1AF4EDA94EE4', 2, 'Excused', 'Excused', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 5ab7e030-03af-4877-80d9-976822fa269f */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('5ab7e030-03af-4877-80d9-976822fa269f', '54779B4A-7EE4-4D06-AC1F-1AF4EDA94EE4', 3, 'Late', 'Late', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 9910fc24-763a-4060-b78c-db7ef2a35797 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9910fc24-763a-4060-b78c-db7ef2a35797', '54779B4A-7EE4-4D06-AC1F-1AF4EDA94EE4', 4, 'LeftEarly', 'LeftEarly', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 7d1debbb-29a2-49b5-94c8-41a7beb1309a */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7d1debbb-29a2-49b5-94c8-41a7beb1309a', '54779B4A-7EE4-4D06-AC1F-1AF4EDA94EE4', 5, 'Present', 'Present', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID f15309cd-2e73-477b-bcf5-6c8ea5b6c74f */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f15309cd-2e73-477b-bcf5-6c8ea5b6c74f', '54779B4A-7EE4-4D06-AC1F-1AF4EDA94EE4', 6, 'Unknown', 'Unknown', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 54779B4A-7EE4-4D06-AC1F-1AF4EDA94EE4 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='54779B4A-7EE4-4D06-AC1F-1AF4EDA94EE4';

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
                 AND e.[SchemaName] NOT IN ('${mjSchema}','${mjSchema}_BizAppsCommon','sys')
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
              AND e.[SchemaName] NOT IN ('${mjSchema}','${mjSchema}_BizAppsCommon','sys')
              AND NOT EXISTS (
               SELECT 1 FROM [${mjSchema}].[EntityField] f2
               WHERE f2.[EntityID] = e.[ID]
                 AND f2.[IncludeInUserSearchAPI] = 1
            )
         );


/* Create Entity Relationship: MJ_BizApps_Tasks: Meeting Agenda Items -> MJ_BizApps_Tasks: Meeting Agenda Items (One To Many via ParentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '5b797837-8769-4cef-a9b8-5fed7d5b6de5'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('5b797837-8769-4cef-a9b8-5fed7d5b6de5', '9C171F1D-86F9-4630-8548-1DC6163272CA', '9C171F1D-86F9-4630-8548-1DC6163272CA', 'ParentID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meeting Agenda Items -> MJ_BizApps_Tasks: Meeting Notes (One To Many via AgendaItemID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '624857fa-2d52-4316-9c95-75b388a26811'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('624857fa-2d52-4316-9c95-75b388a26811', '9C171F1D-86F9-4630-8548-1DC6163272CA', '02892041-B070-475D-9486-5570486DDBEC', 'AgendaItemID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Video Providers -> MJ_BizApps_Tasks: Meeting Series (One To Many via VideoProviderID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '86d1df92-6a14-4581-af4c-36011cd10b8c'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('86d1df92-6a14-4581-af4c-36011cd10b8c', '79634853-B251-4DD5-B1D3-35001E4A0824', '02B53C81-832E-428A-8CE8-493189EE4B28', 'VideoProviderID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Video Providers -> MJ_BizApps_Tasks: Meetings (One To Many via VideoProviderID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '6b347252-0189-4c0c-9cab-2b0a915a3699'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('6b347252-0189-4c0c-9cab-2b0a915a3699', '79634853-B251-4DD5-B1D3-35001E4A0824', 'D8B37817-4EB1-414C-9273-5977AB80DB63', 'VideoProviderID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Video Providers -> MJ_BizApps_Tasks: Meeting Types (One To Many via DefaultVideoProviderID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'f98cc3a4-6837-4fce-bdfe-86198031439d'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('f98cc3a4-6837-4fce-bdfe-86198031439d', '79634853-B251-4DD5-B1D3-35001E4A0824', '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', 'DefaultVideoProviderID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meeting Series -> MJ_BizApps_Tasks: Meetings (One To Many via SeriesID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '247eefba-6215-47ca-9a6f-334a3cfb29f1'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('247eefba-6215-47ca-9a6f-334a3cfb29f1', '02B53C81-832E-428A-8CE8-493189EE4B28', 'D8B37817-4EB1-414C-9273-5977AB80DB63', 'SeriesID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meeting Series -> MJ_BizApps_Tasks: Meeting Links (One To Many via SeriesID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '9ff12cc1-f8cc-400a-acf2-02ce60e35789'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('9ff12cc1-f8cc-400a-acf2-02ce60e35789', '02B53C81-832E-428A-8CE8-493189EE4B28', '3418E742-27E0-4DF9-9030-84EE319851F2', 'SeriesID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meeting Series -> MJ_BizApps_Tasks: Meeting Series Attendees (One To Many via SeriesID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'a0413109-bf61-4366-b8b6-decf7b7ff005'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('a0413109-bf61-4366-b8b6-decf7b7ff005', '02B53C81-832E-428A-8CE8-493189EE4B28', 'E4283E35-10E3-41AC-AA30-D28890A55D62', 'SeriesID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Meetings -> MJ_BizApps_Tasks: Meeting Agenda Items (One To Many via MeetingID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '531c7b45-a778-4096-a365-205dc263c0be'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('531c7b45-a778-4096-a365-205dc263c0be', 'D8B37817-4EB1-414C-9273-5977AB80DB63', '9C171F1D-86F9-4630-8548-1DC6163272CA', 'MeetingID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meetings -> MJ_BizApps_Tasks: Meeting Agenda Items (One To Many via DeferredToMeetingID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '1681a870-521a-4881-b32c-a2b9c7aaf91f'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('1681a870-521a-4881-b32c-a2b9c7aaf91f', 'D8B37817-4EB1-414C-9273-5977AB80DB63', '9C171F1D-86F9-4630-8548-1DC6163272CA', 'DeferredToMeetingID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meetings -> MJ_BizApps_Tasks: Meeting Attendees (One To Many via MeetingID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'da2ede5a-c636-43e1-abe9-0636d6549b1e'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('da2ede5a-c636-43e1-abe9-0636d6549b1e', 'D8B37817-4EB1-414C-9273-5977AB80DB63', '87EF481F-8E24-4863-B5DE-1E31B17E89F3', 'MeetingID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meetings -> MJ_BizApps_Tasks: Meeting Notes (One To Many via MeetingID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'df089b0d-0303-4a28-9d78-69a89df37bf0'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('df089b0d-0303-4a28-9d78-69a89df37bf0', 'D8B37817-4EB1-414C-9273-5977AB80DB63', '02892041-B070-475D-9486-5570486DDBEC', 'MeetingID', 'One To Many', 1, 1, 4, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meetings -> MJ_BizApps_Tasks: Meeting Links (One To Many via MeetingID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '05098847-9fab-408a-a22b-1c15b6d07581'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('05098847-9fab-408a-a22b-1c15b6d07581', 'D8B37817-4EB1-414C-9273-5977AB80DB63', '3418E742-27E0-4DF9-9030-84EE319851F2', 'MeetingID', 'One To Many', 1, 1, 5, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ: AI Prompts -> MJ_BizApps_Tasks: Meeting Types (One To Many via NotesPromptID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '59a6ad59-78a6-4185-8969-531c1420469c'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('59a6ad59-78a6-4185-8969-531c1420469c', '73AD0238-8B56-EF11-991A-6045BDEBA539', '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', 'NotesPromptID', 'One To Many', 1, 1, 25, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Entities -> MJ_BizApps_Tasks: Meeting Links (One To Many via EntityID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '055bf458-a007-47a7-9209-b458df589d4b'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('055bf458-a007-47a7-9209-b458df589d4b', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '3418E742-27E0-4DF9-9030-84EE319851F2', 'EntityID', 'One To Many', 1, 1, 91, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Users -> MJ_BizApps_Tasks: Meeting Attendees (One To Many via UserID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'cee3d308-3338-4997-a430-b9722a56f2bd'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('cee3d308-3338-4997-a430-b9722a56f2bd', 'E1238F34-2837-EF11-86D4-6045BDEE16E6', '87EF481F-8E24-4863-B5DE-1E31B17E89F3', 'UserID', 'One To Many', 1, 1, 123, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ: Users -> MJ_BizApps_Tasks: Meeting Series Attendees (One To Many via UserID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'fe57e5eb-ba09-4ad7-a924-c4c3aafc737b'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('fe57e5eb-ba09-4ad7-a924-c4c3aafc737b', 'E1238F34-2837-EF11-86D4-6045BDEE16E6', 'E4283E35-10E3-41AC-AA30-D28890A55D62', 'UserID', 'One To Many', 1, 1, 124, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Files -> MJ_BizApps_Tasks: Meetings (One To Many via TranscriptFileID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'c3c519ec-789f-4220-afc8-13e7ca23bc31'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('c3c519ec-789f-4220-afc8-13e7ca23bc31', '29248F34-2837-EF11-86D4-6045BDEE16E6', 'D8B37817-4EB1-414C-9273-5977AB80DB63', 'TranscriptFileID', 'One To Many', 1, 1, 10, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ: Credentials -> MJ_BizApps_Tasks: Video Providers (One To Many via CredentialID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'ea7f9648-860d-4451-92d1-ae820c261aca'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('ea7f9648-860d-4451-92d1-ae820c261aca', '7E023DDF-82C6-4B0C-9650-8D35699B9FD0', '79634853-B251-4DD5-B1D3-35001E4A0824', 'CredentialID', 'One To Many', 1, 1, 14, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meeting Types -> MJ_BizApps_Tasks: Meeting Series (One To Many via TypeID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '1053fe5e-ef0d-48ad-a7c4-437118243b82'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('1053fe5e-ef0d-48ad-a7c4-437118243b82', '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', '02B53C81-832E-428A-8CE8-493189EE4B28', 'TypeID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Meeting Types -> MJ_BizApps_Tasks: Meetings (One To Many via TypeID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'dd1d2e9f-b271-4485-a321-434f52a06570'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('dd1d2e9f-b271-4485-a321-434f52a06570', '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', 'D8B37817-4EB1-414C-9273-5977AB80DB63', 'TypeID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Meeting Agenda Item Types -> MJ_BizApps_Tasks: Meeting Agenda Items (One To Many via TypeID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'b258f534-56e8-48a0-b8b6-6cf4679087ae'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('b258f534-56e8-48a0-b8b6-6cf4679087ae', 'C625AAE9-906F-4056-90AC-C655886D3F69', '9C171F1D-86F9-4630-8548-1DC6163272CA', 'TypeID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: AI Prompt Runs -> MJ_BizApps_Tasks: Meeting Notes (One To Many via AIPromptRunID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'bdad18fa-85e2-4e82-bb2b-aa0ee8037cd1'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('bdad18fa-85e2-4e82-bb2b-aa0ee8037cd1', '7C1C98D0-3978-4CE8-8E3F-C90301E59767', '02892041-B070-475D-9486-5570486DDBEC', 'AIPromptRunID', 'One To Many', 1, 1, 11, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Meeting Agenda Items (One To Many via PresenterPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'e5080236-d5ef-4077-9425-e37553b9f4d9'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('e5080236-d5ef-4077-9425-e37553b9f4d9', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '9C171F1D-86F9-4630-8548-1DC6163272CA', 'PresenterPersonID', 'One To Many', 1, 1, 12, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Meeting Attendees (One To Many via PersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '54f1d0a0-58e5-49c4-a3c7-6041cc25a3f5'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('54f1d0a0-58e5-49c4-a3c7-6041cc25a3f5', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '87EF481F-8E24-4863-B5DE-1E31B17E89F3', 'PersonID', 'One To Many', 1, 1, 13, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Meeting Series (One To Many via OrganizerPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '905cef8f-2778-47b0-a327-b10644e63e10'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('905cef8f-2778-47b0-a327-b10644e63e10', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '02B53C81-832E-428A-8CE8-493189EE4B28', 'OrganizerPersonID', 'One To Many', 1, 1, 14, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Meeting Series (One To Many via CreatedByPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '429216e2-0828-4216-a848-3bb3e20968d7'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('429216e2-0828-4216-a848-3bb3e20968d7', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '02B53C81-832E-428A-8CE8-493189EE4B28', 'CreatedByPersonID', 'One To Many', 1, 1, 15, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Meeting Notes (One To Many via AuthorPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '8019e181-5f8f-4e85-94a7-685385564f6d'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('8019e181-5f8f-4e85-94a7-685385564f6d', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '02892041-B070-475D-9486-5570486DDBEC', 'AuthorPersonID', 'One To Many', 1, 1, 16, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Meetings (One To Many via OrganizerPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'd7c3fc46-8942-4a0c-8a41-3815fe5859b5'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('d7c3fc46-8942-4a0c-8a41-3815fe5859b5', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'D8B37817-4EB1-414C-9273-5977AB80DB63', 'OrganizerPersonID', 'One To Many', 1, 1, 17, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Meetings (One To Many via CreatedByPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '744f24b5-1132-4bcc-ab45-462d5049df2f'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('744f24b5-1132-4bcc-ab45-462d5049df2f', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'D8B37817-4EB1-414C-9273-5977AB80DB63', 'CreatedByPersonID', 'One To Many', 1, 1, 18, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Meeting Series Attendees (One To Many via PersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '8e256804-e565-495d-b510-601460797b04'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('8e256804-e565-495d-b510-601460797b04', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'E4283E35-10E3-41AC-AA30-D28890A55D62', 'PersonID', 'One To Many', 1, 1, 19, GETUTCDATE(), GETUTCDATE())
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

/* SQL text to update entity field related entity name field map for entity field ID 1F36C7FB-F776-4D69-9E39-021E3AA51D91 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='1F36C7FB-F776-4D69-9E39-021E3AA51D91', @RelatedEntityNameFieldMap='Meeting';

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

/* SQL text to update entity field related entity name field map for entity field ID 0E80D78D-2A5F-4C54-88AE-E18959DF40D6 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='0E80D78D-2A5F-4C54-88AE-E18959DF40D6', @RelatedEntityNameFieldMap='Meeting';

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

/* SQL text to update entity field related entity name field map for entity field ID D5566483-0FF3-4062-B3E9-1B49B4F31487 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='D5566483-0FF3-4062-B3E9-1B49B4F31487', @RelatedEntityNameFieldMap='Meeting';

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

/* SQL text to update entity field related entity name field map for entity field ID 8DB670A7-1316-4EEA-99B4-91D32AA896FF */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='8DB670A7-1316-4EEA-99B4-91D32AA896FF', @RelatedEntityNameFieldMap='Meeting';

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

/* SQL text to update entity field related entity name field map for entity field ID 5899CC1B-C4AC-44B6-97F4-7F7816FB6276 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='5899CC1B-C4AC-44B6-97F4-7F7816FB6276', @RelatedEntityNameFieldMap='Type';

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

/* SQL text to update entity field related entity name field map for entity field ID 9D7DC0DD-DED6-4EF1-AB1E-9E64B20BA454 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='9D7DC0DD-DED6-4EF1-AB1E-9E64B20BA454', @RelatedEntityNameFieldMap='Series';

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

/* SQL text to update entity field related entity name field map for entity field ID 62354BB6-0E02-41EE-97E7-F402FEBB9EED */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='62354BB6-0E02-41EE-97E7-F402FEBB9EED', @RelatedEntityNameFieldMap='DefaultVideoProvider';

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

/* SQL text to update entity field related entity name field map for entity field ID D5CB2596-C53E-411D-A198-8C71DBBF8745 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='D5CB2596-C53E-411D-A198-8C71DBBF8745', @RelatedEntityNameFieldMap='NotesPrompt';

/* SQL text to update entity field related entity name field map for entity field ID C729C24F-EDCB-4A72-AE37-C5B3399D1126 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='C729C24F-EDCB-4A72-AE37-C5B3399D1126', @RelatedEntityNameFieldMap='Person';

/* SQL text to update entity field related entity name field map for entity field ID 18E983F3-AEA7-455F-9553-ECF122CD946D */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='18E983F3-AEA7-455F-9553-ECF122CD946D', @RelatedEntityNameFieldMap='Series';

/* SQL text to update entity field related entity name field map for entity field ID 3B19AD0B-10CF-4248-8036-C185CEF7D16A */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='3B19AD0B-10CF-4248-8036-C185CEF7D16A', @RelatedEntityNameFieldMap='Parent';

/* SQL text to update entity field related entity name field map for entity field ID 0DD12734-CA7B-42E5-B658-B2BF2B210658 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='0DD12734-CA7B-42E5-B658-B2BF2B210658', @RelatedEntityNameFieldMap='AgendaItem';

/* SQL text to update entity field related entity name field map for entity field ID 73883756-7863-4284-8CBF-D406D435D7D1 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='73883756-7863-4284-8CBF-D406D435D7D1', @RelatedEntityNameFieldMap='Person';

/* SQL text to update entity field related entity name field map for entity field ID C3CE03E6-250D-4CB3-A6C1-9BA1F1FA3A68 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='C3CE03E6-250D-4CB3-A6C1-9BA1F1FA3A68', @RelatedEntityNameFieldMap='OrganizerPerson';

/* SQL text to update entity field related entity name field map for entity field ID 27389469-CC0E-4958-AF50-E3C7181545FE */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='27389469-CC0E-4958-AF50-E3C7181545FE', @RelatedEntityNameFieldMap='User';

/* SQL text to update entity field related entity name field map for entity field ID 251F26F7-3D9F-4B1A-AA82-66C121D54F1E */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='251F26F7-3D9F-4B1A-AA82-66C121D54F1E', @RelatedEntityNameFieldMap='User';

/* SQL text to update entity field related entity name field map for entity field ID CFB8D479-8D27-4C4D-A97D-02B3954E21A7 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='CFB8D479-8D27-4C4D-A97D-02B3954E21A7', @RelatedEntityNameFieldMap='VideoProvider';

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

/* SQL text to update entity field related entity name field map for entity field ID 65C28E8B-D16C-4F3F-A48E-02A18C5F18F7 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='65C28E8B-D16C-4F3F-A48E-02A18C5F18F7', @RelatedEntityNameFieldMap='Type';

/* SQL text to update entity field related entity name field map for entity field ID 2444DBA8-3236-4F5C-92C3-9FF53E182466 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='2444DBA8-3236-4F5C-92C3-9FF53E182466', @RelatedEntityNameFieldMap='Entity';

/* SQL text to update entity field related entity name field map for entity field ID 0278FEAE-9F92-43C6-AFBD-E19EF9712866 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='0278FEAE-9F92-43C6-AFBD-E19EF9712866', @RelatedEntityNameFieldMap='AuthorPerson';

/* SQL text to update entity field related entity name field map for entity field ID DE0E4D3F-A983-4D85-9C30-7D4A033B72AF */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='DE0E4D3F-A983-4D85-9C30-7D4A033B72AF', @RelatedEntityNameFieldMap='AIPromptRun';

/* SQL text to update entity field related entity name field map for entity field ID A62402CB-1548-41C0-BCEE-2602A6A23F44 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='A62402CB-1548-41C0-BCEE-2602A6A23F44', @RelatedEntityNameFieldMap='PresenterPerson';

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

/* SQL text to update entity field related entity name field map for entity field ID 099563E0-AEB7-4EEF-871E-9F2EB3B0CB38 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='099563E0-AEB7-4EEF-871E-9F2EB3B0CB38', @RelatedEntityNameFieldMap='CreatedByPerson';

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

/* SQL text to update entity field related entity name field map for entity field ID 467E00ED-F642-4F09-B316-FA6159F7392C */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='467E00ED-F642-4F09-B316-FA6159F7392C', @RelatedEntityNameFieldMap='DeferredToMeeting';

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

/* SQL text to update entity field related entity name field map for entity field ID E74A1A70-6545-48B6-939D-DCFF634C18E3 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='E74A1A70-6545-48B6-939D-DCFF634C18E3', @RelatedEntityNameFieldMap='Type';

/* SQL text to update entity field related entity name field map for entity field ID 15E79801-5CB1-463A-B7F3-DC95C99D58E8 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='15E79801-5CB1-463A-B7F3-DC95C99D58E8', @RelatedEntityNameFieldMap='Series';

/* SQL text to update entity field related entity name field map for entity field ID D9E32E66-93D9-4689-B94C-81886E712A85 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='D9E32E66-93D9-4689-B94C-81886E712A85', @RelatedEntityNameFieldMap='VideoProvider';

/* SQL text to update entity field related entity name field map for entity field ID 764C5E86-EC9E-4A51-BE4A-C9FB68BFF4AB */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='764C5E86-EC9E-4A51-BE4A-C9FB68BFF4AB', @RelatedEntityNameFieldMap='OrganizerPerson';

/* SQL text to update entity field related entity name field map for entity field ID A8457025-454C-4428-8C0C-BDC5AD82AF69 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='A8457025-454C-4428-8C0C-BDC5AD82AF69', @RelatedEntityNameFieldMap='TranscriptFile';

/* SQL text to update entity field related entity name field map for entity field ID 974D8B4D-A629-442F-B2ED-F257BED9A76D */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='974D8B4D-A629-442F-B2ED-F257BED9A76D', @RelatedEntityNameFieldMap='CreatedByPerson';

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

/* SQL text to update entity field related entity name field map for entity field ID 38C035DE-701C-4B03-920C-DBCFC6B753D3 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='38C035DE-701C-4B03-920C-DBCFC6B753D3', @RelatedEntityNameFieldMap='Credential';

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
EXEC [${mjSchema}].[spDeleteUnneededEntityFields] @ExcludedSchemaNames='', @EntityIDs='02892041-B070-475D-9486-5570486DDBEC,3418E742-27E0-4DF9-9030-84EE319851F2,79634853-B251-4DD5-B1D3-35001E4A0824,6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4,C625AAE9-906F-4056-90AC-C655886D3F69,02B53C81-832E-428A-8CE8-493189EE4B28,D8B37817-4EB1-414C-9273-5977AB80DB63,E4283E35-10E3-41AC-AA30-D28890A55D62,87EF481F-8E24-4863-B5DE-1E31B17E89F3,9C171F1D-86F9-4630-8548-1DC6163272CA', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to insert 31 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9c41e8ad-e946-4fc1-b545-1dc2e98548ac' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'Meeting')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9c41e8ad-e946-4fc1-b545-1dc2e98548ac',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '64755097-7318-441e-8b54-f4ec654d97ce' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'Parent')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '64755097-7318-441e-8b54-f4ec654d97ce',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '35a7a15f-0f13-45d5-9366-0db923cede00' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'Type')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '35a7a15f-0f13-45d5-9366-0db923cede00',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0cf03c65-cc8e-4c90-993b-746dc817ebdc' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'PresenterPerson')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0cf03c65-cc8e-4c90-993b-746dc817ebdc',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '342c57ed-f583-4cdf-a640-6d04b8df6c84' OR (EntityID = '9C171F1D-86F9-4630-8548-1DC6163272CA' AND Name = 'DeferredToMeeting')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '342c57ed-f583-4cdf-a640-6d04b8df6c84',
            '9C171F1D-86F9-4630-8548-1DC6163272CA', -- Entity: MJ_BizApps_Tasks: Meeting Agenda Items
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '9C171F1D-86F9-4630-8548-1DC6163272CA'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4171a010-ac8c-4f83-83f7-74acb197492f' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = 'Meeting')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4171a010-ac8c-4f83-83f7-74acb197492f',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e175a87d-672b-4bd9-b159-13e227c24762' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = 'Person')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e175a87d-672b-4bd9-b159-13e227c24762',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ce46b3c7-26ba-43be-82d1-d1ddef372a5c' OR (EntityID = '87EF481F-8E24-4863-B5DE-1E31B17E89F3' AND Name = 'User')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ce46b3c7-26ba-43be-82d1-d1ddef372a5c',
            '87EF481F-8E24-4863-B5DE-1E31B17E89F3', -- Entity: MJ_BizApps_Tasks: Meeting Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87EF481F-8E24-4863-B5DE-1E31B17E89F3'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '67a1fe90-9f17-45b6-a8e5-c04cf59d7ef0' OR (EntityID = '79634853-B251-4DD5-B1D3-35001E4A0824' AND Name = 'Credential')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '67a1fe90-9f17-45b6-a8e5-c04cf59d7ef0',
            '79634853-B251-4DD5-B1D3-35001E4A0824', -- Entity: MJ_BizApps_Tasks: Video Providers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '79634853-B251-4DD5-B1D3-35001E4A0824'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '87f9ac17-db9e-4dcf-9400-4c0bd0164254' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'Type')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '87f9ac17-db9e-4dcf-9400-4c0bd0164254',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd2ee0f25-25e4-402e-9152-1a340bc15249' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'OrganizerPerson')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd2ee0f25-25e4-402e-9152-1a340bc15249',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '89828649-563d-43db-86bf-bd27498f71de' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'VideoProvider')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '89828649-563d-43db-86bf-bd27498f71de',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a4be76ac-3675-4707-b89a-2ebf761ff1c5' OR (EntityID = '02B53C81-832E-428A-8CE8-493189EE4B28' AND Name = 'CreatedByPerson')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a4be76ac-3675-4707-b89a-2ebf761ff1c5',
            '02B53C81-832E-428A-8CE8-493189EE4B28', -- Entity: MJ_BizApps_Tasks: Meeting Series
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02B53C81-832E-428A-8CE8-493189EE4B28'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6bbb880a-b371-4b44-9b42-be27a3d1927c' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = 'Meeting')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6bbb880a-b371-4b44-9b42-be27a3d1927c',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ae16acfd-31fc-4de9-bbd8-2ba1e12016ce' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = 'AgendaItem')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ae16acfd-31fc-4de9-bbd8-2ba1e12016ce',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '53afa1bb-510d-44c9-8923-cdec96e66d1d' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = 'AuthorPerson')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '53afa1bb-510d-44c9-8923-cdec96e66d1d',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'bc55fce9-4c05-418d-b27c-3197817e87d3' OR (EntityID = '02892041-B070-475D-9486-5570486DDBEC' AND Name = 'AIPromptRun')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'bc55fce9-4c05-418d-b27c-3197817e87d3',
            '02892041-B070-475D-9486-5570486DDBEC', -- Entity: MJ_BizApps_Tasks: Meeting Notes
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02892041-B070-475D-9486-5570486DDBEC'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a087bb60-9fd7-459a-adf5-fe561edbd3d9' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'Type')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a087bb60-9fd7-459a-adf5-fe561edbd3d9',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c482e31c-933b-4872-b477-856c455d972d' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'Series')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c482e31c-933b-4872-b477-856c455d972d',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a5e4a0c4-9e36-47f4-8a89-06b884230155' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'VideoProvider')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a5e4a0c4-9e36-47f4-8a89-06b884230155',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ce434287-b464-4dd0-80f5-9f1998b0fdad' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'OrganizerPerson')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ce434287-b464-4dd0-80f5-9f1998b0fdad',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6755105d-7000-484a-9aed-da0ec8516ac8' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'TranscriptFile')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6755105d-7000-484a-9aed-da0ec8516ac8',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b369c99a-d16c-401d-a3e3-a54a5faa753e' OR (EntityID = 'D8B37817-4EB1-414C-9273-5977AB80DB63' AND Name = 'CreatedByPerson')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b369c99a-d16c-401d-a3e3-a54a5faa753e',
            'D8B37817-4EB1-414C-9273-5977AB80DB63', -- Entity: MJ_BizApps_Tasks: Meetings
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D8B37817-4EB1-414C-9273-5977AB80DB63'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f5f88a06-e59a-401c-8df3-c9d973455534' OR (EntityID = '3418E742-27E0-4DF9-9030-84EE319851F2' AND Name = 'Meeting')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f5f88a06-e59a-401c-8df3-c9d973455534',
            '3418E742-27E0-4DF9-9030-84EE319851F2', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '3418E742-27E0-4DF9-9030-84EE319851F2'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b24f350c-0b14-4fcf-9904-ce70c1c0732d' OR (EntityID = '3418E742-27E0-4DF9-9030-84EE319851F2' AND Name = 'Series')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b24f350c-0b14-4fcf-9904-ce70c1c0732d',
            '3418E742-27E0-4DF9-9030-84EE319851F2', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '3418E742-27E0-4DF9-9030-84EE319851F2'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e82cc849-432e-47b9-91dd-c270f90bcfc5' OR (EntityID = '3418E742-27E0-4DF9-9030-84EE319851F2' AND Name = 'Entity')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e82cc849-432e-47b9-91dd-c270f90bcfc5',
            '3418E742-27E0-4DF9-9030-84EE319851F2', -- Entity: MJ_BizApps_Tasks: Meeting Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '3418E742-27E0-4DF9-9030-84EE319851F2'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5ede6a9b-78c2-469f-be4a-79ab3fef41e5' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = 'DefaultVideoProvider')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5ede6a9b-78c2-469f-be4a-79ab3fef41e5',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '82f265ad-84b4-483c-b028-0f8fe2b4869b' OR (EntityID = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4' AND Name = 'NotesPrompt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '82f265ad-84b4-483c-b028-0f8fe2b4869b',
            '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4', -- Entity: MJ_BizApps_Tasks: Meeting Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ef125d1b-4d31-4c2d-8174-33c795820bd1' OR (EntityID = 'E4283E35-10E3-41AC-AA30-D28890A55D62' AND Name = 'Series')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ef125d1b-4d31-4c2d-8174-33c795820bd1',
            'E4283E35-10E3-41AC-AA30-D28890A55D62', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E4283E35-10E3-41AC-AA30-D28890A55D62'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '16a00b4d-5abc-4644-8588-f02dcf5c353e' OR (EntityID = 'E4283E35-10E3-41AC-AA30-D28890A55D62' AND Name = 'Person')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '16a00b4d-5abc-4644-8588-f02dcf5c353e',
            'E4283E35-10E3-41AC-AA30-D28890A55D62', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E4283E35-10E3-41AC-AA30-D28890A55D62'),
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

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9a145dfa-0f78-4609-b414-5450cf6f2a0f' OR (EntityID = 'E4283E35-10E3-41AC-AA30-D28890A55D62' AND Name = 'User')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9a145dfa-0f78-4609-b414-5450cf6f2a0f',
            'E4283E35-10E3-41AC-AA30-D28890A55D62', -- Entity: MJ_BizApps_Tasks: Meeting Series Attendees
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'E4283E35-10E3-41AC-AA30-D28890A55D62'),
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

/* SQL text to update existing entity fields from schema (10 scoped entities) */
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='', @EntityIDs='02892041-B070-475D-9486-5570486DDBEC,3418E742-27E0-4DF9-9030-84EE319851F2,79634853-B251-4DD5-B1D3-35001E4A0824,6AAF3FEB-AC7F-4B1A-AC08-A9AA43AE5AA4,C625AAE9-906F-4056-90AC-C655886D3F69,02B53C81-832E-428A-8CE8-493189EE4B28,D8B37817-4EB1-414C-9273-5977AB80DB63,E4283E35-10E3-41AC-AA30-D28890A55D62,87EF481F-8E24-4863-B5DE-1E31B17E89F3,9C171F1D-86F9-4630-8548-1DC6163272CA', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

