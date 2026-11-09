-- Teardown for the Work Reports Chief of Staff extension (run by `mj app remove` with the app's data).
-- Retires the rows this app wrote into the shared core schema: the "Work reports" skill with its
-- Chief of Staff agent grant and dependent references, the NavItem.bizapps-tasks.work-reports
-- setting that adds the Reports page to the Chief of Staff application, and the Work Report actions.

UPDATE [${mjSchema}].[SearchExecutionLog] SET [AISkillID] = NULL WHERE [AISkillID] = '6D4B8E21-9A3C-4F58-B712-4E8C1A9D3B20';
DELETE FROM [${mjSchema}].[ConversationSkill] WHERE [SkillID] = '6D4B8E21-9A3C-4F58-B712-4E8C1A9D3B20';
DELETE FROM [${mjSchema}].[AISkillPermission] WHERE [SkillID] = '6D4B8E21-9A3C-4F58-B712-4E8C1A9D3B20';
DELETE FROM [${mjSchema}].[AISkillSearchScope] WHERE [SkillID] = '6D4B8E21-9A3C-4F58-B712-4E8C1A9D3B20';
DELETE FROM [${mjSchema}].[AISkillSubAgent] WHERE [SkillID] = '6D4B8E21-9A3C-4F58-B712-4E8C1A9D3B20';
DELETE FROM [${mjSchema}].[AISkillAction] WHERE [SkillID] = '6D4B8E21-9A3C-4F58-B712-4E8C1A9D3B20';
DELETE FROM [${mjSchema}].[AIAgentSkill] WHERE [SkillID] = '6D4B8E21-9A3C-4F58-B712-4E8C1A9D3B20';
DELETE FROM [${mjSchema}].[AISkill] WHERE [ID] = '6D4B8E21-9A3C-4F58-B712-4E8C1A9D3B20';

DELETE FROM [${mjSchema}].[ApplicationSetting] WHERE [ID] = 'B4E91D72-5C3A-4E81-9F60-2A7D4C8E1B39';

DELETE FROM [${mjSchema}].[ActionResultCode] WHERE [ActionID] IN ('2B8E4A61-7C1D-4F39-8E24-9A1C5D7B3E40', 'C528E40B-76B7-43D9-88CE-94B6F715D8EA', '2B8E4A61-DC1D-493F-8E24-FA1C5D7B3E40');
DELETE FROM [${mjSchema}].[ActionParam] WHERE [ActionID] IN ('2B8E4A61-7C1D-4F39-8E24-9A1C5D7B3E40', 'C528E40B-76B7-43D9-88CE-94B6F715D8EA', '2B8E4A61-DC1D-493F-8E24-FA1C5D7B3E40');
DELETE FROM [${mjSchema}].[Action] WHERE [ID] IN ('2B8E4A61-7C1D-4F39-8E24-9A1C5D7B3E40', 'C528E40B-76B7-43D9-88CE-94B6F715D8EA', '2B8E4A61-DC1D-493F-8E24-FA1C5D7B3E40');
