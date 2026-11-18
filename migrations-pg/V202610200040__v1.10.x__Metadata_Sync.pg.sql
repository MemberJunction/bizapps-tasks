-- =============================================================================================
-- PostgreSQL counterpart of V202610200040__v1.10.x__Metadata_Sync.sql -- BizApps Tasks v1.10.x Metadata_Sync
-- =============================================================================================
-- Same records, same values, same order as the T-SQL file; see its header for what ships and why.
--
-- HOW IT WAS MADE
--   * `mj sql-convert --from tsql --to postgres` (MJ CLI 6.1.6) on the push log the T-SQL file
--     was generated from. Each record is a DO block that calls the core or app function, in
--     whichever signature the host has (jsonb or named parameters).
--   * The converter does not translate the guards the T-SQL file adds, so they are written here
--     by hand from the T-SQL ones: IF <guard> EXEC ... becomes IF <guard> THEN <call> END IF.
--   * String values match the T-SQL file verbatim.
--   * Core calls use ${mjSchema}; this app's schema is written as the converter emits it.
-- =============================================================================================

SET standard_conforming_strings = on;

-- Save MJ: Application Settings (core SP call only)
DO $mj$
DECLARE
  p_ID_792f17ed8c91 UUID;
  p_ApplicationID_792f17ed8c91 UUID;
  p_Name_792f17ed8c91 VARCHAR(100);
  p_Value_792f17ed8c91 TEXT;
  p_Comments_792f17ed8c91 TEXT;
