-- The UI role can already read every tasks entity. It can now create and
-- update them, which is what a staff user needs to change a status, comment,
-- assign, and add a subtask. The edit panel removes an assignee, a tag link,
-- a dependency, or a task link with Delete(), so those four also allow delete.
-- Catalog rows (types, roles, tags, templates) stay non-deletable.

DECLARE @UI uniqueidentifier = 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E';

UPDATE p
SET p.CanCreate = 1,
    p.CanUpdate = 1,
    p.__mj_UpdatedAt = GETUTCDATE()
FROM [${mjSchema}].[EntityPermission] AS p
INNER JOIN [${mjSchema}].[Entity] AS e ON e.ID = p.EntityID
WHERE p.RoleID = @UI
  AND e.Name LIKE N'MJ_BizApps_Tasks:%';

UPDATE p
SET p.CanDelete = 1,
    p.__mj_UpdatedAt = GETUTCDATE()
FROM [${mjSchema}].[EntityPermission] AS p
INNER JOIN [${mjSchema}].[Entity] AS e ON e.ID = p.EntityID
WHERE p.RoleID = @UI
  AND e.Name IN (
      N'MJ_BizApps_Tasks: Task Assignments',
      N'MJ_BizApps_Tasks: Task Tag Links',
      N'MJ_BizApps_Tasks: Task Dependencies',
      N'MJ_BizApps_Tasks: Task Links'
  );

IF NOT EXISTS (
    SELECT 1
    FROM [${mjSchema}].[EntityPermission] AS p
    INNER JOIN [${mjSchema}].[Entity] AS e ON e.ID = p.EntityID
    WHERE p.RoleID = @UI
      AND e.Name = N'MJ_BizApps_Tasks: Tasks'
      AND p.CanRead = 1
      AND p.CanCreate = 1
      AND p.CanUpdate = 1
)
    THROW 50000, 'UI is missing create and update on Tasks.', 1;

IF (
    SELECT COUNT(*)
    FROM [${mjSchema}].[EntityPermission] AS p
    INNER JOIN [${mjSchema}].[Entity] AS e ON e.ID = p.EntityID
    WHERE p.RoleID = @UI
      AND p.CanDelete = 1
      AND e.Name IN (
          N'MJ_BizApps_Tasks: Task Assignments',
          N'MJ_BizApps_Tasks: Task Tag Links',
          N'MJ_BizApps_Tasks: Task Dependencies',
          N'MJ_BizApps_Tasks: Task Links'
      )
) <> 4
    THROW 50000, 'UI is missing delete on an assignment, tag link, dependency, or link.', 1;
GO
