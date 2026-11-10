-- =============================================================================================
-- PostgreSQL counterpart of V202611101836__v1.12.x__Metadata_Sync.sql
-- =============================================================================================
-- Same records, same values as the T-SQL file; see its header for what ships and why.
--
-- HOW IT WAS MADE: `mj sql-convert --from tsql --to postgres` (MJ CLI 6.2.1) on each block of the
-- push log, one block per run (the converter merges a multi-block log into one). Each block's
-- guard is then widened to match the T-SQL file (ID, or the natural key) and its update branch
-- removed, so every record is create-only. Core references use ${mjSchema}.
-- =============================================================================================

-- Save MJ: Application Settings (core SP call only)
DO $mj$
DECLARE
  p_ID_372ce7d1ab33 UUID;
  p_ApplicationID_372ce7d1ab33 UUID;
  p_Name_372ce7d1ab33 VARCHAR(100);
  p_Value_372ce7d1ab33 TEXT;
  p_Comments_372ce7d1ab33 TEXT;
BEGIN
  p_ID_372ce7d1ab33 := 'CBF531C2-4DBE-4F63-9CFB-C3266835AD6E';
  p_ApplicationID_372ce7d1ab33 := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."Application"
    WHERE
      LOWER("Name") = LOWER('Tasks')
  );
  p_Name_372ce7d1ab33 := 'ApprovalReassignRoles';
  p_Value_372ce7d1ab33 := '';
  p_Comments_372ce7d1ab33 := 'Comma-separated NAMES of the MJ roles whose holders may change who an approval task (a task whose type has IsApproval set) is assigned to, or remove its assignee (bc-aidp-next-golive#389). Names match trimmed and case-insensitively; a name that is not a role matches nobody and is logged. Nobody may reassign an approval to themselves, whatever their role. Creating assignments is not checked, so workflow routing is unaffected. Empty, the default, switches the role rule off, so assignments move as before; the self-assignment refusal still applies.';
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ApplicationSetting"
                 WHERE "ID" = p_ID_372ce7d1ab33
                    OR ("ApplicationID" = p_ApplicationID_372ce7d1ab33 AND "Name" = p_Name_372ce7d1ab33)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateApplicationSetting'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateApplicationSetting"(p_data := jsonb_build_object(
    'ID', p_ID_372ce7d1ab33,
    'ApplicationID', p_ApplicationID_372ce7d1ab33,
    'Name', p_Name_372ce7d1ab33,
    'Value', p_Value_372ce7d1ab33,
    'Comments', p_Comments_372ce7d1ab33
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateApplicationSetting"(p_ID := p_ID_372ce7d1ab33, p_ApplicationID := p_ApplicationID_372ce7d1ab33, p_Name := p_Name_372ce7d1ab33, p_Value := p_Value_372ce7d1ab33, p_Comments := p_Comments_372ce7d1ab33);
    END IF;
  END IF;
END $mj$;