BEGIN
  p_ID_792f17ed8c91 := '03CB418F-59E6-4838-9DA7-5646502D3D79';
  p_ApplicationID_792f17ed8c91 := '22541055-8ED4-4850-8ACD-E5EE1887B15B';
  p_Name_792f17ed8c91 := 'PreventSelfApproval';
  p_Value_792f17ed8c91 := 'false';
  p_Comments_792f17ed8c91 := 'When true, a decision on an approval task (a task whose type has IsApproval set) is accepted only from one of the task''s assignees, recorded as that assignee''s own decision, and never from the person who created the task (bc-aidp-next-golive#320). Checked on the server for every path that records a decision: the approval panel, the Tasks inbox and other apps'' server code. False, the default, accepts every decision as before.';
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ApplicationSetting" WHERE "ID" = p_ID_792f17ed8c91 OR ("ApplicationID" = p_ApplicationID_792f17ed8c91 AND "Name" = p_Name_792f17ed8c91)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateApplicationSetting'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateApplicationSetting"(p_data := jsonb_build_object(
      'ID', p_ID_792f17ed8c91,
      'ApplicationID', p_ApplicationID_792f17ed8c91,
      'Name', p_Name_792f17ed8c91,
      'Value', p_Value_792f17ed8c91,
      'Comments', p_Comments_792f17ed8c91
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateApplicationSetting"(p_ID := p_ID_792f17ed8c91, p_ApplicationID := p_ApplicationID_792f17ed8c91, p_Name := p_Name_792f17ed8c91, p_Value := p_Value_792f17ed8c91, p_Comments := p_Comments_792f17ed8c91);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Application Settings (core SP call only)
DO $mj$
DECLARE
  p_ID_d6aeb744928f UUID;
  p_ApplicationID_d6aeb744928f UUID;
  p_Name_d6aeb744928f VARCHAR(100);
  p_Value_d6aeb744928f TEXT;
  p_Comments_d6aeb744928f TEXT;
BEGIN
  p_ID_d6aeb744928f := '17CC9998-9382-447B-A7DF-682A06837953';
  p_ApplicationID_d6aeb744928f := '22541055-8ED4-4850-8ACD-E5EE1887B15B';
  p_Name_d6aeb744928f := 'SelfApprovalExemptRole';
  p_Value_d6aeb744928f := '';
  p_Comments_d6aeb744928f := 'The NAME of the MJ role whose holders may decide an approval task they created themselves while PreventSelfApproval is true. They must still be one of its assignees. Empty exempts nobody. A name that is not a role exempts nobody and is logged.';
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ApplicationSetting" WHERE "ID" = p_ID_d6aeb744928f OR ("ApplicationID" = p_ApplicationID_d6aeb744928f AND "Name" = p_Name_d6aeb744928f)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateApplicationSetting'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateApplicationSetting"(p_data := jsonb_build_object(
      'ID', p_ID_d6aeb744928f,
      'ApplicationID', p_ApplicationID_d6aeb744928f,
      'Name', p_Name_d6aeb744928f,
      'Value', p_Value_d6aeb744928f,
      'Comments', p_Comments_d6aeb744928f
    ));
    ELSE
      PERFORM "${mjSchema}"."spCreateApplicationSetting"(p_ID := p_ID_d6aeb744928f, p_ApplicationID := p_ApplicationID_d6aeb744928f, p_Name := p_Name_d6aeb744928f, p_Value := p_Value_d6aeb744928f, p_Comments := p_Comments_d6aeb744928f);
    END IF;
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Task Types (core SP call only)
DO $mj$
DECLARE
  p_ID_86fb1a7c5e5a UUID;
  p_Name_86fb1a7c5e5a VARCHAR(100);
  p_Description_86fb1a7c5e5a TEXT;
  p_IconClass_86fb1a7c5e5a VARCHAR(100);
  p_DefaultPriority_86fb1a7c5e5a VARCHAR(20);
  p_OnAssignActionID_86fb1a7c5e5a UUID;
  p_OnCompleteActionID_86fb1a7c5e5a UUID;
  p_OnOverdueActionID_86fb1a7c5e5a UUID;
  p_OnPercentChangeActionID_86fb1a7c5e5a UUID;
  p_IsActive_86fb1a7c5e5a BOOLEAN;
  p_OnRejectActionID_86fb1a7c5e5a UUID;
  p_OnCancelActionID_86fb1a7c5e5a UUID;
  p_Code_86fb1a7c5e5a VARCHAR(50);
  p_OnCreateActionID_86fb1a7c5e5a UUID;
  p_OnStatusChangeActionID_86fb1a7c5e5a UUID;
  p_IsApproval_86fb1a7c5e5a BOOLEAN;
BEGIN
  p_ID_86fb1a7c5e5a := '8D42A1B9-3E71-4C5A-9F20-1B6E8D3A9C01';
  p_Name_86fb1a7c5e5a := 'Priority Objective';
  p_Description_86fb1a7c5e5a := 'Strategic quarterly or annual priority objective (OKR parent) tracked by the user and their Chief of Staff agent';
  p_IconClass_86fb1a7c5e5a := 'fa-solid fa-bullseye';
  p_DefaultPriority_86fb1a7c5e5a := 'High';
  p_IsActive_86fb1a7c5e5a := TRUE;
  p_Code_86fb1a7c5e5a := 'PRIORITY_OBJECTIVE';
  p_IsApproval_86fb1a7c5e5a := FALSE;
  IF NOT EXISTS (SELECT 1 FROM __mj_bizappstasks."TaskType" WHERE "ID" = p_ID_86fb1a7c5e5a OR "Name" = p_Name_86fb1a7c5e5a OR "Code" = p_Code_86fb1a7c5e5a) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '__mj_BizAppsTasks' AND p.proname = 'spCreateTaskType'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM __mj_BizAppsTasks."spCreateTaskType"(p_data := jsonb_build_object(
      'ID', p_ID_86fb1a7c5e5a,
      'Name', p_Name_86fb1a7c5e5a,
      'Description', p_Description_86fb1a7c5e5a,
      'IconClass', p_IconClass_86fb1a7c5e5a,
      'DefaultPriority', p_DefaultPriority_86fb1a7c5e5a,
      'OnAssignActionID', p_OnAssignActionID_86fb1a7c5e5a,
      'OnCompleteActionID', p_OnCompleteActionID_86fb1a7c5e5a,
      'OnOverdueActionID', p_OnOverdueActionID_86fb1a7c5e5a,
      'OnPercentChangeActionID', p_OnPercentChangeActionID_86fb1a7c5e5a,
      'IsActive', p_IsActive_86fb1a7c5e5a,
      'OnRejectActionID', p_OnRejectActionID_86fb1a7c5e5a,
      'OnCancelActionID', p_OnCancelActionID_86fb1a7c5e5a,
      'Code', p_Code_86fb1a7c5e5a,
      'OnCreateActionID', p_OnCreateActionID_86fb1a7c5e5a,
      'OnStatusChangeActionID', p_OnStatusChangeActionID_86fb1a7c5e5a,
      'IsApproval', p_IsApproval_86fb1a7c5e5a
    ));
    ELSE
      PERFORM __mj_BizAppsTasks."spCreateTaskType"(p_ID := p_ID_86fb1a7c5e5a, p_Name := p_Name_86fb1a7c5e5a, p_Description := p_Description_86fb1a7c5e5a, p_IconClass := p_IconClass_86fb1a7c5e5a, p_DefaultPriority := p_DefaultPriority_86fb1a7c5e5a, p_OnAssignActionID := p_OnAssignActionID_86fb1a7c5e5a, p_OnAssignActionID_Clear := TRUE, p_OnCompleteActionID := p_OnCompleteActionID_86fb1a7c5e5a, p_OnCompleteActionID_Clear := TRUE, p_OnOverdueActionID := p_OnOverdueActionID_86fb1a7c5e5a, p_OnOverdueActionID_Clear := TRUE, p_OnPercentChangeActionID := p_OnPercentChangeActionID_86fb1a7c5e5a, p_OnPercentChangeActionID_Clear := TRUE, p_IsActive := p_IsActive_86fb1a7c5e5a, p_OnRejectActionID := p_OnRejectActionID_86fb1a7c5e5a, p_OnRejectActionID_Clear := TRUE, p_OnCancelActionID := p_OnCancelActionID_86fb1a7c5e5a, p_OnCancelActionID_Clear := TRUE, p_Code := p_Code_86fb1a7c5e5a, p_OnCreateActionID := p_OnCreateActionID_86fb1a7c5e5a, p_OnCreateActionID_Clear := TRUE, p_OnStatusChangeActionID := p_OnStatusChangeActionID_86fb1a7c5e5a, p_OnStatusChangeActionID_Clear := TRUE, p_IsApproval := p_IsApproval_86fb1a7c5e5a);
    END IF;
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Task Types (core SP call only)
DO $mj$
DECLARE
  p_ID_6e4075a46159 UUID;
  p_Name_6e4075a46159 VARCHAR(100);
  p_Description_6e4075a46159 TEXT;
  p_IconClass_6e4075a46159 VARCHAR(100);
  p_DefaultPriority_6e4075a46159 VARCHAR(20);
  p_OnAssignActionID_6e4075a46159 UUID;
  p_OnCompleteActionID_6e4075a46159 UUID;
  p_OnOverdueActionID_6e4075a46159 UUID;
  p_OnPercentChangeActionID_6e4075a46159 UUID;
  p_IsActive_6e4075a46159 BOOLEAN;
  p_OnRejectActionID_6e4075a46159 UUID;
  p_OnCancelActionID_6e4075a46159 UUID;
  p_Code_6e4075a46159 VARCHAR(50);
  p_OnCreateActionID_6e4075a46159 UUID;
  p_OnStatusChangeActionID_6e4075a46159 UUID;
  p_IsApproval_6e4075a46159 BOOLEAN;
BEGIN
  p_ID_6e4075a46159 := '8D42A1B9-3E71-4C5A-9F20-1B6E8D3A9C02';
  p_Name_6e4075a46159 := 'Key Result';
  p_Description_6e4075a46159 := 'Measurable key result with baseline, target, and actual values plus periodic check-in cadence';
  p_IconClass_6e4075a46159 := 'fa-solid fa-chart-line';
  p_DefaultPriority_6e4075a46159 := 'High';
  p_IsActive_6e4075a46159 := TRUE;
  p_Code_6e4075a46159 := 'KEY_RESULT';
  p_IsApproval_6e4075a46159 := FALSE;
  IF NOT EXISTS (SELECT 1 FROM __mj_bizappstasks."TaskType" WHERE "ID" = p_ID_6e4075a46159 OR "Name" = p_Name_6e4075a46159 OR "Code" = p_Code_6e4075a46159) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '__mj_BizAppsTasks' AND p.proname = 'spCreateTaskType'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM __mj_BizAppsTasks."spCreateTaskType"(p_data := jsonb_build_object(
      'ID', p_ID_6e4075a46159,
      'Name', p_Name_6e4075a46159,
      'Description', p_Description_6e4075a46159,
      'IconClass', p_IconClass_6e4075a46159,
      'DefaultPriority', p_DefaultPriority_6e4075a46159,
      'OnAssignActionID', p_OnAssignActionID_6e4075a46159,
      'OnCompleteActionID', p_OnCompleteActionID_6e4075a46159,
      'OnOverdueActionID', p_OnOverdueActionID_6e4075a46159,
      'OnPercentChangeActionID', p_OnPercentChangeActionID_6e4075a46159,
      'IsActive', p_IsActive_6e4075a46159,
      'OnRejectActionID', p_OnRejectActionID_6e4075a46159,
      'OnCancelActionID', p_OnCancelActionID_6e4075a46159,
      'Code', p_Code_6e4075a46159,
      'OnCreateActionID', p_OnCreateActionID_6e4075a46159,
      'OnStatusChangeActionID', p_OnStatusChangeActionID_6e4075a46159,
      'IsApproval', p_IsApproval_6e4075a46159
    ));
    ELSE
      PERFORM __mj_BizAppsTasks."spCreateTaskType"(p_ID := p_ID_6e4075a46159, p_Name := p_Name_6e4075a46159, p_Description := p_Description_6e4075a46159, p_IconClass := p_IconClass_6e4075a46159, p_DefaultPriority := p_DefaultPriority_6e4075a46159, p_OnAssignActionID := p_OnAssignActionID_6e4075a46159, p_OnAssignActionID_Clear := TRUE, p_OnCompleteActionID := p_OnCompleteActionID_6e4075a46159, p_OnCompleteActionID_Clear := TRUE, p_OnOverdueActionID := p_OnOverdueActionID_6e4075a46159, p_OnOverdueActionID_Clear := TRUE, p_OnPercentChangeActionID := p_OnPercentChangeActionID_6e4075a46159, p_OnPercentChangeActionID_Clear := TRUE, p_IsActive := p_IsActive_6e4075a46159, p_OnRejectActionID := p_OnRejectActionID_6e4075a46159, p_OnRejectActionID_Clear := TRUE, p_OnCancelActionID := p_OnCancelActionID_6e4075a46159, p_OnCancelActionID_Clear := TRUE, p_Code := p_Code_6e4075a46159, p_OnCreateActionID := p_OnCreateActionID_6e4075a46159, p_OnCreateActionID_Clear := TRUE, p_OnStatusChangeActionID := p_OnStatusChangeActionID_6e4075a46159, p_OnStatusChangeActionID_Clear := TRUE, p_IsApproval := p_IsApproval_6e4075a46159);
    END IF;
  END IF;
END $mj$;
