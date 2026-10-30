-- Teardown for the Chief of Staff extension (run by `mj app remove` with the app's data).
-- Retires the rows this app wrote into the shared core schema: the
-- "Chief of Staff Tasks & Priorities" skill with its agent grant and everything that references
-- it, and the NavItem.* setting that adds the Priorities & To-dos page to the Chief of Staff app.
-- Rows are matched by their metadata primary keys (metadata/chief-of-staff-skills and
-- metadata/chief-of-staff-nav-items). ${mjSchema} resolves to the core schema.

-- Usage history keeps the log row and drops the link.
UPDATE "${mjSchema}"."SearchExecutionLog" SET "AISkillID" = NULL WHERE "AISkillID" = '05ED981A-4F9A-4B78-A5E9-9B383823F43C';
DELETE FROM "${mjSchema}"."ConversationSkill" WHERE "SkillID" = '05ED981A-4F9A-4B78-A5E9-9B383823F43C';
DELETE FROM "${mjSchema}"."AISkillPermission" WHERE "SkillID" = '05ED981A-4F9A-4B78-A5E9-9B383823F43C';
DELETE FROM "${mjSchema}"."AISkillSearchScope" WHERE "SkillID" = '05ED981A-4F9A-4B78-A5E9-9B383823F43C';
DELETE FROM "${mjSchema}"."AISkillSubAgent" WHERE "SkillID" = '05ED981A-4F9A-4B78-A5E9-9B383823F43C';
DELETE FROM "${mjSchema}"."AISkillAction" WHERE "SkillID" = '05ED981A-4F9A-4B78-A5E9-9B383823F43C';
DELETE FROM "${mjSchema}"."AIAgentSkill" WHERE "SkillID" = '05ED981A-4F9A-4B78-A5E9-9B383823F43C';
DELETE FROM "${mjSchema}"."AISkill" WHERE "ID" = '05ED981A-4F9A-4B78-A5E9-9B383823F43C';

-- The page this app adds to the Chief of Staff application.
DELETE FROM "${mjSchema}"."ApplicationSetting" WHERE "ID" = 'F7408CCE-B0BB-4DAF-8797-9E2DFD4D73BC';
