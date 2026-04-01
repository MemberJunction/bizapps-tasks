-- Fix SchemaInfo: set EntityNamePrefix so future CodeGen runs apply the prefix.
-- Also rename existing entities that were created without the prefix.

GO

-- 1. Update SchemaInfo with the correct prefix and description
UPDATE __mj.SchemaInfo
SET EntityNamePrefix = 'MJ.BizApps.Tasks:',
    Description = 'Reusable task management for MemberJunction business applications'
WHERE SchemaName = '__mj_BizAppsTasks';
GO

-- 2. Rename existing entities to include the prefix
UPDATE __mj.Entity SET Name = 'MJ.BizApps.Tasks: Tasks'                          WHERE SchemaName = '__mj_BizAppsTasks' AND Name = 'Tasks';
UPDATE __mj.Entity SET Name = 'MJ.BizApps.Tasks: Task Types'                     WHERE SchemaName = '__mj_BizAppsTasks' AND Name = 'Task Types';
UPDATE __mj.Entity SET Name = 'MJ.BizApps.Tasks: Task Categories'                WHERE SchemaName = '__mj_BizAppsTasks' AND Name = 'Task Categories';
UPDATE __mj.Entity SET Name = 'MJ.BizApps.Tasks: Task Roles'                     WHERE SchemaName = '__mj_BizAppsTasks' AND Name = 'Task Roles';
UPDATE __mj.Entity SET Name = 'MJ.BizApps.Tasks: Task Assignments'               WHERE SchemaName = '__mj_BizAppsTasks' AND Name = 'Task Assignments';
UPDATE __mj.Entity SET Name = 'MJ.BizApps.Tasks: Task Links'                     WHERE SchemaName = '__mj_BizAppsTasks' AND Name = 'Task Links';
UPDATE __mj.Entity SET Name = 'MJ.BizApps.Tasks: Task Dependencies'              WHERE SchemaName = '__mj_BizAppsTasks' AND Name = 'Task Dependencies';
UPDATE __mj.Entity SET Name = 'MJ.BizApps.Tasks: Task Tags'                      WHERE SchemaName = '__mj_BizAppsTasks' AND Name = 'Task Tags';
UPDATE __mj.Entity SET Name = 'MJ.BizApps.Tasks: Task Tag Links'                 WHERE SchemaName = '__mj_BizAppsTasks' AND Name = 'Task Tag Links';
UPDATE __mj.Entity SET Name = 'MJ.BizApps.Tasks: Task Comments'                  WHERE SchemaName = '__mj_BizAppsTasks' AND Name = 'Task Comments';
UPDATE __mj.Entity SET Name = 'MJ.BizApps.Tasks: Task Templates'                 WHERE SchemaName = '__mj_BizAppsTasks' AND Name = 'Task Templates';
UPDATE __mj.Entity SET Name = 'MJ.BizApps.Tasks: Task Template Items'            WHERE SchemaName = '__mj_BizAppsTasks' AND Name = 'Task Template Items';
UPDATE __mj.Entity SET Name = 'MJ.BizApps.Tasks: Task Template Item Dependencies' WHERE SchemaName = '__mj_BizAppsTasks' AND Name = 'Task Template Item Dependencies';
UPDATE __mj.Entity SET Name = 'MJ.BizApps.Tasks: Task Template Item Roles'       WHERE SchemaName = '__mj_BizAppsTasks' AND Name = 'Task Template Item Roles';
UPDATE __mj.Entity SET Name = 'MJ.BizApps.Tasks: Task Activities'                WHERE SchemaName = '__mj_BizAppsTasks' AND Name = 'Task Activities';
GO
