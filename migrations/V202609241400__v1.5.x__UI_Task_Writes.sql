-- The UI role stays read-only on every tasks entity, then receives only the
-- writes the panels make:
--   create and update: Tasks, Task Comments, Task Assignments
--   create: Task Tag Links, Task Tags, Task Roles, Task Decisions, Task Activities
--   delete: Task Assignments, Task Tag Links
-- Task Activities are created by the task server class as the saving user, so
-- UI needs create there and not update. Task delete stays refused. The catalog,
-- notification configs, and notification logs stay read-only.

DECLARE @UI uniqueidentifier = 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E';

UPDATE p
SET p.CanCreate = 0,
    p.CanUpdate = 0,
    p.CanDelete = 0,
    p.__mj_UpdatedAt = GETUTCDATE()
FROM [${mjSchema}].[EntityPermission] AS p
INNER JOIN [${mjSchema}].[Entity] AS e ON e.ID = p.EntityID
WHERE p.RoleID = @UI
  AND e.Name LIKE N'MJ_BizApps_Tasks:%';

UPDATE p
SET p.CanCreate = v.CanCreate,
    p.CanUpdate = v.CanUpdate,
    p.CanDelete = v.CanDelete,
    p.__mj_UpdatedAt = GETUTCDATE()
FROM [${mjSchema}].[EntityPermission] AS p
INNER JOIN [${mjSchema}].[Entity] AS e ON e.ID = p.EntityID
INNER JOIN (VALUES
    (N'MJ_BizApps_Tasks: Tasks', 1, 1, 0),
    (N'MJ_BizApps_Tasks: Task Comments', 1, 1, 0),
    (N'MJ_BizApps_Tasks: Task Assignments', 1, 1, 1),
    (N'MJ_BizApps_Tasks: Task Tag Links', 1, 0, 1),
    (N'MJ_BizApps_Tasks: Task Tags', 1, 0, 0),
    (N'MJ_BizApps_Tasks: Task Roles', 1, 0, 0),
    (N'MJ_BizApps_Tasks: Task Decisions', 1, 0, 0),
    (N'MJ_BizApps_Tasks: Task Activities', 1, 0, 0)
) AS v(Name, CanCreate, CanUpdate, CanDelete) ON v.Name = e.Name
WHERE p.RoleID = @UI;

IF EXISTS (
    SELECT 1
    FROM [${mjSchema}].[EntityPermission] AS p
    INNER JOIN [${mjSchema}].[Entity] AS e ON e.ID = p.EntityID
    WHERE p.RoleID = @UI
      AND e.Name LIKE N'MJ_BizApps_Tasks:%'
      AND NOT (
          (e.Name = N'MJ_BizApps_Tasks: Tasks' AND p.CanRead = 1 AND p.CanCreate = 1 AND p.CanUpdate = 1 AND p.CanDelete = 0)
          OR (e.Name = N'MJ_BizApps_Tasks: Task Comments' AND p.CanRead = 1 AND p.CanCreate = 1 AND p.CanUpdate = 1 AND p.CanDelete = 0)
          OR (e.Name = N'MJ_BizApps_Tasks: Task Assignments' AND p.CanRead = 1 AND p.CanCreate = 1 AND p.CanUpdate = 1 AND p.CanDelete = 1)
          OR (e.Name = N'MJ_BizApps_Tasks: Task Tag Links' AND p.CanRead = 1 AND p.CanCreate = 1 AND p.CanUpdate = 0 AND p.CanDelete = 1)
          OR (e.Name = N'MJ_BizApps_Tasks: Task Tags' AND p.CanRead = 1 AND p.CanCreate = 1 AND p.CanUpdate = 0 AND p.CanDelete = 0)
          OR (e.Name = N'MJ_BizApps_Tasks: Task Roles' AND p.CanRead = 1 AND p.CanCreate = 1 AND p.CanUpdate = 0 AND p.CanDelete = 0)
          OR (e.Name = N'MJ_BizApps_Tasks: Task Decisions' AND p.CanRead = 1 AND p.CanCreate = 1 AND p.CanUpdate = 0 AND p.CanDelete = 0)
          OR (e.Name = N'MJ_BizApps_Tasks: Task Activities' AND p.CanRead = 1 AND p.CanCreate = 1 AND p.CanUpdate = 0 AND p.CanDelete = 0)
          OR (e.Name NOT IN (
              N'MJ_BizApps_Tasks: Tasks',
              N'MJ_BizApps_Tasks: Task Comments',
              N'MJ_BizApps_Tasks: Task Assignments',
              N'MJ_BizApps_Tasks: Task Tag Links',
              N'MJ_BizApps_Tasks: Task Tags',
              N'MJ_BizApps_Tasks: Task Roles',
              N'MJ_BizApps_Tasks: Task Decisions',
              N'MJ_BizApps_Tasks: Task Activities'
          ) AND p.CanRead = 1 AND p.CanCreate = 0 AND p.CanUpdate = 0 AND p.CanDelete = 0)
      )
)
    THROW 50000, 'A UI tasks grant is outside the panel list.', 1;

IF (
    SELECT COUNT(DISTINCT e.Name)
    FROM [${mjSchema}].[EntityPermission] AS p
    INNER JOIN [${mjSchema}].[Entity] AS e ON e.ID = p.EntityID
    WHERE p.RoleID = @UI
      AND (
          (e.Name = N'MJ_BizApps_Tasks: Tasks' AND p.CanRead = 1 AND p.CanCreate = 1 AND p.CanUpdate = 1 AND p.CanDelete = 0)
          OR (e.Name = N'MJ_BizApps_Tasks: Task Comments' AND p.CanRead = 1 AND p.CanCreate = 1 AND p.CanUpdate = 1 AND p.CanDelete = 0)
          OR (e.Name = N'MJ_BizApps_Tasks: Task Assignments' AND p.CanRead = 1 AND p.CanCreate = 1 AND p.CanUpdate = 1 AND p.CanDelete = 1)
          OR (e.Name = N'MJ_BizApps_Tasks: Task Tag Links' AND p.CanRead = 1 AND p.CanCreate = 1 AND p.CanUpdate = 0 AND p.CanDelete = 1)
          OR (e.Name = N'MJ_BizApps_Tasks: Task Tags' AND p.CanRead = 1 AND p.CanCreate = 1 AND p.CanUpdate = 0 AND p.CanDelete = 0)
          OR (e.Name = N'MJ_BizApps_Tasks: Task Roles' AND p.CanRead = 1 AND p.CanCreate = 1 AND p.CanUpdate = 0 AND p.CanDelete = 0)
          OR (e.Name = N'MJ_BizApps_Tasks: Task Decisions' AND p.CanRead = 1 AND p.CanCreate = 1 AND p.CanUpdate = 0 AND p.CanDelete = 0)
          OR (e.Name = N'MJ_BizApps_Tasks: Task Activities' AND p.CanRead = 1 AND p.CanCreate = 1 AND p.CanUpdate = 0 AND p.CanDelete = 0)
      )
) <> 8
    THROW 50000, 'UI is missing one of the eight panel grants.', 1;
GO
