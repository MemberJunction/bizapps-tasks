-- =============================================================================================
-- PostgreSQL counterpart of V202611191630__v1.14.x__Metadata_Sync.sql
-- =============================================================================================
-- Same records, same values as the T-SQL file; see its header for what ships, what is held back
-- and why. Differences:
--   * Row-level security filters: FilterText is each filter's PostgreSQL text from its
--     PlatformVariants in metadata/, since MJ 6.2.1 has no PlatformVariants column and applies
--     FilterText as written.
--   * Meeting agenda item types, meeting types and video providers are written by INSERT: the
--     Meetings PostgreSQL migration (V202611171200) ships no CRUD functions for these tables.
--
-- HOW IT WAS MADE: `mj sql-convert --from tsql --to postgres` (MJ CLI 6.2.1) on each block of the
-- push log, one block per run (the converter merges a multi-block log into one). Each block's
-- guard is then widened to match the T-SQL file (ID, or the natural key) and its update branch
-- removed, so every record is create-only; the two update kinds carry the T-SQL file's guards.
-- String values are restored from the T-SQL file. Core references use ${mjSchema}; this app's
-- schema is written __mj_BizAppsTasks, unquoted, as in the app's other PostgreSQL migrations.
-- =============================================================================================

-- Save MJ: Row Level Security Filters (core SP call only)
DO $mj$
DECLARE
  p_ID_25a179f618fa UUID;
  p_Name_25a179f618fa VARCHAR(100);
  p_Description_25a179f618fa TEXT;
  p_FilterText_25a179f618fa TEXT;
BEGIN
  p_ID_25a179f618fa := '1E5E2158-D462-43B7-98F4-83DDA7645082';
  p_Name_25a179f618fa := 'Tasks: Visible Meetings';
  p_Description_25a179f618fa := 'A Standard meeting, or a Private meeting the caller is an attendee of.';
  -- PostgreSQL text from the filter's PlatformVariants (MJ 6.2.1 has no such column).
  p_FilterText_25a179f618fa := '("Visibility" = ''Standard'' OR "ID" IN (SELECT "MeetingID" FROM __mj_BizAppsTasks."vwMeetingAttendees" WHERE "UserID" = NULLIF(''{{UserID}}'', '''')::uuid))';
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."RowLevelSecurityFilter"
                 WHERE "ID" = p_ID_25a179f618fa
                    OR ("Name" = p_Name_25a179f618fa)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateRowLevelSecurityFilter'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateRowLevelSecurityFilter"(p_data := jsonb_build_object(
    'ID', p_ID_25a179f618fa,
    'Name', p_Name_25a179f618fa,
    'Description', p_Description_25a179f618fa,
    'FilterText', p_FilterText_25a179f618fa
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateRowLevelSecurityFilter"(p_ID := p_ID_25a179f618fa, p_Name := p_Name_25a179f618fa, p_Description := p_Description_25a179f618fa, p_FilterText := p_FilterText_25a179f618fa);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Row Level Security Filters (core SP call only)
DO $mj$
DECLARE
  p_ID_8339f85f3f3b UUID;
  p_Name_8339f85f3f3b VARCHAR(100);
  p_Description_8339f85f3f3b TEXT;
  p_FilterText_8339f85f3f3b TEXT;
BEGIN
  p_ID_8339f85f3f3b := '5F74277C-EE11-4B3F-8323-0B1BDB459428';
  p_Name_8339f85f3f3b := 'Tasks: Rows Of Visible Meetings';
  p_Description_8339f85f3f3b := 'A row (an attendee, an agenda item, a note) of a meeting the caller may see: Standard, or Private with the caller among its attendees.';
  -- PostgreSQL text from the filter's PlatformVariants (MJ 6.2.1 has no such column).
  p_FilterText_8339f85f3f3b := '("MeetingID" IN (SELECT "ID" FROM __mj_BizAppsTasks."vwMeetings" WHERE "Visibility" = ''Standard'' OR "ID" IN (SELECT "MeetingID" FROM __mj_BizAppsTasks."vwMeetingAttendees" WHERE "UserID" = NULLIF(''{{UserID}}'', '''')::uuid)))';
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."RowLevelSecurityFilter"
                 WHERE "ID" = p_ID_8339f85f3f3b
                    OR ("Name" = p_Name_8339f85f3f3b)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateRowLevelSecurityFilter'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateRowLevelSecurityFilter"(p_data := jsonb_build_object(
    'ID', p_ID_8339f85f3f3b,
    'Name', p_Name_8339f85f3f3b,
    'Description', p_Description_8339f85f3f3b,
    'FilterText', p_FilterText_8339f85f3f3b
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateRowLevelSecurityFilter"(p_ID := p_ID_8339f85f3f3b, p_Name := p_Name_8339f85f3f3b, p_Description := p_Description_8339f85f3f3b, p_FilterText := p_FilterText_8339f85f3f3b);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Row Level Security Filters (core SP call only)
DO $mj$
DECLARE
  p_ID_24c6319427fe UUID;
  p_Name_24c6319427fe VARCHAR(100);
  p_Description_24c6319427fe TEXT;
  p_FilterText_24c6319427fe TEXT;
BEGIN
  p_ID_24c6319427fe := 'AB856DE4-9F70-4A17-8E6D-1C1C24142E9C';
  p_Name_24c6319427fe := 'Tasks: Visible Meeting Links';
  p_Description_24c6319427fe := 'A link of a series the caller may see, or of a meeting the caller may see.';
  -- PostgreSQL text from the filter's PlatformVariants (MJ 6.2.1 has no such column).
  p_FilterText_24c6319427fe := '(("SeriesID" IS NOT NULL AND "SeriesID" IN (SELECT "ID" FROM __mj_BizAppsTasks."vwMeetingSeries" WHERE "Visibility" = ''Standard'' OR "OrganizerPersonID"::text IN (SELECT "LinkedEntityRecordID" FROM "${mjSchema}"."vwUsers" WHERE "ID" = NULLIF(''{{UserID}}'', '''')::uuid) OR "OrganizerPersonID" IN (SELECT "ID" FROM __mj_BizAppsCommon."vwPeople" WHERE "LinkedUserID" = NULLIF(''{{UserID}}'', '''')::uuid) OR "ID" IN (SELECT "SeriesID" FROM __mj_BizAppsTasks."vwMeetingSeriesAttendees" WHERE "UserID" = NULLIF(''{{UserID}}'', '''')::uuid))) OR ("MeetingID" IS NOT NULL AND "MeetingID" IN (SELECT "ID" FROM __mj_BizAppsTasks."vwMeetings" WHERE "Visibility" = ''Standard'' OR "ID" IN (SELECT "MeetingID" FROM __mj_BizAppsTasks."vwMeetingAttendees" WHERE "UserID" = NULLIF(''{{UserID}}'', '''')::uuid))))';
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."RowLevelSecurityFilter"
                 WHERE "ID" = p_ID_24c6319427fe
                    OR ("Name" = p_Name_24c6319427fe)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateRowLevelSecurityFilter'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateRowLevelSecurityFilter"(p_data := jsonb_build_object(
    'ID', p_ID_24c6319427fe,
    'Name', p_Name_24c6319427fe,
    'Description', p_Description_24c6319427fe,
    'FilterText', p_FilterText_24c6319427fe
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateRowLevelSecurityFilter"(p_ID := p_ID_24c6319427fe, p_Name := p_Name_24c6319427fe, p_Description := p_Description_24c6319427fe, p_FilterText := p_FilterText_24c6319427fe);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Row Level Security Filters (core SP call only)
DO $mj$
DECLARE
  p_ID_2a530fa2c79c UUID;
  p_Name_2a530fa2c79c VARCHAR(100);
  p_Description_2a530fa2c79c TEXT;
  p_FilterText_2a530fa2c79c TEXT;
BEGIN
  p_ID_2a530fa2c79c := '3C7D9A1E-5B2F-4E8A-9D6C-1F0E2A3B4C5D';
  p_Name_2a530fa2c79c := 'Tasks: Visible Meeting Series';
  p_Description_2a530fa2c79c := 'A Standard series, or a Private series the caller organizes (through their user''s link to a Person, or the Person''s deprecated LinkedUserID) or is invited to.';
  -- PostgreSQL text from the filter's PlatformVariants (MJ 6.2.1 has no such column).
  p_FilterText_2a530fa2c79c := '("Visibility" = ''Standard'' OR "OrganizerPersonID"::text IN (SELECT "LinkedEntityRecordID" FROM "${mjSchema}"."vwUsers" WHERE "ID" = NULLIF(''{{UserID}}'', '''')::uuid) OR "OrganizerPersonID" IN (SELECT "ID" FROM __mj_BizAppsCommon."vwPeople" WHERE "LinkedUserID" = NULLIF(''{{UserID}}'', '''')::uuid) OR "ID" IN (SELECT "SeriesID" FROM __mj_BizAppsTasks."vwMeetingSeriesAttendees" WHERE "UserID" = NULLIF(''{{UserID}}'', '''')::uuid))';
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."RowLevelSecurityFilter"
                 WHERE "ID" = p_ID_2a530fa2c79c
                    OR ("Name" = p_Name_2a530fa2c79c)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateRowLevelSecurityFilter'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateRowLevelSecurityFilter"(p_data := jsonb_build_object(
    'ID', p_ID_2a530fa2c79c,
    'Name', p_Name_2a530fa2c79c,
    'Description', p_Description_2a530fa2c79c,
    'FilterText', p_FilterText_2a530fa2c79c
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateRowLevelSecurityFilter"(p_ID := p_ID_2a530fa2c79c, p_Name := p_Name_2a530fa2c79c, p_Description := p_Description_2a530fa2c79c, p_FilterText := p_FilterText_2a530fa2c79c);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Row Level Security Filters (core SP call only)
DO $mj$
DECLARE
  p_ID_c03d53887788 UUID;
  p_Name_c03d53887788 VARCHAR(100);
  p_Description_c03d53887788 TEXT;
  p_FilterText_c03d53887788 TEXT;
BEGIN
  p_ID_c03d53887788 := '8E2F4B6D-0A1C-4D3E-B5F7-2C9A8B7D6E5F';
  p_Name_c03d53887788 := 'Tasks: Visible Meeting Series Attendees';
  p_Description_c03d53887788 := 'Who a series invites, for a series the caller may see.';
  -- PostgreSQL text from the filter's PlatformVariants (MJ 6.2.1 has no such column).
  p_FilterText_c03d53887788 := '("SeriesID" IN (SELECT "ID" FROM __mj_BizAppsTasks."vwMeetingSeries" WHERE "Visibility" = ''Standard'' OR "OrganizerPersonID"::text IN (SELECT "LinkedEntityRecordID" FROM "${mjSchema}"."vwUsers" WHERE "ID" = NULLIF(''{{UserID}}'', '''')::uuid) OR "OrganizerPersonID" IN (SELECT "ID" FROM __mj_BizAppsCommon."vwPeople" WHERE "LinkedUserID" = NULLIF(''{{UserID}}'', '''')::uuid) OR "ID" IN (SELECT "SeriesID" FROM __mj_BizAppsTasks."vwMeetingSeriesAttendees" WHERE "UserID" = NULLIF(''{{UserID}}'', '''')::uuid)))';
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."RowLevelSecurityFilter"
                 WHERE "ID" = p_ID_c03d53887788
                    OR ("Name" = p_Name_c03d53887788)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateRowLevelSecurityFilter'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateRowLevelSecurityFilter"(p_data := jsonb_build_object(
    'ID', p_ID_c03d53887788,
    'Name', p_Name_c03d53887788,
    'Description', p_Description_c03d53887788,
    'FilterText', p_FilterText_c03d53887788
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateRowLevelSecurityFilter"(p_ID := p_ID_c03d53887788, p_Name := p_Name_c03d53887788, p_Description := p_Description_c03d53887788, p_FilterText := p_FilterText_c03d53887788);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Entity Fields (core SP call only)
DO $mj$
DECLARE
  p_Configuration_6ed7ddb44a9a TEXT;
  p_ID_6ed7ddb44a9a UUID;
BEGIN
  p_Configuration_6ed7ddb44a9a := '{
  "Hierarchy": {
    "IsHierarchy": true
  }
}';
  p_ID_6ed7ddb44a9a := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."EntityField"
    WHERE
      "EntityID" = (
        SELECT
          "ID"
        FROM
          "${mjSchema}"."Entity"
        WHERE
          LOWER("Name") = LOWER('MJ_BizApps_Tasks: Meeting Agenda Items')
      )
      AND LOWER("Name") = LOWER('ParentID')
  );
  -- Set only while the field has no Configuration, so a host's own is kept.
  IF EXISTS (SELECT 1 FROM "${mjSchema}"."EntityField"
             WHERE "ID" = p_ID_6ed7ddb44a9a AND "Configuration" IS NULL) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityField'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spUpdateEntityField"(p_data := jsonb_build_object(
      'Configuration', p_Configuration_6ed7ddb44a9a,
      'ID', p_ID_6ed7ddb44a9a
    ));
    ELSE
      PERFORM "${mjSchema}"."spUpdateEntityField"(p_Configuration := p_Configuration_6ed7ddb44a9a, p_ID := p_ID_6ed7ddb44a9a);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Entity Permissions (core SP call only)
DO $mj$
DECLARE
  p_CanCreate_204501464c7c BOOLEAN;
  p_CanUpdate_204501464c7c BOOLEAN;
  p_ReadRLSFilterID_204501464c7c UUID;
  p_ID_204501464c7c UUID;
BEGIN
  p_CanCreate_204501464c7c := TRUE;
  p_CanUpdate_204501464c7c := TRUE;
  p_ReadRLSFilterID_204501464c7c := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."RowLevelSecurityFilter"
    WHERE
      LOWER("Name") = LOWER('Tasks: Visible Meetings')
  );
  p_ID_204501464c7c := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."EntityPermission"
    WHERE
      "EntityID" = (
        SELECT
          "ID"
        FROM
          "${mjSchema}"."Entity"
        WHERE
          LOWER("Name") = LOWER('MJ_BizApps_Tasks: Meetings')
      )
      AND "RoleID" = (
        SELECT
          "ID"
        FROM
          "${mjSchema}"."Role"
        WHERE
          LOWER("Name") = LOWER('UI')
      )
  );
  -- Set only while the UI role's permission has no read filter, so a host's own grant and filter are kept.
  IF EXISTS (SELECT 1 FROM "${mjSchema}"."EntityPermission"
             WHERE "ID" = p_ID_204501464c7c AND "ReadRLSFilterID" IS NULL) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityPermission'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_data := jsonb_build_object(
      'CanCreate', p_CanCreate_204501464c7c,
      'CanUpdate', p_CanUpdate_204501464c7c,
      'ReadRLSFilterID', p_ReadRLSFilterID_204501464c7c,
      'ID', p_ID_204501464c7c
    ));
    ELSE
      PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_CanCreate := p_CanCreate_204501464c7c, p_CanUpdate := p_CanUpdate_204501464c7c, p_ReadRLSFilterID := p_ReadRLSFilterID_204501464c7c, p_ID := p_ID_204501464c7c);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Entity Permissions (core SP call only)
DO $mj$
DECLARE
  p_CanCreate_747620e00fac BOOLEAN;
  p_CanUpdate_747620e00fac BOOLEAN;
  p_ReadRLSFilterID_747620e00fac UUID;
  p_ID_747620e00fac UUID;
BEGIN
  p_CanCreate_747620e00fac := TRUE;
  p_CanUpdate_747620e00fac := TRUE;
  p_ReadRLSFilterID_747620e00fac := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."RowLevelSecurityFilter"
    WHERE
      LOWER("Name") = LOWER('Tasks: Visible Meeting Series')
  );
  p_ID_747620e00fac := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."EntityPermission"
    WHERE
      "EntityID" = (
        SELECT
          "ID"
        FROM
          "${mjSchema}"."Entity"
        WHERE
          LOWER("Name") = LOWER('MJ_BizApps_Tasks: Meeting Series')
      )
      AND "RoleID" = (
        SELECT
          "ID"
        FROM
          "${mjSchema}"."Role"
        WHERE
          LOWER("Name") = LOWER('UI')
      )
  );
  -- Set only while the UI role's permission has no read filter, so a host's own grant and filter are kept.
  IF EXISTS (SELECT 1 FROM "${mjSchema}"."EntityPermission"
             WHERE "ID" = p_ID_747620e00fac AND "ReadRLSFilterID" IS NULL) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityPermission'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_data := jsonb_build_object(
      'CanCreate', p_CanCreate_747620e00fac,
      'CanUpdate', p_CanUpdate_747620e00fac,
      'ReadRLSFilterID', p_ReadRLSFilterID_747620e00fac,
      'ID', p_ID_747620e00fac
    ));
    ELSE
      PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_CanCreate := p_CanCreate_747620e00fac, p_CanUpdate := p_CanUpdate_747620e00fac, p_ReadRLSFilterID := p_ReadRLSFilterID_747620e00fac, p_ID := p_ID_747620e00fac);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Entity Permissions (core SP call only)
DO $mj$
DECLARE
  p_CanCreate_8f9f94f90866 BOOLEAN;
  p_CanUpdate_8f9f94f90866 BOOLEAN;
  p_CanDelete_8f9f94f90866 BOOLEAN;
  p_ReadRLSFilterID_8f9f94f90866 UUID;
  p_ID_8f9f94f90866 UUID;
BEGIN
  p_CanCreate_8f9f94f90866 := TRUE;
  p_CanUpdate_8f9f94f90866 := TRUE;
  p_CanDelete_8f9f94f90866 := TRUE;
  p_ReadRLSFilterID_8f9f94f90866 := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."RowLevelSecurityFilter"
    WHERE
      LOWER("Name") = LOWER('Tasks: Visible Meeting Series Attendees')
  );
  p_ID_8f9f94f90866 := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."EntityPermission"
    WHERE
      "EntityID" = (
        SELECT
          "ID"
        FROM
          "${mjSchema}"."Entity"
        WHERE
          LOWER("Name") = LOWER('MJ_BizApps_Tasks: Meeting Series Attendees')
      )
      AND "RoleID" = (
        SELECT
          "ID"
        FROM
          "${mjSchema}"."Role"
        WHERE
          LOWER("Name") = LOWER('UI')
      )
  );
  -- Set only while the UI role's permission has no read filter, so a host's own grant and filter are kept.
  IF EXISTS (SELECT 1 FROM "${mjSchema}"."EntityPermission"
             WHERE "ID" = p_ID_8f9f94f90866 AND "ReadRLSFilterID" IS NULL) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityPermission'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_data := jsonb_build_object(
      'CanCreate', p_CanCreate_8f9f94f90866,
      'CanUpdate', p_CanUpdate_8f9f94f90866,
      'CanDelete', p_CanDelete_8f9f94f90866,
      'ReadRLSFilterID', p_ReadRLSFilterID_8f9f94f90866,
      'ID', p_ID_8f9f94f90866
    ));
    ELSE
      PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_CanCreate := p_CanCreate_8f9f94f90866, p_CanUpdate := p_CanUpdate_8f9f94f90866, p_CanDelete := p_CanDelete_8f9f94f90866, p_ReadRLSFilterID := p_ReadRLSFilterID_8f9f94f90866, p_ID := p_ID_8f9f94f90866);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Entity Permissions (core SP call only)
DO $mj$
DECLARE
  p_CanCreate_92ffd1466afb BOOLEAN;
  p_CanUpdate_92ffd1466afb BOOLEAN;
  p_CanDelete_92ffd1466afb BOOLEAN;
  p_ReadRLSFilterID_92ffd1466afb UUID;
  p_ID_92ffd1466afb UUID;
BEGIN
  p_CanCreate_92ffd1466afb := TRUE;
  p_CanUpdate_92ffd1466afb := TRUE;
  p_CanDelete_92ffd1466afb := TRUE;
  p_ReadRLSFilterID_92ffd1466afb := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."RowLevelSecurityFilter"
    WHERE
      LOWER("Name") = LOWER('Tasks: Rows Of Visible Meetings')
  );
  p_ID_92ffd1466afb := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."EntityPermission"
    WHERE
      "EntityID" = (
        SELECT
          "ID"
        FROM
          "${mjSchema}"."Entity"
        WHERE
          LOWER("Name") = LOWER('MJ_BizApps_Tasks: Meeting Attendees')
      )
      AND "RoleID" = (
        SELECT
          "ID"
        FROM
          "${mjSchema}"."Role"
        WHERE
          LOWER("Name") = LOWER('UI')
      )
  );
  -- Set only while the UI role's permission has no read filter, so a host's own grant and filter are kept.
  IF EXISTS (SELECT 1 FROM "${mjSchema}"."EntityPermission"
             WHERE "ID" = p_ID_92ffd1466afb AND "ReadRLSFilterID" IS NULL) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityPermission'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_data := jsonb_build_object(
      'CanCreate', p_CanCreate_92ffd1466afb,
      'CanUpdate', p_CanUpdate_92ffd1466afb,
      'CanDelete', p_CanDelete_92ffd1466afb,
      'ReadRLSFilterID', p_ReadRLSFilterID_92ffd1466afb,
      'ID', p_ID_92ffd1466afb
    ));
    ELSE
      PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_CanCreate := p_CanCreate_92ffd1466afb, p_CanUpdate := p_CanUpdate_92ffd1466afb, p_CanDelete := p_CanDelete_92ffd1466afb, p_ReadRLSFilterID := p_ReadRLSFilterID_92ffd1466afb, p_ID := p_ID_92ffd1466afb);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Entity Permissions (core SP call only)
DO $mj$
DECLARE
  p_CanCreate_dd9207bc70b4 BOOLEAN;
  p_CanUpdate_dd9207bc70b4 BOOLEAN;
  p_CanDelete_dd9207bc70b4 BOOLEAN;
  p_ReadRLSFilterID_dd9207bc70b4 UUID;
  p_ID_dd9207bc70b4 UUID;
BEGIN
  p_CanCreate_dd9207bc70b4 := TRUE;
  p_CanUpdate_dd9207bc70b4 := TRUE;
  p_CanDelete_dd9207bc70b4 := TRUE;
  p_ReadRLSFilterID_dd9207bc70b4 := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."RowLevelSecurityFilter"
    WHERE
      LOWER("Name") = LOWER('Tasks: Rows Of Visible Meetings')
  );
  p_ID_dd9207bc70b4 := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."EntityPermission"
    WHERE
      "EntityID" = (
        SELECT
          "ID"
        FROM
          "${mjSchema}"."Entity"
        WHERE
          LOWER("Name") = LOWER('MJ_BizApps_Tasks: Meeting Agenda Items')
      )
      AND "RoleID" = (
        SELECT
          "ID"
        FROM
          "${mjSchema}"."Role"
        WHERE
          LOWER("Name") = LOWER('UI')
      )
  );
  -- Set only while the UI role's permission has no read filter, so a host's own grant and filter are kept.
  IF EXISTS (SELECT 1 FROM "${mjSchema}"."EntityPermission"
             WHERE "ID" = p_ID_dd9207bc70b4 AND "ReadRLSFilterID" IS NULL) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityPermission'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_data := jsonb_build_object(
      'CanCreate', p_CanCreate_dd9207bc70b4,
      'CanUpdate', p_CanUpdate_dd9207bc70b4,
      'CanDelete', p_CanDelete_dd9207bc70b4,
      'ReadRLSFilterID', p_ReadRLSFilterID_dd9207bc70b4,
      'ID', p_ID_dd9207bc70b4
    ));
    ELSE
      PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_CanCreate := p_CanCreate_dd9207bc70b4, p_CanUpdate := p_CanUpdate_dd9207bc70b4, p_CanDelete := p_CanDelete_dd9207bc70b4, p_ReadRLSFilterID := p_ReadRLSFilterID_dd9207bc70b4, p_ID := p_ID_dd9207bc70b4);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Entity Permissions (core SP call only)
DO $mj$
DECLARE
  p_CanCreate_a14998b0b53a BOOLEAN;
  p_CanUpdate_a14998b0b53a BOOLEAN;
  p_CanDelete_a14998b0b53a BOOLEAN;
  p_ReadRLSFilterID_a14998b0b53a UUID;
  p_ID_a14998b0b53a UUID;
BEGIN
  p_CanCreate_a14998b0b53a := TRUE;
  p_CanUpdate_a14998b0b53a := TRUE;
  p_CanDelete_a14998b0b53a := TRUE;
  p_ReadRLSFilterID_a14998b0b53a := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."RowLevelSecurityFilter"
    WHERE
      LOWER("Name") = LOWER('Tasks: Rows Of Visible Meetings')
  );
  p_ID_a14998b0b53a := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."EntityPermission"
    WHERE
      "EntityID" = (
        SELECT
          "ID"
        FROM
          "${mjSchema}"."Entity"
        WHERE
          LOWER("Name") = LOWER('MJ_BizApps_Tasks: Meeting Notes')
      )
      AND "RoleID" = (
        SELECT
          "ID"
        FROM
          "${mjSchema}"."Role"
        WHERE
          LOWER("Name") = LOWER('UI')
      )
  );
  -- Set only while the UI role's permission has no read filter, so a host's own grant and filter are kept.
  IF EXISTS (SELECT 1 FROM "${mjSchema}"."EntityPermission"
             WHERE "ID" = p_ID_a14998b0b53a AND "ReadRLSFilterID" IS NULL) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityPermission'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_data := jsonb_build_object(
      'CanCreate', p_CanCreate_a14998b0b53a,
      'CanUpdate', p_CanUpdate_a14998b0b53a,
      'CanDelete', p_CanDelete_a14998b0b53a,
      'ReadRLSFilterID', p_ReadRLSFilterID_a14998b0b53a,
      'ID', p_ID_a14998b0b53a
    ));
    ELSE
      PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_CanCreate := p_CanCreate_a14998b0b53a, p_CanUpdate := p_CanUpdate_a14998b0b53a, p_CanDelete := p_CanDelete_a14998b0b53a, p_ReadRLSFilterID := p_ReadRLSFilterID_a14998b0b53a, p_ID := p_ID_a14998b0b53a);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Entity Permissions (core SP call only)
DO $mj$
DECLARE
  p_CanCreate_8e3a20ad1603 BOOLEAN;
  p_CanUpdate_8e3a20ad1603 BOOLEAN;
  p_CanDelete_8e3a20ad1603 BOOLEAN;
  p_ReadRLSFilterID_8e3a20ad1603 UUID;
  p_ID_8e3a20ad1603 UUID;
BEGIN
  p_CanCreate_8e3a20ad1603 := TRUE;
  p_CanUpdate_8e3a20ad1603 := TRUE;
  p_CanDelete_8e3a20ad1603 := TRUE;
  p_ReadRLSFilterID_8e3a20ad1603 := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."RowLevelSecurityFilter"
    WHERE
      LOWER("Name") = LOWER('Tasks: Visible Meeting Links')
  );
  p_ID_8e3a20ad1603 := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."EntityPermission"
    WHERE
      "EntityID" = (
        SELECT
          "ID"
        FROM
          "${mjSchema}"."Entity"
        WHERE
          LOWER("Name") = LOWER('MJ_BizApps_Tasks: Meeting Links')
      )
      AND "RoleID" = (
        SELECT
          "ID"
        FROM
          "${mjSchema}"."Role"
        WHERE
          LOWER("Name") = LOWER('UI')
      )
  );
  -- Set only while the UI role's permission has no read filter, so a host's own grant and filter are kept.
  IF EXISTS (SELECT 1 FROM "${mjSchema}"."EntityPermission"
             WHERE "ID" = p_ID_8e3a20ad1603 AND "ReadRLSFilterID" IS NULL) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spUpdateEntityPermission'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_data := jsonb_build_object(
      'CanCreate', p_CanCreate_8e3a20ad1603,
      'CanUpdate', p_CanUpdate_8e3a20ad1603,
      'CanDelete', p_CanDelete_8e3a20ad1603,
      'ReadRLSFilterID', p_ReadRLSFilterID_8e3a20ad1603,
      'ID', p_ID_8e3a20ad1603
    ));
    ELSE
      PERFORM "${mjSchema}"."spUpdateEntityPermission"(p_CanCreate := p_CanCreate_8e3a20ad1603, p_CanUpdate := p_CanUpdate_8e3a20ad1603, p_CanDelete := p_CanDelete_8e3a20ad1603, p_ReadRLSFilterID := p_ReadRLSFilterID_8e3a20ad1603, p_ID := p_ID_8e3a20ad1603);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Credential Types (core SP call only)
DO $mj$
DECLARE
  p_ID_c955078801a6 UUID;
  p_Name_c955078801a6 VARCHAR(100);
  p_Description_c955078801a6 TEXT;
  p_Category_c955078801a6 VARCHAR(50);
  p_FieldSchema_c955078801a6 TEXT;
  p_IconClass_c955078801a6 VARCHAR(100);
  p_ValidationEndpoint_c955078801a6 VARCHAR(500);
BEGIN
  p_ID_c955078801a6 := 'DAA02013-510D-41F4-BFAA-9250C7BC7D37';
  p_Name_c955078801a6 := 'Video Provider OAuth';
  p_Description_c955078801a6 := 'OAuth credentials for video conferencing providers (Zoom Server-to-Server, Teams, Google Meet)';
  p_Category_c955078801a6 := 'Integration';
  p_FieldSchema_c955078801a6 := '{"type": "object", "properties": {"client_id": {"type": "string", "title": "Client ID / Service Account Email"}, "client_secret": {"type": "string", "title": "Client Secret / Private Key PEM"}, "account_id": {"type": "string", "title": "Account ID (Zoom) / Tenant ID (Teams) / Impersonated User (Google)"}, "organizer_user_id": {"type": "string", "title": "Organizer User ID (Teams only) \u2014 AAD Object ID or UPN"}}, "required": ["client_id", "client_secret", "account_id"]}';
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."CredentialType"
                 WHERE "ID" = p_ID_c955078801a6
                    OR ("Name" = p_Name_c955078801a6)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateCredentialType'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateCredentialType"(p_data := jsonb_build_object(
    'ID', p_ID_c955078801a6,
    'Name', p_Name_c955078801a6,
    'Description', p_Description_c955078801a6,
    'Category', p_Category_c955078801a6,
    'FieldSchema', p_FieldSchema_c955078801a6,
    'IconClass', p_IconClass_c955078801a6,
    'ValidationEndpoint', p_ValidationEndpoint_c955078801a6
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateCredentialType"(p_ID := p_ID_c955078801a6, p_Name := p_Name_c955078801a6, p_Description := p_Description_c955078801a6, p_Category := p_Category_c955078801a6, p_FieldSchema := p_FieldSchema_c955078801a6, p_IconClass := p_IconClass_c955078801a6, p_IconClass_Clear := TRUE, p_ValidationEndpoint := p_ValidationEndpoint_c955078801a6, p_ValidationEndpoint_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Applications (core SP call only)
DO $mj$
DECLARE
  p_ID_38c8d980bcb6 UUID;
  p_Name_38c8d980bcb6 VARCHAR(100);
  p_Description_38c8d980bcb6 TEXT;
  p_Icon_38c8d980bcb6 VARCHAR(500);
  p_DefaultForNewUser_38c8d980bcb6 BOOLEAN;
  p_SchemaAutoAddNewEntities_38c8d980bcb6 TEXT;
  p_Color_38c8d980bcb6 VARCHAR(20);
  p_DefaultNavItems_38c8d980bcb6 TEXT;
  p_ClassName_38c8d980bcb6 VARCHAR(255);
  p_DefaultSequence_38c8d980bcb6 INTEGER;
  p_Status_38c8d980bcb6 VARCHAR(20);
  p_NavigationStyle_38c8d980bcb6 VARCHAR(20);
  p_TopNavLocation_38c8d980bcb6 VARCHAR(30);
  p_HideNavBarIconWhenActive_38c8d980bcb6 BOOLEAN;
  p_Path_38c8d980bcb6 VARCHAR(100);
  p_AutoUpdatePath_38c8d980bcb6 BOOLEAN;
  p_AgentSettings_38c8d980bcb6 TEXT;
BEGIN
  p_ID_38c8d980bcb6 := '14C40AAC-D873-4206-9735-8EC26A72FADF';
  p_Name_38c8d980bcb6 := 'Meetings';
  p_Description_38c8d980bcb6 := 'Meetings and agendas: schedule one-off or recurring meetings, build agendas from templates, invite people and guests, run the live meeting, keep notes and file follow-ups as tasks.';
  p_Icon_38c8d980bcb6 := 'fa-solid fa-calendar-check';
  p_DefaultForNewUser_38c8d980bcb6 := FALSE;
  p_DefaultNavItems_38c8d980bcb6 := '[
  {
    "Label": "My meetings",
    "Icon": "fa-solid fa-user-clock",
    "ResourceType": "Custom",
    "DriverClass": "MyMeetingsSectionResource",
    "isDefault": true
  },
  {
    "Label": "Meetings",
    "Icon": "fa-solid fa-calendar-check",
    "ResourceType": "Custom",
    "DriverClass": "MeetingsSectionResource",
    "isDefault": false
  },
  {
    "Label": "Series",
    "Icon": "fa-solid fa-repeat",
    "ResourceType": "Custom",
    "DriverClass": "MeetingSeriesSectionResource",
    "isDefault": false
  }
]';
  p_DefaultSequence_38c8d980bcb6 := 100;
  p_Status_38c8d980bcb6 := 'Active';
  p_NavigationStyle_38c8d980bcb6 := 'App Switcher';
  p_HideNavBarIconWhenActive_38c8d980bcb6 := FALSE;
  p_Path_38c8d980bcb6 := 'meetings';
  p_AutoUpdatePath_38c8d980bcb6 := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."Application"
                 WHERE "ID" = p_ID_38c8d980bcb6
                    OR ("Name" = p_Name_38c8d980bcb6)
                    OR ("Path" = p_Path_38c8d980bcb6)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateApplication'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateApplication"(p_data := jsonb_build_object(
    'ID', p_ID_38c8d980bcb6,
    'Name', p_Name_38c8d980bcb6,
    'Description', p_Description_38c8d980bcb6,
    'Icon', p_Icon_38c8d980bcb6,
    'DefaultForNewUser', p_DefaultForNewUser_38c8d980bcb6,
    'SchemaAutoAddNewEntities', p_SchemaAutoAddNewEntities_38c8d980bcb6,
    'Color', p_Color_38c8d980bcb6,
    'DefaultNavItems', p_DefaultNavItems_38c8d980bcb6,
    'ClassName', p_ClassName_38c8d980bcb6,
    'DefaultSequence', p_DefaultSequence_38c8d980bcb6,
    'Status', p_Status_38c8d980bcb6,
    'NavigationStyle', p_NavigationStyle_38c8d980bcb6,
    'TopNavLocation', p_TopNavLocation_38c8d980bcb6,
    'HideNavBarIconWhenActive', p_HideNavBarIconWhenActive_38c8d980bcb6,
    'Path', p_Path_38c8d980bcb6,
    'AutoUpdatePath', p_AutoUpdatePath_38c8d980bcb6,
    'AgentSettings', p_AgentSettings_38c8d980bcb6
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateApplication"(p_ID := p_ID_38c8d980bcb6, p_Name := p_Name_38c8d980bcb6, p_Description := p_Description_38c8d980bcb6, p_Icon := p_Icon_38c8d980bcb6, p_DefaultForNewUser := p_DefaultForNewUser_38c8d980bcb6, p_SchemaAutoAddNewEntities := p_SchemaAutoAddNewEntities_38c8d980bcb6, p_SchemaAutoAddNewEntities_Clear := TRUE, p_Color := p_Color_38c8d980bcb6, p_Color_Clear := TRUE, p_DefaultNavItems := p_DefaultNavItems_38c8d980bcb6, p_ClassName := p_ClassName_38c8d980bcb6, p_ClassName_Clear := TRUE, p_DefaultSequence := p_DefaultSequence_38c8d980bcb6, p_Status := p_Status_38c8d980bcb6, p_NavigationStyle := p_NavigationStyle_38c8d980bcb6, p_TopNavLocation := p_TopNavLocation_38c8d980bcb6, p_TopNavLocation_Clear := TRUE, p_HideNavBarIconWhenActive := p_HideNavBarIconWhenActive_38c8d980bcb6, p_Path := p_Path_38c8d980bcb6, p_AutoUpdatePath := p_AutoUpdatePath_38c8d980bcb6, p_AgentSettings := p_AgentSettings_38c8d980bcb6, p_AgentSettings_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Application Settings (core SP call only)
DO $mj$
DECLARE
  p_ID_58b5dd572818 UUID;
  p_ApplicationID_58b5dd572818 UUID;
  p_Name_58b5dd572818 VARCHAR(100);
  p_Value_58b5dd572818 TEXT;
  p_Comments_58b5dd572818 TEXT;
BEGIN
  p_ID_58b5dd572818 := '28DDAA01-0000-4000-8000-000000000001';
  p_ApplicationID_58b5dd572818 := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."Application"
    WHERE
      LOWER("Name") = LOWER('Tasks')
  );
  p_Name_58b5dd572818 := 'DefaultCalendarProviderName';
  p_Value_58b5dd572818 := '';
  p_Comments_58b5dd572818 := 'The MJ: Communication Providers name (for example ''Microsoft Graph'' or ''Gmail'') used to synchronize meetings with an external calendar via CalendarEventLinks (T2). Empty leaves automatic calendar sync off.';
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ApplicationSetting"
                 WHERE "ID" = p_ID_58b5dd572818
                    OR ("ApplicationID" = p_ApplicationID_58b5dd572818 AND "Name" = p_Name_58b5dd572818)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateApplicationSetting'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateApplicationSetting"(p_data := jsonb_build_object(
    'ID', p_ID_58b5dd572818,
    'ApplicationID', p_ApplicationID_58b5dd572818,
    'Name', p_Name_58b5dd572818,
    'Value', p_Value_58b5dd572818,
    'Comments', p_Comments_58b5dd572818
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateApplicationSetting"(p_ID := p_ID_58b5dd572818, p_ApplicationID := p_ApplicationID_58b5dd572818, p_Name := p_Name_58b5dd572818, p_Value := p_Value_58b5dd572818, p_Comments := p_Comments_58b5dd572818);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Application Settings (core SP call only)
DO $mj$
DECLARE
  p_ID_a7abdfffb149 UUID;
  p_ApplicationID_a7abdfffb149 UUID;
  p_Name_a7abdfffb149 VARCHAR(100);
  p_Value_a7abdfffb149 TEXT;
  p_Comments_a7abdfffb149 TEXT;
BEGIN
  p_ID_a7abdfffb149 := '28DDAA01-0000-4000-8000-000000000002';
  p_ApplicationID_a7abdfffb149 := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."Application"
    WHERE
      LOWER("Name") = LOWER('Tasks')
  );
  p_Name_a7abdfffb149 := 'SharedCalendarMailbox';
  p_Value_a7abdfffb149 := '';
  p_Comments_a7abdfffb149 := 'Optional shared scheduling mailbox address used as the CalendarTarget.Identifier fallback when a meeting''s organizer has no email address.';
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ApplicationSetting"
                 WHERE "ID" = p_ID_a7abdfffb149
                    OR ("ApplicationID" = p_ApplicationID_a7abdfffb149 AND "Name" = p_Name_a7abdfffb149)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateApplicationSetting'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateApplicationSetting"(p_data := jsonb_build_object(
    'ID', p_ID_a7abdfffb149,
    'ApplicationID', p_ApplicationID_a7abdfffb149,
    'Name', p_Name_a7abdfffb149,
    'Value', p_Value_a7abdfffb149,
    'Comments', p_Comments_a7abdfffb149
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateApplicationSetting"(p_ID := p_ID_a7abdfffb149, p_ApplicationID := p_ApplicationID_a7abdfffb149, p_Name := p_Name_a7abdfffb149, p_Value := p_Value_a7abdfffb149, p_Comments := p_Comments_a7abdfffb149);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Templates (core SP call only)
DO $mj$
DECLARE
  p_ID_805217d2d735 UUID;
  p_Name_805217d2d735 VARCHAR(255);
  p_Description_805217d2d735 TEXT;
  p_CategoryID_805217d2d735 UUID;
  p_UserPrompt_805217d2d735 TEXT;
  p_UserID_805217d2d735 UUID;
  p_ActiveAt_805217d2d735 TIMESTAMPTZ;
  p_DisabledAt_805217d2d735 TIMESTAMPTZ;
  p_IsActive_805217d2d735 BOOLEAN;
BEGIN
  p_ID_805217d2d735 := 'f11535e9-dd0c-4e78-8f93-c681c9b820bf';
  p_Name_805217d2d735 := 'Tasks: Meeting Notes from Transcript';
  p_Description_805217d2d735 := 'Template for AI Prompt: Tasks: Meeting Notes from Transcript';
  p_CategoryID_805217d2d735 := 'B61B01C3-2DD1-4FFA-AE77-6DE9765BCA68';
  p_UserID_805217d2d735 := 'ECAFCCEC-6A37-EF11-86D4-000D3A4E707E';
  p_IsActive_805217d2d735 := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."Template"
                 WHERE "ID" = p_ID_805217d2d735) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplate'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplate"(p_data := jsonb_build_object(
    'ID', p_ID_805217d2d735,
    'Name', p_Name_805217d2d735,
    'Description', p_Description_805217d2d735,
    'CategoryID', p_CategoryID_805217d2d735,
    'UserPrompt', p_UserPrompt_805217d2d735,
    'UserID', p_UserID_805217d2d735,
    'ActiveAt', p_ActiveAt_805217d2d735,
    'DisabledAt', p_DisabledAt_805217d2d735,
    'IsActive', p_IsActive_805217d2d735
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplate"(p_ID := p_ID_805217d2d735, p_Name := p_Name_805217d2d735, p_Description := p_Description_805217d2d735, p_CategoryID := p_CategoryID_805217d2d735, p_UserPrompt := p_UserPrompt_805217d2d735, p_UserPrompt_Clear := TRUE, p_UserID := p_UserID_805217d2d735, p_ActiveAt := p_ActiveAt_805217d2d735, p_ActiveAt_Clear := TRUE, p_DisabledAt := p_DisabledAt_805217d2d735, p_DisabledAt_Clear := TRUE, p_IsActive := p_IsActive_805217d2d735);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Contents (core SP call only)
DO $mj$
DECLARE
  p_ID_ec74d81b7dba UUID;
  p_TemplateID_ec74d81b7dba UUID;
  p_TypeID_ec74d81b7dba UUID;
  p_TemplateText_ec74d81b7dba TEXT;
  p_Priority_ec74d81b7dba INTEGER;
  p_IsActive_ec74d81b7dba BOOLEAN;
BEGIN
  p_ID_ec74d81b7dba := 'afdc4ead-f617-483a-9d1a-db20b0153708';
  p_TemplateID_ec74d81b7dba := 'F11535E9-DD0C-4E78-8F93-C681C9B820BF';
  p_TypeID_ec74d81b7dba := 'E7AFCCEC-6A37-EF11-86D4-000D3A4E707E';
  p_TemplateText_ec74d81b7dba := 'You are an expert meeting scribe for MemberJunction BizApps Tasks.

Given a meeting''s details, its agenda items, its attendees, and a raw meeting transcript, produce:
1. `title`: A concise title for the meeting summary note.
2. `summary`: Clear, well-structured Markdown notes covering key discussion points, decisions, and outcomes.
3. `proposedTasks`: An array of concrete action items agreed upon during the meeting. For each proposed action item, match `assigneePersonId` to an attendee''s `PersonID` when the speaker or assignee is clear, and match `agendaItemId` to an agenda item''s `ID` when the action item belongs to a specific topic.

### Meeting Details
- **Title:** {{ meetingName }}
- **Description:** {{ meetingDescription }}
- **StartsAt:** {{ startsAt }}
- **EndsAt:** {{ endsAt }}
- **TimeZone:** {{ timeZone }}

### Agenda Items
{{ agendaItemsJson }}

### Attendees
{{ attendeesJson }}

### Transcript
{{ transcript }}

Return ONLY valid JSON matching this schema:
```json
{
  "title": "string",
  "summary": "string (Markdown)",
  "proposedTasks": [
    {
      "id": "string",
      "title": "string",
      "description": "string | null",
      "assigneePersonId": "string (UUID) | null",
      "assigneeName": "string | null",
      "dueAt": "string (ISO-8601 date) | null",
      "agendaItemId": "string (UUID) | null"
    }
  ]
}
```
';
  p_Priority_ec74d81b7dba := 1;
  p_IsActive_ec74d81b7dba := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateContent"
                 WHERE "ID" = p_ID_ec74d81b7dba
                    OR ("TemplateID" = p_TemplateID_ec74d81b7dba AND "TypeID" = p_TypeID_ec74d81b7dba)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateContent'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateContent"(p_data := jsonb_build_object(
    'ID', p_ID_ec74d81b7dba,
    'TemplateID', p_TemplateID_ec74d81b7dba,
    'TypeID', p_TypeID_ec74d81b7dba,
    'TemplateText', p_TemplateText_ec74d81b7dba,
    'Priority', p_Priority_ec74d81b7dba,
    'IsActive', p_IsActive_ec74d81b7dba
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateContent"(p_ID := p_ID_ec74d81b7dba, p_TemplateID := p_TemplateID_ec74d81b7dba, p_TypeID := p_TypeID_ec74d81b7dba, p_TemplateText := p_TemplateText_ec74d81b7dba, p_Priority := p_Priority_ec74d81b7dba, p_IsActive := p_IsActive_ec74d81b7dba);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Params (core SP call only)
DO $mj$
DECLARE
  p_ID_c11b6dafdd14 UUID;
  p_TemplateID_c11b6dafdd14 UUID;
  p_Name_c11b6dafdd14 VARCHAR(255);
  p_Description_c11b6dafdd14 TEXT;
  p_Type_c11b6dafdd14 VARCHAR(20);
  p_DefaultValue_c11b6dafdd14 TEXT;
  p_IsRequired_c11b6dafdd14 BOOLEAN;
  p_LinkedParameterName_c11b6dafdd14 VARCHAR(255);
  p_LinkedParameterField_c11b6dafdd14 VARCHAR(500);
  p_ExtraFilter_c11b6dafdd14 TEXT;
  p_EntityID_c11b6dafdd14 UUID;
  p_RecordID_c11b6dafdd14 VARCHAR(2000);
  p_OrderBy_c11b6dafdd14 TEXT;
  p_TemplateContentID_c11b6dafdd14 UUID;
BEGIN
  p_ID_c11b6dafdd14 := '31850509-3dc4-4238-a502-24996bec3fc7';
  p_TemplateID_c11b6dafdd14 := 'F11535E9-DD0C-4E78-8F93-C681C9B820BF';
  p_Name_c11b6dafdd14 := 'agendaItemsJson';
  p_Description_c11b6dafdd14 := 'Template scalar parameter ''agendaItemsJson''';
  p_Type_c11b6dafdd14 := 'Scalar';
  p_IsRequired_c11b6dafdd14 := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateParam"
                 WHERE "ID" = p_ID_c11b6dafdd14
                    OR ("TemplateID" = p_TemplateID_c11b6dafdd14 AND "Name" = p_Name_c11b6dafdd14)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_data := jsonb_build_object(
    'ID', p_ID_c11b6dafdd14,
    'TemplateID', p_TemplateID_c11b6dafdd14,
    'Name', p_Name_c11b6dafdd14,
    'Description', p_Description_c11b6dafdd14,
    'Type', p_Type_c11b6dafdd14,
    'DefaultValue', p_DefaultValue_c11b6dafdd14,
    'IsRequired', p_IsRequired_c11b6dafdd14,
    'LinkedParameterName', p_LinkedParameterName_c11b6dafdd14,
    'LinkedParameterField', p_LinkedParameterField_c11b6dafdd14,
    'ExtraFilter', p_ExtraFilter_c11b6dafdd14,
    'EntityID', p_EntityID_c11b6dafdd14,
    'RecordID', p_RecordID_c11b6dafdd14,
    'OrderBy', p_OrderBy_c11b6dafdd14,
    'TemplateContentID', p_TemplateContentID_c11b6dafdd14
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_ID := p_ID_c11b6dafdd14, p_TemplateID := p_TemplateID_c11b6dafdd14, p_Name := p_Name_c11b6dafdd14, p_Description := p_Description_c11b6dafdd14, p_Type := p_Type_c11b6dafdd14, p_DefaultValue := p_DefaultValue_c11b6dafdd14, p_DefaultValue_Clear := TRUE, p_IsRequired := p_IsRequired_c11b6dafdd14, p_LinkedParameterName := p_LinkedParameterName_c11b6dafdd14, p_LinkedParameterName_Clear := TRUE, p_LinkedParameterField := p_LinkedParameterField_c11b6dafdd14, p_LinkedParameterField_Clear := TRUE, p_ExtraFilter := p_ExtraFilter_c11b6dafdd14, p_ExtraFilter_Clear := TRUE, p_EntityID := p_EntityID_c11b6dafdd14, p_EntityID_Clear := TRUE, p_RecordID := p_RecordID_c11b6dafdd14, p_RecordID_Clear := TRUE, p_OrderBy := p_OrderBy_c11b6dafdd14, p_OrderBy_Clear := TRUE, p_TemplateContentID := p_TemplateContentID_c11b6dafdd14, p_TemplateContentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Params (core SP call only)
DO $mj$
DECLARE
  p_ID_229909441ac8 UUID;
  p_TemplateID_229909441ac8 UUID;
  p_Name_229909441ac8 VARCHAR(255);
  p_Description_229909441ac8 TEXT;
  p_Type_229909441ac8 VARCHAR(20);
  p_DefaultValue_229909441ac8 TEXT;
  p_IsRequired_229909441ac8 BOOLEAN;
  p_LinkedParameterName_229909441ac8 VARCHAR(255);
  p_LinkedParameterField_229909441ac8 VARCHAR(500);
  p_ExtraFilter_229909441ac8 TEXT;
  p_EntityID_229909441ac8 UUID;
  p_RecordID_229909441ac8 VARCHAR(2000);
  p_OrderBy_229909441ac8 TEXT;
  p_TemplateContentID_229909441ac8 UUID;
BEGIN
  p_ID_229909441ac8 := '37c5de4d-e61d-4894-82a3-32b38ad267e6';
  p_TemplateID_229909441ac8 := 'F11535E9-DD0C-4E78-8F93-C681C9B820BF';
  p_Name_229909441ac8 := 'attendeesJson';
  p_Description_229909441ac8 := 'Template scalar parameter ''attendeesJson''';
  p_Type_229909441ac8 := 'Scalar';
  p_IsRequired_229909441ac8 := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateParam"
                 WHERE "ID" = p_ID_229909441ac8
                    OR ("TemplateID" = p_TemplateID_229909441ac8 AND "Name" = p_Name_229909441ac8)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_data := jsonb_build_object(
    'ID', p_ID_229909441ac8,
    'TemplateID', p_TemplateID_229909441ac8,
    'Name', p_Name_229909441ac8,
    'Description', p_Description_229909441ac8,
    'Type', p_Type_229909441ac8,
    'DefaultValue', p_DefaultValue_229909441ac8,
    'IsRequired', p_IsRequired_229909441ac8,
    'LinkedParameterName', p_LinkedParameterName_229909441ac8,
    'LinkedParameterField', p_LinkedParameterField_229909441ac8,
    'ExtraFilter', p_ExtraFilter_229909441ac8,
    'EntityID', p_EntityID_229909441ac8,
    'RecordID', p_RecordID_229909441ac8,
    'OrderBy', p_OrderBy_229909441ac8,
    'TemplateContentID', p_TemplateContentID_229909441ac8
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_ID := p_ID_229909441ac8, p_TemplateID := p_TemplateID_229909441ac8, p_Name := p_Name_229909441ac8, p_Description := p_Description_229909441ac8, p_Type := p_Type_229909441ac8, p_DefaultValue := p_DefaultValue_229909441ac8, p_DefaultValue_Clear := TRUE, p_IsRequired := p_IsRequired_229909441ac8, p_LinkedParameterName := p_LinkedParameterName_229909441ac8, p_LinkedParameterName_Clear := TRUE, p_LinkedParameterField := p_LinkedParameterField_229909441ac8, p_LinkedParameterField_Clear := TRUE, p_ExtraFilter := p_ExtraFilter_229909441ac8, p_ExtraFilter_Clear := TRUE, p_EntityID := p_EntityID_229909441ac8, p_EntityID_Clear := TRUE, p_RecordID := p_RecordID_229909441ac8, p_RecordID_Clear := TRUE, p_OrderBy := p_OrderBy_229909441ac8, p_OrderBy_Clear := TRUE, p_TemplateContentID := p_TemplateContentID_229909441ac8, p_TemplateContentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Params (core SP call only)
DO $mj$
DECLARE
  p_ID_ec72258480b2 UUID;
  p_TemplateID_ec72258480b2 UUID;
  p_Name_ec72258480b2 VARCHAR(255);
  p_Description_ec72258480b2 TEXT;
  p_Type_ec72258480b2 VARCHAR(20);
  p_DefaultValue_ec72258480b2 TEXT;
  p_IsRequired_ec72258480b2 BOOLEAN;
  p_LinkedParameterName_ec72258480b2 VARCHAR(255);
  p_LinkedParameterField_ec72258480b2 VARCHAR(500);
  p_ExtraFilter_ec72258480b2 TEXT;
  p_EntityID_ec72258480b2 UUID;
  p_RecordID_ec72258480b2 VARCHAR(2000);
  p_OrderBy_ec72258480b2 TEXT;
  p_TemplateContentID_ec72258480b2 UUID;
BEGIN
  p_ID_ec72258480b2 := 'cf83afdd-5b54-41b6-ac53-54b58e7cf57a';
  p_TemplateID_ec72258480b2 := 'F11535E9-DD0C-4E78-8F93-C681C9B820BF';
  p_Name_ec72258480b2 := 'endsAt';
  p_Description_ec72258480b2 := 'Template scalar parameter ''endsAt''';
  p_Type_ec72258480b2 := 'Scalar';
  p_IsRequired_ec72258480b2 := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateParam"
                 WHERE "ID" = p_ID_ec72258480b2
                    OR ("TemplateID" = p_TemplateID_ec72258480b2 AND "Name" = p_Name_ec72258480b2)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_data := jsonb_build_object(
    'ID', p_ID_ec72258480b2,
    'TemplateID', p_TemplateID_ec72258480b2,
    'Name', p_Name_ec72258480b2,
    'Description', p_Description_ec72258480b2,
    'Type', p_Type_ec72258480b2,
    'DefaultValue', p_DefaultValue_ec72258480b2,
    'IsRequired', p_IsRequired_ec72258480b2,
    'LinkedParameterName', p_LinkedParameterName_ec72258480b2,
    'LinkedParameterField', p_LinkedParameterField_ec72258480b2,
    'ExtraFilter', p_ExtraFilter_ec72258480b2,
    'EntityID', p_EntityID_ec72258480b2,
    'RecordID', p_RecordID_ec72258480b2,
    'OrderBy', p_OrderBy_ec72258480b2,
    'TemplateContentID', p_TemplateContentID_ec72258480b2
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_ID := p_ID_ec72258480b2, p_TemplateID := p_TemplateID_ec72258480b2, p_Name := p_Name_ec72258480b2, p_Description := p_Description_ec72258480b2, p_Type := p_Type_ec72258480b2, p_DefaultValue := p_DefaultValue_ec72258480b2, p_DefaultValue_Clear := TRUE, p_IsRequired := p_IsRequired_ec72258480b2, p_LinkedParameterName := p_LinkedParameterName_ec72258480b2, p_LinkedParameterName_Clear := TRUE, p_LinkedParameterField := p_LinkedParameterField_ec72258480b2, p_LinkedParameterField_Clear := TRUE, p_ExtraFilter := p_ExtraFilter_ec72258480b2, p_ExtraFilter_Clear := TRUE, p_EntityID := p_EntityID_ec72258480b2, p_EntityID_Clear := TRUE, p_RecordID := p_RecordID_ec72258480b2, p_RecordID_Clear := TRUE, p_OrderBy := p_OrderBy_ec72258480b2, p_OrderBy_Clear := TRUE, p_TemplateContentID := p_TemplateContentID_ec72258480b2, p_TemplateContentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Params (core SP call only)
DO $mj$
DECLARE
  p_ID_edb419622837 UUID;
  p_TemplateID_edb419622837 UUID;
  p_Name_edb419622837 VARCHAR(255);
  p_Description_edb419622837 TEXT;
  p_Type_edb419622837 VARCHAR(20);
  p_DefaultValue_edb419622837 TEXT;
  p_IsRequired_edb419622837 BOOLEAN;
  p_LinkedParameterName_edb419622837 VARCHAR(255);
  p_LinkedParameterField_edb419622837 VARCHAR(500);
  p_ExtraFilter_edb419622837 TEXT;
  p_EntityID_edb419622837 UUID;
  p_RecordID_edb419622837 VARCHAR(2000);
  p_OrderBy_edb419622837 TEXT;
  p_TemplateContentID_edb419622837 UUID;
BEGIN
  p_ID_edb419622837 := '979eface-113e-4ff8-8d70-46518208cac9';
  p_TemplateID_edb419622837 := 'F11535E9-DD0C-4E78-8F93-C681C9B820BF';
  p_Name_edb419622837 := 'meetingDescription';
  p_Description_edb419622837 := 'Template scalar parameter ''meetingDescription''';
  p_Type_edb419622837 := 'Scalar';
  p_IsRequired_edb419622837 := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateParam"
                 WHERE "ID" = p_ID_edb419622837
                    OR ("TemplateID" = p_TemplateID_edb419622837 AND "Name" = p_Name_edb419622837)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_data := jsonb_build_object(
    'ID', p_ID_edb419622837,
    'TemplateID', p_TemplateID_edb419622837,
    'Name', p_Name_edb419622837,
    'Description', p_Description_edb419622837,
    'Type', p_Type_edb419622837,
    'DefaultValue', p_DefaultValue_edb419622837,
    'IsRequired', p_IsRequired_edb419622837,
    'LinkedParameterName', p_LinkedParameterName_edb419622837,
    'LinkedParameterField', p_LinkedParameterField_edb419622837,
    'ExtraFilter', p_ExtraFilter_edb419622837,
    'EntityID', p_EntityID_edb419622837,
    'RecordID', p_RecordID_edb419622837,
    'OrderBy', p_OrderBy_edb419622837,
    'TemplateContentID', p_TemplateContentID_edb419622837
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_ID := p_ID_edb419622837, p_TemplateID := p_TemplateID_edb419622837, p_Name := p_Name_edb419622837, p_Description := p_Description_edb419622837, p_Type := p_Type_edb419622837, p_DefaultValue := p_DefaultValue_edb419622837, p_DefaultValue_Clear := TRUE, p_IsRequired := p_IsRequired_edb419622837, p_LinkedParameterName := p_LinkedParameterName_edb419622837, p_LinkedParameterName_Clear := TRUE, p_LinkedParameterField := p_LinkedParameterField_edb419622837, p_LinkedParameterField_Clear := TRUE, p_ExtraFilter := p_ExtraFilter_edb419622837, p_ExtraFilter_Clear := TRUE, p_EntityID := p_EntityID_edb419622837, p_EntityID_Clear := TRUE, p_RecordID := p_RecordID_edb419622837, p_RecordID_Clear := TRUE, p_OrderBy := p_OrderBy_edb419622837, p_OrderBy_Clear := TRUE, p_TemplateContentID := p_TemplateContentID_edb419622837, p_TemplateContentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Params (core SP call only)
DO $mj$
DECLARE
  p_ID_d5c21262872e UUID;
  p_TemplateID_d5c21262872e UUID;
  p_Name_d5c21262872e VARCHAR(255);
  p_Description_d5c21262872e TEXT;
  p_Type_d5c21262872e VARCHAR(20);
  p_DefaultValue_d5c21262872e TEXT;
  p_IsRequired_d5c21262872e BOOLEAN;
  p_LinkedParameterName_d5c21262872e VARCHAR(255);
  p_LinkedParameterField_d5c21262872e VARCHAR(500);
  p_ExtraFilter_d5c21262872e TEXT;
  p_EntityID_d5c21262872e UUID;
  p_RecordID_d5c21262872e VARCHAR(2000);
  p_OrderBy_d5c21262872e TEXT;
  p_TemplateContentID_d5c21262872e UUID;
BEGIN
  p_ID_d5c21262872e := '06d12038-38dc-433e-a257-b91903072fe1';
  p_TemplateID_d5c21262872e := 'F11535E9-DD0C-4E78-8F93-C681C9B820BF';
  p_Name_d5c21262872e := 'meetingName';
  p_Description_d5c21262872e := 'Template scalar parameter ''meetingName''';
  p_Type_d5c21262872e := 'Scalar';
  p_IsRequired_d5c21262872e := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateParam"
                 WHERE "ID" = p_ID_d5c21262872e
                    OR ("TemplateID" = p_TemplateID_d5c21262872e AND "Name" = p_Name_d5c21262872e)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_data := jsonb_build_object(
    'ID', p_ID_d5c21262872e,
    'TemplateID', p_TemplateID_d5c21262872e,
    'Name', p_Name_d5c21262872e,
    'Description', p_Description_d5c21262872e,
    'Type', p_Type_d5c21262872e,
    'DefaultValue', p_DefaultValue_d5c21262872e,
    'IsRequired', p_IsRequired_d5c21262872e,
    'LinkedParameterName', p_LinkedParameterName_d5c21262872e,
    'LinkedParameterField', p_LinkedParameterField_d5c21262872e,
    'ExtraFilter', p_ExtraFilter_d5c21262872e,
    'EntityID', p_EntityID_d5c21262872e,
    'RecordID', p_RecordID_d5c21262872e,
    'OrderBy', p_OrderBy_d5c21262872e,
    'TemplateContentID', p_TemplateContentID_d5c21262872e
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_ID := p_ID_d5c21262872e, p_TemplateID := p_TemplateID_d5c21262872e, p_Name := p_Name_d5c21262872e, p_Description := p_Description_d5c21262872e, p_Type := p_Type_d5c21262872e, p_DefaultValue := p_DefaultValue_d5c21262872e, p_DefaultValue_Clear := TRUE, p_IsRequired := p_IsRequired_d5c21262872e, p_LinkedParameterName := p_LinkedParameterName_d5c21262872e, p_LinkedParameterName_Clear := TRUE, p_LinkedParameterField := p_LinkedParameterField_d5c21262872e, p_LinkedParameterField_Clear := TRUE, p_ExtraFilter := p_ExtraFilter_d5c21262872e, p_ExtraFilter_Clear := TRUE, p_EntityID := p_EntityID_d5c21262872e, p_EntityID_Clear := TRUE, p_RecordID := p_RecordID_d5c21262872e, p_RecordID_Clear := TRUE, p_OrderBy := p_OrderBy_d5c21262872e, p_OrderBy_Clear := TRUE, p_TemplateContentID := p_TemplateContentID_d5c21262872e, p_TemplateContentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Params (core SP call only)
DO $mj$
DECLARE
  p_ID_1c925fd58a4a UUID;
  p_TemplateID_1c925fd58a4a UUID;
  p_Name_1c925fd58a4a VARCHAR(255);
  p_Description_1c925fd58a4a TEXT;
  p_Type_1c925fd58a4a VARCHAR(20);
  p_DefaultValue_1c925fd58a4a TEXT;
  p_IsRequired_1c925fd58a4a BOOLEAN;
  p_LinkedParameterName_1c925fd58a4a VARCHAR(255);
  p_LinkedParameterField_1c925fd58a4a VARCHAR(500);
  p_ExtraFilter_1c925fd58a4a TEXT;
  p_EntityID_1c925fd58a4a UUID;
  p_RecordID_1c925fd58a4a VARCHAR(2000);
  p_OrderBy_1c925fd58a4a TEXT;
  p_TemplateContentID_1c925fd58a4a UUID;
BEGIN
  p_ID_1c925fd58a4a := '3311abd8-6f29-44c6-b326-c2816444978b';
  p_TemplateID_1c925fd58a4a := 'F11535E9-DD0C-4E78-8F93-C681C9B820BF';
  p_Name_1c925fd58a4a := 'startsAt';
  p_Description_1c925fd58a4a := 'Template scalar parameter ''startsAt''';
  p_Type_1c925fd58a4a := 'Scalar';
  p_IsRequired_1c925fd58a4a := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateParam"
                 WHERE "ID" = p_ID_1c925fd58a4a
                    OR ("TemplateID" = p_TemplateID_1c925fd58a4a AND "Name" = p_Name_1c925fd58a4a)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_data := jsonb_build_object(
    'ID', p_ID_1c925fd58a4a,
    'TemplateID', p_TemplateID_1c925fd58a4a,
    'Name', p_Name_1c925fd58a4a,
    'Description', p_Description_1c925fd58a4a,
    'Type', p_Type_1c925fd58a4a,
    'DefaultValue', p_DefaultValue_1c925fd58a4a,
    'IsRequired', p_IsRequired_1c925fd58a4a,
    'LinkedParameterName', p_LinkedParameterName_1c925fd58a4a,
    'LinkedParameterField', p_LinkedParameterField_1c925fd58a4a,
    'ExtraFilter', p_ExtraFilter_1c925fd58a4a,
    'EntityID', p_EntityID_1c925fd58a4a,
    'RecordID', p_RecordID_1c925fd58a4a,
    'OrderBy', p_OrderBy_1c925fd58a4a,
    'TemplateContentID', p_TemplateContentID_1c925fd58a4a
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_ID := p_ID_1c925fd58a4a, p_TemplateID := p_TemplateID_1c925fd58a4a, p_Name := p_Name_1c925fd58a4a, p_Description := p_Description_1c925fd58a4a, p_Type := p_Type_1c925fd58a4a, p_DefaultValue := p_DefaultValue_1c925fd58a4a, p_DefaultValue_Clear := TRUE, p_IsRequired := p_IsRequired_1c925fd58a4a, p_LinkedParameterName := p_LinkedParameterName_1c925fd58a4a, p_LinkedParameterName_Clear := TRUE, p_LinkedParameterField := p_LinkedParameterField_1c925fd58a4a, p_LinkedParameterField_Clear := TRUE, p_ExtraFilter := p_ExtraFilter_1c925fd58a4a, p_ExtraFilter_Clear := TRUE, p_EntityID := p_EntityID_1c925fd58a4a, p_EntityID_Clear := TRUE, p_RecordID := p_RecordID_1c925fd58a4a, p_RecordID_Clear := TRUE, p_OrderBy := p_OrderBy_1c925fd58a4a, p_OrderBy_Clear := TRUE, p_TemplateContentID := p_TemplateContentID_1c925fd58a4a, p_TemplateContentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Params (core SP call only)
DO $mj$
DECLARE
  p_ID_c82157ec867a UUID;
  p_TemplateID_c82157ec867a UUID;
  p_Name_c82157ec867a VARCHAR(255);
  p_Description_c82157ec867a TEXT;
  p_Type_c82157ec867a VARCHAR(20);
  p_DefaultValue_c82157ec867a TEXT;
  p_IsRequired_c82157ec867a BOOLEAN;
  p_LinkedParameterName_c82157ec867a VARCHAR(255);
  p_LinkedParameterField_c82157ec867a VARCHAR(500);
  p_ExtraFilter_c82157ec867a TEXT;
  p_EntityID_c82157ec867a UUID;
  p_RecordID_c82157ec867a VARCHAR(2000);
  p_OrderBy_c82157ec867a TEXT;
  p_TemplateContentID_c82157ec867a UUID;
BEGIN
  p_ID_c82157ec867a := '0b061e61-b2ea-482c-b802-0d045740ac38';
  p_TemplateID_c82157ec867a := 'F11535E9-DD0C-4E78-8F93-C681C9B820BF';
  p_Name_c82157ec867a := 'timeZone';
  p_Description_c82157ec867a := 'Template scalar parameter ''timeZone''';
  p_Type_c82157ec867a := 'Scalar';
  p_IsRequired_c82157ec867a := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateParam"
                 WHERE "ID" = p_ID_c82157ec867a
                    OR ("TemplateID" = p_TemplateID_c82157ec867a AND "Name" = p_Name_c82157ec867a)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_data := jsonb_build_object(
    'ID', p_ID_c82157ec867a,
    'TemplateID', p_TemplateID_c82157ec867a,
    'Name', p_Name_c82157ec867a,
    'Description', p_Description_c82157ec867a,
    'Type', p_Type_c82157ec867a,
    'DefaultValue', p_DefaultValue_c82157ec867a,
    'IsRequired', p_IsRequired_c82157ec867a,
    'LinkedParameterName', p_LinkedParameterName_c82157ec867a,
    'LinkedParameterField', p_LinkedParameterField_c82157ec867a,
    'ExtraFilter', p_ExtraFilter_c82157ec867a,
    'EntityID', p_EntityID_c82157ec867a,
    'RecordID', p_RecordID_c82157ec867a,
    'OrderBy', p_OrderBy_c82157ec867a,
    'TemplateContentID', p_TemplateContentID_c82157ec867a
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_ID := p_ID_c82157ec867a, p_TemplateID := p_TemplateID_c82157ec867a, p_Name := p_Name_c82157ec867a, p_Description := p_Description_c82157ec867a, p_Type := p_Type_c82157ec867a, p_DefaultValue := p_DefaultValue_c82157ec867a, p_DefaultValue_Clear := TRUE, p_IsRequired := p_IsRequired_c82157ec867a, p_LinkedParameterName := p_LinkedParameterName_c82157ec867a, p_LinkedParameterName_Clear := TRUE, p_LinkedParameterField := p_LinkedParameterField_c82157ec867a, p_LinkedParameterField_Clear := TRUE, p_ExtraFilter := p_ExtraFilter_c82157ec867a, p_ExtraFilter_Clear := TRUE, p_EntityID := p_EntityID_c82157ec867a, p_EntityID_Clear := TRUE, p_RecordID := p_RecordID_c82157ec867a, p_RecordID_Clear := TRUE, p_OrderBy := p_OrderBy_c82157ec867a, p_OrderBy_Clear := TRUE, p_TemplateContentID := p_TemplateContentID_c82157ec867a, p_TemplateContentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Params (core SP call only)
DO $mj$
DECLARE
  p_ID_973f006468ee UUID;
  p_TemplateID_973f006468ee UUID;
  p_Name_973f006468ee VARCHAR(255);
  p_Description_973f006468ee TEXT;
  p_Type_973f006468ee VARCHAR(20);
  p_DefaultValue_973f006468ee TEXT;
  p_IsRequired_973f006468ee BOOLEAN;
  p_LinkedParameterName_973f006468ee VARCHAR(255);
  p_LinkedParameterField_973f006468ee VARCHAR(500);
  p_ExtraFilter_973f006468ee TEXT;
  p_EntityID_973f006468ee UUID;
  p_RecordID_973f006468ee VARCHAR(2000);
  p_OrderBy_973f006468ee TEXT;
  p_TemplateContentID_973f006468ee UUID;
BEGIN
  p_ID_973f006468ee := 'f53285b4-5ecc-4a57-b3d7-e3d2767870e4';
  p_TemplateID_973f006468ee := 'F11535E9-DD0C-4E78-8F93-C681C9B820BF';
  p_Name_973f006468ee := 'transcript';
  p_Description_973f006468ee := 'Template scalar parameter ''transcript''';
  p_Type_973f006468ee := 'Scalar';
  p_IsRequired_973f006468ee := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateParam"
                 WHERE "ID" = p_ID_973f006468ee
                    OR ("TemplateID" = p_TemplateID_973f006468ee AND "Name" = p_Name_973f006468ee)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_data := jsonb_build_object(
    'ID', p_ID_973f006468ee,
    'TemplateID', p_TemplateID_973f006468ee,
    'Name', p_Name_973f006468ee,
    'Description', p_Description_973f006468ee,
    'Type', p_Type_973f006468ee,
    'DefaultValue', p_DefaultValue_973f006468ee,
    'IsRequired', p_IsRequired_973f006468ee,
    'LinkedParameterName', p_LinkedParameterName_973f006468ee,
    'LinkedParameterField', p_LinkedParameterField_973f006468ee,
    'ExtraFilter', p_ExtraFilter_973f006468ee,
    'EntityID', p_EntityID_973f006468ee,
    'RecordID', p_RecordID_973f006468ee,
    'OrderBy', p_OrderBy_973f006468ee,
    'TemplateContentID', p_TemplateContentID_973f006468ee
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_ID := p_ID_973f006468ee, p_TemplateID := p_TemplateID_973f006468ee, p_Name := p_Name_973f006468ee, p_Description := p_Description_973f006468ee, p_Type := p_Type_973f006468ee, p_DefaultValue := p_DefaultValue_973f006468ee, p_DefaultValue_Clear := TRUE, p_IsRequired := p_IsRequired_973f006468ee, p_LinkedParameterName := p_LinkedParameterName_973f006468ee, p_LinkedParameterName_Clear := TRUE, p_LinkedParameterField := p_LinkedParameterField_973f006468ee, p_LinkedParameterField_Clear := TRUE, p_ExtraFilter := p_ExtraFilter_973f006468ee, p_ExtraFilter_Clear := TRUE, p_EntityID := p_EntityID_973f006468ee, p_EntityID_Clear := TRUE, p_RecordID := p_RecordID_973f006468ee, p_RecordID_Clear := TRUE, p_OrderBy := p_OrderBy_973f006468ee, p_OrderBy_Clear := TRUE, p_TemplateContentID := p_TemplateContentID_973f006468ee, p_TemplateContentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: AI Prompts (core SP call only)
DO $mj$
DECLARE
  p_ID_2aec00d7b99f UUID;
  p_Name_2aec00d7b99f VARCHAR(255);
  p_Description_2aec00d7b99f TEXT;
  p_TemplateID_2aec00d7b99f UUID;
  p_CategoryID_2aec00d7b99f UUID;
  p_TypeID_2aec00d7b99f UUID;
  p_Status_2aec00d7b99f VARCHAR(50);
  p_ResponseFormat_2aec00d7b99f VARCHAR(20);
  p_ModelSpecificResponseFormat_2aec00d7b99f TEXT;
  p_AIModelTypeID_2aec00d7b99f UUID;
  p_MinPowerRank_2aec00d7b99f INTEGER;
  p_SelectionStrategy_2aec00d7b99f VARCHAR(20);
  p_PowerPreference_2aec00d7b99f VARCHAR(20);
  p_ParallelizationMode_2aec00d7b99f VARCHAR(20);
  p_ParallelCount_2aec00d7b99f INTEGER;
  p_ParallelConfigParam_2aec00d7b99f VARCHAR(100);
  p_OutputType_2aec00d7b99f VARCHAR(50);
  p_OutputExample_2aec00d7b99f TEXT;
  p_ValidationBehavior_2aec00d7b99f VARCHAR(50);
  p_MaxRetries_2aec00d7b99f INTEGER;
  p_RetryDelayMS_2aec00d7b99f INTEGER;
  p_RetryStrategy_2aec00d7b99f VARCHAR(20);
  p_ResultSelectorPromptID_2aec00d7b99f UUID;
  p_EnableCaching_2aec00d7b99f BOOLEAN;
  p_CacheTTLSeconds_2aec00d7b99f INTEGER;
  p_CacheMatchType_2aec00d7b99f VARCHAR(20);
  p_CacheSimilarityThreshold_2aec00d7b99f DOUBLE PRECISION;
  p_CacheMustMatchModel_2aec00d7b99f BOOLEAN;
  p_CacheMustMatchVendor_2aec00d7b99f BOOLEAN;
  p_CacheMustMatchAgent_2aec00d7b99f BOOLEAN;
  p_CacheMustMatchConfig_2aec00d7b99f BOOLEAN;
  p_PromptRole_2aec00d7b99f VARCHAR(20);
  p_PromptPosition_2aec00d7b99f VARCHAR(20);
  p_Temperature_2aec00d7b99f NUMERIC(3,2);
  p_TopP_2aec00d7b99f NUMERIC(3,2);
  p_TopK_2aec00d7b99f INTEGER;
  p_MinP_2aec00d7b99f NUMERIC(3,2);
  p_FrequencyPenalty_2aec00d7b99f NUMERIC(3,2);
  p_PresencePenalty_2aec00d7b99f NUMERIC(3,2);
  p_Seed_2aec00d7b99f INTEGER;
  p_StopSequences_2aec00d7b99f VARCHAR(1000);
  p_IncludeLogProbs_2aec00d7b99f BOOLEAN;
  p_TopLogProbs_2aec00d7b99f INTEGER;
  p_FailoverStrategy_2aec00d7b99f VARCHAR(50);
  p_FailoverMaxAttempts_2aec00d7b99f INTEGER;
  p_FailoverDelaySeconds_2aec00d7b99f INTEGER;
  p_FailoverModelStrategy_2aec00d7b99f VARCHAR(50);
  p_FailoverErrorScope_2aec00d7b99f VARCHAR(50);
  p_EffortLevel_2aec00d7b99f INTEGER;
  p_AssistantPrefill_2aec00d7b99f TEXT;
  p_PrefillFallbackMode_2aec00d7b99f VARCHAR(20);
  p_RequireSpecificModels_2aec00d7b99f BOOLEAN;
  p_PromptConfiguration_2aec00d7b99f TEXT;
  p_TemplateDataCapture_2aec00d7b99f VARCHAR(20);
BEGIN
  p_ID_2aec00d7b99f := 'E1A00001-0000-4000-8000-000000000001';
  p_Name_2aec00d7b99f := 'Tasks: Meeting Notes from Transcript';
  p_Description_2aec00d7b99f := 'Summarizes a meeting transcript into structured Markdown notes and extracts proposed action items (ProposedTasks) with optional assignee and due date.';
  p_TemplateID_2aec00d7b99f := 'F11535E9-DD0C-4E78-8F93-C681C9B820BF';
  p_TypeID_2aec00d7b99f := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."AIPromptType"
    WHERE
      LOWER("Name") = LOWER('Chat')
  );
  p_Status_2aec00d7b99f := 'Active';
  p_ResponseFormat_2aec00d7b99f := 'JSON';
  p_MinPowerRank_2aec00d7b99f := 0;
  p_SelectionStrategy_2aec00d7b99f := 'Default';
  p_PowerPreference_2aec00d7b99f := 'Highest';
  p_ParallelizationMode_2aec00d7b99f := 'None';
  p_OutputType_2aec00d7b99f := 'string';
  p_ValidationBehavior_2aec00d7b99f := 'Warn';
  p_MaxRetries_2aec00d7b99f := 0;
  p_RetryDelayMS_2aec00d7b99f := 0;
  p_RetryStrategy_2aec00d7b99f := 'Fixed';
  p_EnableCaching_2aec00d7b99f := FALSE;
  p_CacheMatchType_2aec00d7b99f := 'Exact';
  p_CacheMustMatchModel_2aec00d7b99f := TRUE;
  p_CacheMustMatchVendor_2aec00d7b99f := TRUE;
  p_CacheMustMatchAgent_2aec00d7b99f := FALSE;
  p_CacheMustMatchConfig_2aec00d7b99f := FALSE;
  p_PromptRole_2aec00d7b99f := 'System';
  p_PromptPosition_2aec00d7b99f := 'First';
  p_IncludeLogProbs_2aec00d7b99f := FALSE;
  p_FailoverStrategy_2aec00d7b99f := 'SameModelDifferentVendor';
  p_FailoverMaxAttempts_2aec00d7b99f := 3;
  p_FailoverDelaySeconds_2aec00d7b99f := 5;
  p_FailoverModelStrategy_2aec00d7b99f := 'PreferSameModel';
  p_FailoverErrorScope_2aec00d7b99f := 'All';
  p_PrefillFallbackMode_2aec00d7b99f := 'Ignore';
  p_RequireSpecificModels_2aec00d7b99f := FALSE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."AIPrompt"
                 WHERE "ID" = p_ID_2aec00d7b99f
                    OR ("Name" = p_Name_2aec00d7b99f)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateAIPrompt'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateAIPrompt"(p_data := jsonb_build_object(
    'ID', p_ID_2aec00d7b99f,
    'Name', p_Name_2aec00d7b99f,
    'Description', p_Description_2aec00d7b99f,
    'TemplateID', p_TemplateID_2aec00d7b99f,
    'CategoryID', p_CategoryID_2aec00d7b99f,
    'TypeID', p_TypeID_2aec00d7b99f,
    'Status', p_Status_2aec00d7b99f,
    'ResponseFormat', p_ResponseFormat_2aec00d7b99f,
    'ModelSpecificResponseFormat', p_ModelSpecificResponseFormat_2aec00d7b99f,
    'AIModelTypeID', p_AIModelTypeID_2aec00d7b99f,
    'MinPowerRank', p_MinPowerRank_2aec00d7b99f,
    'SelectionStrategy', p_SelectionStrategy_2aec00d7b99f,
    'PowerPreference', p_PowerPreference_2aec00d7b99f,
    'ParallelizationMode', p_ParallelizationMode_2aec00d7b99f,
    'ParallelCount', p_ParallelCount_2aec00d7b99f,
    'ParallelConfigParam', p_ParallelConfigParam_2aec00d7b99f,
    'OutputType', p_OutputType_2aec00d7b99f,
    'OutputExample', p_OutputExample_2aec00d7b99f,
    'ValidationBehavior', p_ValidationBehavior_2aec00d7b99f,
    'MaxRetries', p_MaxRetries_2aec00d7b99f,
    'RetryDelayMS', p_RetryDelayMS_2aec00d7b99f,
    'RetryStrategy', p_RetryStrategy_2aec00d7b99f,
    'ResultSelectorPromptID', p_ResultSelectorPromptID_2aec00d7b99f,
    'EnableCaching', p_EnableCaching_2aec00d7b99f,
    'CacheTTLSeconds', p_CacheTTLSeconds_2aec00d7b99f,
    'CacheMatchType', p_CacheMatchType_2aec00d7b99f,
    'CacheSimilarityThreshold', p_CacheSimilarityThreshold_2aec00d7b99f,
    'CacheMustMatchModel', p_CacheMustMatchModel_2aec00d7b99f,
    'CacheMustMatchVendor', p_CacheMustMatchVendor_2aec00d7b99f,
    'CacheMustMatchAgent', p_CacheMustMatchAgent_2aec00d7b99f,
    'CacheMustMatchConfig', p_CacheMustMatchConfig_2aec00d7b99f,
    'PromptRole', p_PromptRole_2aec00d7b99f,
    'PromptPosition', p_PromptPosition_2aec00d7b99f,
    'Temperature', p_Temperature_2aec00d7b99f,
    'TopP', p_TopP_2aec00d7b99f,
    'TopK', p_TopK_2aec00d7b99f,
    'MinP', p_MinP_2aec00d7b99f,
    'FrequencyPenalty', p_FrequencyPenalty_2aec00d7b99f,
    'PresencePenalty', p_PresencePenalty_2aec00d7b99f,
    'Seed', p_Seed_2aec00d7b99f,
    'StopSequences', p_StopSequences_2aec00d7b99f,
    'IncludeLogProbs', p_IncludeLogProbs_2aec00d7b99f,
    'TopLogProbs', p_TopLogProbs_2aec00d7b99f,
    'FailoverStrategy', p_FailoverStrategy_2aec00d7b99f,
    'FailoverMaxAttempts', p_FailoverMaxAttempts_2aec00d7b99f,
    'FailoverDelaySeconds', p_FailoverDelaySeconds_2aec00d7b99f,
    'FailoverModelStrategy', p_FailoverModelStrategy_2aec00d7b99f,
    'FailoverErrorScope', p_FailoverErrorScope_2aec00d7b99f,
    'EffortLevel', p_EffortLevel_2aec00d7b99f,
    'AssistantPrefill', p_AssistantPrefill_2aec00d7b99f
  ) ||
  jsonb_build_object(
    'PrefillFallbackMode', p_PrefillFallbackMode_2aec00d7b99f,
    'RequireSpecificModels', p_RequireSpecificModels_2aec00d7b99f,
    'PromptConfiguration', p_PromptConfiguration_2aec00d7b99f,
    'TemplateDataCapture', p_TemplateDataCapture_2aec00d7b99f
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateAIPrompt"(p_ID := p_ID_2aec00d7b99f, p_Name := p_Name_2aec00d7b99f, p_Description := p_Description_2aec00d7b99f, p_TemplateID := p_TemplateID_2aec00d7b99f, p_CategoryID := p_CategoryID_2aec00d7b99f, p_CategoryID_Clear := TRUE, p_TypeID := p_TypeID_2aec00d7b99f, p_Status := p_Status_2aec00d7b99f, p_ResponseFormat := p_ResponseFormat_2aec00d7b99f, p_ModelSpecificResponseFormat := p_ModelSpecificResponseFormat_2aec00d7b99f, p_ModelSpecificResponseFormat_Clear := TRUE, p_AIModelTypeID := p_AIModelTypeID_2aec00d7b99f, p_AIModelTypeID_Clear := TRUE, p_MinPowerRank := p_MinPowerRank_2aec00d7b99f, p_SelectionStrategy := p_SelectionStrategy_2aec00d7b99f, p_PowerPreference := p_PowerPreference_2aec00d7b99f, p_ParallelizationMode := p_ParallelizationMode_2aec00d7b99f, p_ParallelCount := p_ParallelCount_2aec00d7b99f, p_ParallelCount_Clear := TRUE, p_ParallelConfigParam := p_ParallelConfigParam_2aec00d7b99f, p_ParallelConfigParam_Clear := TRUE, p_OutputType := p_OutputType_2aec00d7b99f, p_OutputExample := p_OutputExample_2aec00d7b99f, p_OutputExample_Clear := TRUE, p_ValidationBehavior := p_ValidationBehavior_2aec00d7b99f, p_MaxRetries := p_MaxRetries_2aec00d7b99f, p_RetryDelayMS := p_RetryDelayMS_2aec00d7b99f, p_RetryStrategy := p_RetryStrategy_2aec00d7b99f, p_ResultSelectorPromptID := p_ResultSelectorPromptID_2aec00d7b99f, p_ResultSelectorPromptID_Clear := TRUE, p_EnableCaching := p_EnableCaching_2aec00d7b99f, p_CacheTTLSeconds := p_CacheTTLSeconds_2aec00d7b99f, p_CacheTTLSeconds_Clear := TRUE, p_CacheMatchType := p_CacheMatchType_2aec00d7b99f, p_CacheSimilarityThreshold := p_CacheSimilarityThreshold_2aec00d7b99f, p_CacheSimilarityThreshold_Clear := TRUE, p_CacheMustMatchModel := p_CacheMustMatchModel_2aec00d7b99f, p_CacheMustMatchVendor := p_CacheMustMatchVendor_2aec00d7b99f, p_CacheMustMatchAgent := p_CacheMustMatchAgent_2aec00d7b99f, p_CacheMustMatchConfig := p_CacheMustMatchConfig_2aec00d7b99f, p_PromptRole := p_PromptRole_2aec00d7b99f, p_PromptPosition := p_PromptPosition_2aec00d7b99f, p_Temperature := p_Temperature_2aec00d7b99f, p_Temperature_Clear := TRUE, p_TopP := p_TopP_2aec00d7b99f, p_TopP_Clear := TRUE, p_TopK := p_TopK_2aec00d7b99f, p_TopK_Clear := TRUE, p_MinP := p_MinP_2aec00d7b99f, p_MinP_Clear := TRUE, p_FrequencyPenalty := p_FrequencyPenalty_2aec00d7b99f, p_FrequencyPenalty_Clear := TRUE, p_PresencePenalty := p_PresencePenalty_2aec00d7b99f, p_PresencePenalty_Clear := TRUE, p_Seed := p_Seed_2aec00d7b99f, p_Seed_Clear := TRUE, p_StopSequences := p_StopSequences_2aec00d7b99f, p_StopSequences_Clear := TRUE, p_IncludeLogProbs := p_IncludeLogProbs_2aec00d7b99f, p_TopLogProbs := p_TopLogProbs_2aec00d7b99f, p_TopLogProbs_Clear := TRUE, p_FailoverStrategy := p_FailoverStrategy_2aec00d7b99f, p_FailoverMaxAttempts := p_FailoverMaxAttempts_2aec00d7b99f, p_FailoverDelaySeconds := p_FailoverDelaySeconds_2aec00d7b99f, p_FailoverModelStrategy := p_FailoverModelStrategy_2aec00d7b99f, p_FailoverErrorScope := p_FailoverErrorScope_2aec00d7b99f, p_EffortLevel := p_EffortLevel_2aec00d7b99f, p_EffortLevel_Clear := TRUE, p_AssistantPrefill := p_AssistantPrefill_2aec00d7b99f, p_AssistantPrefill_Clear := TRUE, p_PrefillFallbackMode := p_PrefillFallbackMode_2aec00d7b99f, p_RequireSpecificModels := p_RequireSpecificModels_2aec00d7b99f, p_PromptConfiguration := p_PromptConfiguration_2aec00d7b99f, p_PromptConfiguration_Clear := TRUE, p_TemplateDataCapture := p_TemplateDataCapture_2aec00d7b99f, p_TemplateDataCapture_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Templates (core SP call only)
DO $mj$
DECLARE
  p_ID_088803187874 UUID;
  p_Name_088803187874 VARCHAR(255);
  p_Description_088803187874 TEXT;
  p_CategoryID_088803187874 UUID;
  p_UserPrompt_088803187874 TEXT;
  p_UserID_088803187874 UUID;
  p_ActiveAt_088803187874 TIMESTAMPTZ;
  p_DisabledAt_088803187874 TIMESTAMPTZ;
  p_IsActive_088803187874 BOOLEAN;
BEGIN
  p_ID_088803187874 := '9c7164e7-a21c-4b1a-97bd-335650f2450f';
  p_Name_088803187874 := 'Tasks: Draft Meeting Agenda';
  p_Description_088803187874 := 'Template for AI Prompt: Tasks: Draft Meeting Agenda';
  p_CategoryID_088803187874 := 'B61B01C3-2DD1-4FFA-AE77-6DE9765BCA68';
  p_UserID_088803187874 := 'ECAFCCEC-6A37-EF11-86D4-000D3A4E707E';
  p_IsActive_088803187874 := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."Template"
                 WHERE "ID" = p_ID_088803187874) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplate'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplate"(p_data := jsonb_build_object(
    'ID', p_ID_088803187874,
    'Name', p_Name_088803187874,
    'Description', p_Description_088803187874,
    'CategoryID', p_CategoryID_088803187874,
    'UserPrompt', p_UserPrompt_088803187874,
    'UserID', p_UserID_088803187874,
    'ActiveAt', p_ActiveAt_088803187874,
    'DisabledAt', p_DisabledAt_088803187874,
    'IsActive', p_IsActive_088803187874
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplate"(p_ID := p_ID_088803187874, p_Name := p_Name_088803187874, p_Description := p_Description_088803187874, p_CategoryID := p_CategoryID_088803187874, p_UserPrompt := p_UserPrompt_088803187874, p_UserPrompt_Clear := TRUE, p_UserID := p_UserID_088803187874, p_ActiveAt := p_ActiveAt_088803187874, p_ActiveAt_Clear := TRUE, p_DisabledAt := p_DisabledAt_088803187874, p_DisabledAt_Clear := TRUE, p_IsActive := p_IsActive_088803187874);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Contents (core SP call only)
DO $mj$
DECLARE
  p_ID_efbf566765c1 UUID;
  p_TemplateID_efbf566765c1 UUID;
  p_TypeID_efbf566765c1 UUID;
  p_TemplateText_efbf566765c1 TEXT;
  p_Priority_efbf566765c1 INTEGER;
  p_IsActive_efbf566765c1 BOOLEAN;
BEGIN
  p_ID_efbf566765c1 := '8c284c17-f78b-472e-a723-d3a0e61110c8';
  p_TemplateID_efbf566765c1 := '9C7164E7-A21C-4B1A-97BD-335650F2450F';
  p_TypeID_efbf566765c1 := 'E7AFCCEC-6A37-EF11-86D4-000D3A4E707E';
  p_TemplateText_efbf566765c1 := 'You are an expert meeting facilitator for MemberJunction BizApps Tasks.

Given a meeting''s title, duration, type template, open linked tasks, and unfinished agenda items from prior occurrences in the series, produce an ordered list of agenda items (`items`) that fits the meeting''s allotted duration.

### Meeting Details
- **Title:** {{ meetingName }}
- **Description:** {{ meetingDescription }}
- **StartsAt:** {{ startsAt }}
- **EndsAt:** {{ endsAt }}
- **DurationMinutes:** {{ durationMinutes }}

### Meeting Type Template
{{ templateJson }}

### Open Linked Tasks
{{ openTasksJson }}

### Unfinished Prior Agenda Items
{{ unfinishedItemsJson }}

Return ONLY valid JSON matching this schema:
```json
{
  "items": [
    {
      "title": "string",
      "typeCode": "INFORMATION | DISCUSSION | DECISION | REPORT | PRESENTATION | ACTION_REVIEW | BREAK | null",
      "durationMinutes": 10,
      "description": "string | null",
      "items": []
    }
  ]
}
```
';
  p_Priority_efbf566765c1 := 1;
  p_IsActive_efbf566765c1 := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateContent"
                 WHERE "ID" = p_ID_efbf566765c1
                    OR ("TemplateID" = p_TemplateID_efbf566765c1 AND "TypeID" = p_TypeID_efbf566765c1)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateContent'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateContent"(p_data := jsonb_build_object(
    'ID', p_ID_efbf566765c1,
    'TemplateID', p_TemplateID_efbf566765c1,
    'TypeID', p_TypeID_efbf566765c1,
    'TemplateText', p_TemplateText_efbf566765c1,
    'Priority', p_Priority_efbf566765c1,
    'IsActive', p_IsActive_efbf566765c1
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateContent"(p_ID := p_ID_efbf566765c1, p_TemplateID := p_TemplateID_efbf566765c1, p_TypeID := p_TypeID_efbf566765c1, p_TemplateText := p_TemplateText_efbf566765c1, p_Priority := p_Priority_efbf566765c1, p_IsActive := p_IsActive_efbf566765c1);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Params (core SP call only)
DO $mj$
DECLARE
  p_ID_0e989fbc9dee UUID;
  p_TemplateID_0e989fbc9dee UUID;
  p_Name_0e989fbc9dee VARCHAR(255);
  p_Description_0e989fbc9dee TEXT;
  p_Type_0e989fbc9dee VARCHAR(20);
  p_DefaultValue_0e989fbc9dee TEXT;
  p_IsRequired_0e989fbc9dee BOOLEAN;
  p_LinkedParameterName_0e989fbc9dee VARCHAR(255);
  p_LinkedParameterField_0e989fbc9dee VARCHAR(500);
  p_ExtraFilter_0e989fbc9dee TEXT;
  p_EntityID_0e989fbc9dee UUID;
  p_RecordID_0e989fbc9dee VARCHAR(2000);
  p_OrderBy_0e989fbc9dee TEXT;
  p_TemplateContentID_0e989fbc9dee UUID;
BEGIN
  p_ID_0e989fbc9dee := '4ced9d56-7566-4a67-b9a5-a12df07007c8';
  p_TemplateID_0e989fbc9dee := '9C7164E7-A21C-4B1A-97BD-335650F2450F';
  p_Name_0e989fbc9dee := 'durationMinutes';
  p_Description_0e989fbc9dee := 'Template scalar parameter ''durationMinutes''';
  p_Type_0e989fbc9dee := 'Scalar';
  p_IsRequired_0e989fbc9dee := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateParam"
                 WHERE "ID" = p_ID_0e989fbc9dee
                    OR ("TemplateID" = p_TemplateID_0e989fbc9dee AND "Name" = p_Name_0e989fbc9dee)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_data := jsonb_build_object(
    'ID', p_ID_0e989fbc9dee,
    'TemplateID', p_TemplateID_0e989fbc9dee,
    'Name', p_Name_0e989fbc9dee,
    'Description', p_Description_0e989fbc9dee,
    'Type', p_Type_0e989fbc9dee,
    'DefaultValue', p_DefaultValue_0e989fbc9dee,
    'IsRequired', p_IsRequired_0e989fbc9dee,
    'LinkedParameterName', p_LinkedParameterName_0e989fbc9dee,
    'LinkedParameterField', p_LinkedParameterField_0e989fbc9dee,
    'ExtraFilter', p_ExtraFilter_0e989fbc9dee,
    'EntityID', p_EntityID_0e989fbc9dee,
    'RecordID', p_RecordID_0e989fbc9dee,
    'OrderBy', p_OrderBy_0e989fbc9dee,
    'TemplateContentID', p_TemplateContentID_0e989fbc9dee
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_ID := p_ID_0e989fbc9dee, p_TemplateID := p_TemplateID_0e989fbc9dee, p_Name := p_Name_0e989fbc9dee, p_Description := p_Description_0e989fbc9dee, p_Type := p_Type_0e989fbc9dee, p_DefaultValue := p_DefaultValue_0e989fbc9dee, p_DefaultValue_Clear := TRUE, p_IsRequired := p_IsRequired_0e989fbc9dee, p_LinkedParameterName := p_LinkedParameterName_0e989fbc9dee, p_LinkedParameterName_Clear := TRUE, p_LinkedParameterField := p_LinkedParameterField_0e989fbc9dee, p_LinkedParameterField_Clear := TRUE, p_ExtraFilter := p_ExtraFilter_0e989fbc9dee, p_ExtraFilter_Clear := TRUE, p_EntityID := p_EntityID_0e989fbc9dee, p_EntityID_Clear := TRUE, p_RecordID := p_RecordID_0e989fbc9dee, p_RecordID_Clear := TRUE, p_OrderBy := p_OrderBy_0e989fbc9dee, p_OrderBy_Clear := TRUE, p_TemplateContentID := p_TemplateContentID_0e989fbc9dee, p_TemplateContentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Params (core SP call only)
DO $mj$
DECLARE
  p_ID_68e6ad3e2022 UUID;
  p_TemplateID_68e6ad3e2022 UUID;
  p_Name_68e6ad3e2022 VARCHAR(255);
  p_Description_68e6ad3e2022 TEXT;
  p_Type_68e6ad3e2022 VARCHAR(20);
  p_DefaultValue_68e6ad3e2022 TEXT;
  p_IsRequired_68e6ad3e2022 BOOLEAN;
  p_LinkedParameterName_68e6ad3e2022 VARCHAR(255);
  p_LinkedParameterField_68e6ad3e2022 VARCHAR(500);
  p_ExtraFilter_68e6ad3e2022 TEXT;
  p_EntityID_68e6ad3e2022 UUID;
  p_RecordID_68e6ad3e2022 VARCHAR(2000);
  p_OrderBy_68e6ad3e2022 TEXT;
  p_TemplateContentID_68e6ad3e2022 UUID;
BEGIN
  p_ID_68e6ad3e2022 := 'ab9e6edb-e68e-45cd-b23f-6c8abba3455e';
  p_TemplateID_68e6ad3e2022 := '9C7164E7-A21C-4B1A-97BD-335650F2450F';
  p_Name_68e6ad3e2022 := 'endsAt';
  p_Description_68e6ad3e2022 := 'Template scalar parameter ''endsAt''';
  p_Type_68e6ad3e2022 := 'Scalar';
  p_IsRequired_68e6ad3e2022 := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateParam"
                 WHERE "ID" = p_ID_68e6ad3e2022
                    OR ("TemplateID" = p_TemplateID_68e6ad3e2022 AND "Name" = p_Name_68e6ad3e2022)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_data := jsonb_build_object(
    'ID', p_ID_68e6ad3e2022,
    'TemplateID', p_TemplateID_68e6ad3e2022,
    'Name', p_Name_68e6ad3e2022,
    'Description', p_Description_68e6ad3e2022,
    'Type', p_Type_68e6ad3e2022,
    'DefaultValue', p_DefaultValue_68e6ad3e2022,
    'IsRequired', p_IsRequired_68e6ad3e2022,
    'LinkedParameterName', p_LinkedParameterName_68e6ad3e2022,
    'LinkedParameterField', p_LinkedParameterField_68e6ad3e2022,
    'ExtraFilter', p_ExtraFilter_68e6ad3e2022,
    'EntityID', p_EntityID_68e6ad3e2022,
    'RecordID', p_RecordID_68e6ad3e2022,
    'OrderBy', p_OrderBy_68e6ad3e2022,
    'TemplateContentID', p_TemplateContentID_68e6ad3e2022
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_ID := p_ID_68e6ad3e2022, p_TemplateID := p_TemplateID_68e6ad3e2022, p_Name := p_Name_68e6ad3e2022, p_Description := p_Description_68e6ad3e2022, p_Type := p_Type_68e6ad3e2022, p_DefaultValue := p_DefaultValue_68e6ad3e2022, p_DefaultValue_Clear := TRUE, p_IsRequired := p_IsRequired_68e6ad3e2022, p_LinkedParameterName := p_LinkedParameterName_68e6ad3e2022, p_LinkedParameterName_Clear := TRUE, p_LinkedParameterField := p_LinkedParameterField_68e6ad3e2022, p_LinkedParameterField_Clear := TRUE, p_ExtraFilter := p_ExtraFilter_68e6ad3e2022, p_ExtraFilter_Clear := TRUE, p_EntityID := p_EntityID_68e6ad3e2022, p_EntityID_Clear := TRUE, p_RecordID := p_RecordID_68e6ad3e2022, p_RecordID_Clear := TRUE, p_OrderBy := p_OrderBy_68e6ad3e2022, p_OrderBy_Clear := TRUE, p_TemplateContentID := p_TemplateContentID_68e6ad3e2022, p_TemplateContentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Params (core SP call only)
DO $mj$
DECLARE
  p_ID_ba5051998c93 UUID;
  p_TemplateID_ba5051998c93 UUID;
  p_Name_ba5051998c93 VARCHAR(255);
  p_Description_ba5051998c93 TEXT;
  p_Type_ba5051998c93 VARCHAR(20);
  p_DefaultValue_ba5051998c93 TEXT;
  p_IsRequired_ba5051998c93 BOOLEAN;
  p_LinkedParameterName_ba5051998c93 VARCHAR(255);
  p_LinkedParameterField_ba5051998c93 VARCHAR(500);
  p_ExtraFilter_ba5051998c93 TEXT;
  p_EntityID_ba5051998c93 UUID;
  p_RecordID_ba5051998c93 VARCHAR(2000);
  p_OrderBy_ba5051998c93 TEXT;
  p_TemplateContentID_ba5051998c93 UUID;
BEGIN
  p_ID_ba5051998c93 := 'd76654f4-41a4-42ce-b0a5-9db2b2dcd340';
  p_TemplateID_ba5051998c93 := '9C7164E7-A21C-4B1A-97BD-335650F2450F';
  p_Name_ba5051998c93 := 'meetingDescription';
  p_Description_ba5051998c93 := 'Template scalar parameter ''meetingDescription''';
  p_Type_ba5051998c93 := 'Scalar';
  p_IsRequired_ba5051998c93 := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateParam"
                 WHERE "ID" = p_ID_ba5051998c93
                    OR ("TemplateID" = p_TemplateID_ba5051998c93 AND "Name" = p_Name_ba5051998c93)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_data := jsonb_build_object(
    'ID', p_ID_ba5051998c93,
    'TemplateID', p_TemplateID_ba5051998c93,
    'Name', p_Name_ba5051998c93,
    'Description', p_Description_ba5051998c93,
    'Type', p_Type_ba5051998c93,
    'DefaultValue', p_DefaultValue_ba5051998c93,
    'IsRequired', p_IsRequired_ba5051998c93,
    'LinkedParameterName', p_LinkedParameterName_ba5051998c93,
    'LinkedParameterField', p_LinkedParameterField_ba5051998c93,
    'ExtraFilter', p_ExtraFilter_ba5051998c93,
    'EntityID', p_EntityID_ba5051998c93,
    'RecordID', p_RecordID_ba5051998c93,
    'OrderBy', p_OrderBy_ba5051998c93,
    'TemplateContentID', p_TemplateContentID_ba5051998c93
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_ID := p_ID_ba5051998c93, p_TemplateID := p_TemplateID_ba5051998c93, p_Name := p_Name_ba5051998c93, p_Description := p_Description_ba5051998c93, p_Type := p_Type_ba5051998c93, p_DefaultValue := p_DefaultValue_ba5051998c93, p_DefaultValue_Clear := TRUE, p_IsRequired := p_IsRequired_ba5051998c93, p_LinkedParameterName := p_LinkedParameterName_ba5051998c93, p_LinkedParameterName_Clear := TRUE, p_LinkedParameterField := p_LinkedParameterField_ba5051998c93, p_LinkedParameterField_Clear := TRUE, p_ExtraFilter := p_ExtraFilter_ba5051998c93, p_ExtraFilter_Clear := TRUE, p_EntityID := p_EntityID_ba5051998c93, p_EntityID_Clear := TRUE, p_RecordID := p_RecordID_ba5051998c93, p_RecordID_Clear := TRUE, p_OrderBy := p_OrderBy_ba5051998c93, p_OrderBy_Clear := TRUE, p_TemplateContentID := p_TemplateContentID_ba5051998c93, p_TemplateContentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Params (core SP call only)
DO $mj$
DECLARE
  p_ID_0ed257428d75 UUID;
  p_TemplateID_0ed257428d75 UUID;
  p_Name_0ed257428d75 VARCHAR(255);
  p_Description_0ed257428d75 TEXT;
  p_Type_0ed257428d75 VARCHAR(20);
  p_DefaultValue_0ed257428d75 TEXT;
  p_IsRequired_0ed257428d75 BOOLEAN;
  p_LinkedParameterName_0ed257428d75 VARCHAR(255);
  p_LinkedParameterField_0ed257428d75 VARCHAR(500);
  p_ExtraFilter_0ed257428d75 TEXT;
  p_EntityID_0ed257428d75 UUID;
  p_RecordID_0ed257428d75 VARCHAR(2000);
  p_OrderBy_0ed257428d75 TEXT;
  p_TemplateContentID_0ed257428d75 UUID;
BEGIN
  p_ID_0ed257428d75 := 'ee29e973-f3c5-4061-89f6-1574e206821e';
  p_TemplateID_0ed257428d75 := '9C7164E7-A21C-4B1A-97BD-335650F2450F';
  p_Name_0ed257428d75 := 'meetingName';
  p_Description_0ed257428d75 := 'Template scalar parameter ''meetingName''';
  p_Type_0ed257428d75 := 'Scalar';
  p_IsRequired_0ed257428d75 := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateParam"
                 WHERE "ID" = p_ID_0ed257428d75
                    OR ("TemplateID" = p_TemplateID_0ed257428d75 AND "Name" = p_Name_0ed257428d75)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_data := jsonb_build_object(
    'ID', p_ID_0ed257428d75,
    'TemplateID', p_TemplateID_0ed257428d75,
    'Name', p_Name_0ed257428d75,
    'Description', p_Description_0ed257428d75,
    'Type', p_Type_0ed257428d75,
    'DefaultValue', p_DefaultValue_0ed257428d75,
    'IsRequired', p_IsRequired_0ed257428d75,
    'LinkedParameterName', p_LinkedParameterName_0ed257428d75,
    'LinkedParameterField', p_LinkedParameterField_0ed257428d75,
    'ExtraFilter', p_ExtraFilter_0ed257428d75,
    'EntityID', p_EntityID_0ed257428d75,
    'RecordID', p_RecordID_0ed257428d75,
    'OrderBy', p_OrderBy_0ed257428d75,
    'TemplateContentID', p_TemplateContentID_0ed257428d75
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_ID := p_ID_0ed257428d75, p_TemplateID := p_TemplateID_0ed257428d75, p_Name := p_Name_0ed257428d75, p_Description := p_Description_0ed257428d75, p_Type := p_Type_0ed257428d75, p_DefaultValue := p_DefaultValue_0ed257428d75, p_DefaultValue_Clear := TRUE, p_IsRequired := p_IsRequired_0ed257428d75, p_LinkedParameterName := p_LinkedParameterName_0ed257428d75, p_LinkedParameterName_Clear := TRUE, p_LinkedParameterField := p_LinkedParameterField_0ed257428d75, p_LinkedParameterField_Clear := TRUE, p_ExtraFilter := p_ExtraFilter_0ed257428d75, p_ExtraFilter_Clear := TRUE, p_EntityID := p_EntityID_0ed257428d75, p_EntityID_Clear := TRUE, p_RecordID := p_RecordID_0ed257428d75, p_RecordID_Clear := TRUE, p_OrderBy := p_OrderBy_0ed257428d75, p_OrderBy_Clear := TRUE, p_TemplateContentID := p_TemplateContentID_0ed257428d75, p_TemplateContentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Params (core SP call only)
DO $mj$
DECLARE
  p_ID_212e690c199b UUID;
  p_TemplateID_212e690c199b UUID;
  p_Name_212e690c199b VARCHAR(255);
  p_Description_212e690c199b TEXT;
  p_Type_212e690c199b VARCHAR(20);
  p_DefaultValue_212e690c199b TEXT;
  p_IsRequired_212e690c199b BOOLEAN;
  p_LinkedParameterName_212e690c199b VARCHAR(255);
  p_LinkedParameterField_212e690c199b VARCHAR(500);
  p_ExtraFilter_212e690c199b TEXT;
  p_EntityID_212e690c199b UUID;
  p_RecordID_212e690c199b VARCHAR(2000);
  p_OrderBy_212e690c199b TEXT;
  p_TemplateContentID_212e690c199b UUID;
BEGIN
  p_ID_212e690c199b := '26542399-fcf7-43a1-8219-3a79859035b5';
  p_TemplateID_212e690c199b := '9C7164E7-A21C-4B1A-97BD-335650F2450F';
  p_Name_212e690c199b := 'openTasksJson';
  p_Description_212e690c199b := 'Template scalar parameter ''openTasksJson''';
  p_Type_212e690c199b := 'Scalar';
  p_IsRequired_212e690c199b := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateParam"
                 WHERE "ID" = p_ID_212e690c199b
                    OR ("TemplateID" = p_TemplateID_212e690c199b AND "Name" = p_Name_212e690c199b)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_data := jsonb_build_object(
    'ID', p_ID_212e690c199b,
    'TemplateID', p_TemplateID_212e690c199b,
    'Name', p_Name_212e690c199b,
    'Description', p_Description_212e690c199b,
    'Type', p_Type_212e690c199b,
    'DefaultValue', p_DefaultValue_212e690c199b,
    'IsRequired', p_IsRequired_212e690c199b,
    'LinkedParameterName', p_LinkedParameterName_212e690c199b,
    'LinkedParameterField', p_LinkedParameterField_212e690c199b,
    'ExtraFilter', p_ExtraFilter_212e690c199b,
    'EntityID', p_EntityID_212e690c199b,
    'RecordID', p_RecordID_212e690c199b,
    'OrderBy', p_OrderBy_212e690c199b,
    'TemplateContentID', p_TemplateContentID_212e690c199b
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_ID := p_ID_212e690c199b, p_TemplateID := p_TemplateID_212e690c199b, p_Name := p_Name_212e690c199b, p_Description := p_Description_212e690c199b, p_Type := p_Type_212e690c199b, p_DefaultValue := p_DefaultValue_212e690c199b, p_DefaultValue_Clear := TRUE, p_IsRequired := p_IsRequired_212e690c199b, p_LinkedParameterName := p_LinkedParameterName_212e690c199b, p_LinkedParameterName_Clear := TRUE, p_LinkedParameterField := p_LinkedParameterField_212e690c199b, p_LinkedParameterField_Clear := TRUE, p_ExtraFilter := p_ExtraFilter_212e690c199b, p_ExtraFilter_Clear := TRUE, p_EntityID := p_EntityID_212e690c199b, p_EntityID_Clear := TRUE, p_RecordID := p_RecordID_212e690c199b, p_RecordID_Clear := TRUE, p_OrderBy := p_OrderBy_212e690c199b, p_OrderBy_Clear := TRUE, p_TemplateContentID := p_TemplateContentID_212e690c199b, p_TemplateContentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Params (core SP call only)
DO $mj$
DECLARE
  p_ID_2dd8e7d04dd2 UUID;
  p_TemplateID_2dd8e7d04dd2 UUID;
  p_Name_2dd8e7d04dd2 VARCHAR(255);
  p_Description_2dd8e7d04dd2 TEXT;
  p_Type_2dd8e7d04dd2 VARCHAR(20);
  p_DefaultValue_2dd8e7d04dd2 TEXT;
  p_IsRequired_2dd8e7d04dd2 BOOLEAN;
  p_LinkedParameterName_2dd8e7d04dd2 VARCHAR(255);
  p_LinkedParameterField_2dd8e7d04dd2 VARCHAR(500);
  p_ExtraFilter_2dd8e7d04dd2 TEXT;
  p_EntityID_2dd8e7d04dd2 UUID;
  p_RecordID_2dd8e7d04dd2 VARCHAR(2000);
  p_OrderBy_2dd8e7d04dd2 TEXT;
  p_TemplateContentID_2dd8e7d04dd2 UUID;
BEGIN
  p_ID_2dd8e7d04dd2 := '5274e0ed-6e50-4845-868d-f677e79f1bd8';
  p_TemplateID_2dd8e7d04dd2 := '9C7164E7-A21C-4B1A-97BD-335650F2450F';
  p_Name_2dd8e7d04dd2 := 'startsAt';
  p_Description_2dd8e7d04dd2 := 'Template scalar parameter ''startsAt''';
  p_Type_2dd8e7d04dd2 := 'Scalar';
  p_IsRequired_2dd8e7d04dd2 := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateParam"
                 WHERE "ID" = p_ID_2dd8e7d04dd2
                    OR ("TemplateID" = p_TemplateID_2dd8e7d04dd2 AND "Name" = p_Name_2dd8e7d04dd2)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_data := jsonb_build_object(
    'ID', p_ID_2dd8e7d04dd2,
    'TemplateID', p_TemplateID_2dd8e7d04dd2,
    'Name', p_Name_2dd8e7d04dd2,
    'Description', p_Description_2dd8e7d04dd2,
    'Type', p_Type_2dd8e7d04dd2,
    'DefaultValue', p_DefaultValue_2dd8e7d04dd2,
    'IsRequired', p_IsRequired_2dd8e7d04dd2,
    'LinkedParameterName', p_LinkedParameterName_2dd8e7d04dd2,
    'LinkedParameterField', p_LinkedParameterField_2dd8e7d04dd2,
    'ExtraFilter', p_ExtraFilter_2dd8e7d04dd2,
    'EntityID', p_EntityID_2dd8e7d04dd2,
    'RecordID', p_RecordID_2dd8e7d04dd2,
    'OrderBy', p_OrderBy_2dd8e7d04dd2,
    'TemplateContentID', p_TemplateContentID_2dd8e7d04dd2
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_ID := p_ID_2dd8e7d04dd2, p_TemplateID := p_TemplateID_2dd8e7d04dd2, p_Name := p_Name_2dd8e7d04dd2, p_Description := p_Description_2dd8e7d04dd2, p_Type := p_Type_2dd8e7d04dd2, p_DefaultValue := p_DefaultValue_2dd8e7d04dd2, p_DefaultValue_Clear := TRUE, p_IsRequired := p_IsRequired_2dd8e7d04dd2, p_LinkedParameterName := p_LinkedParameterName_2dd8e7d04dd2, p_LinkedParameterName_Clear := TRUE, p_LinkedParameterField := p_LinkedParameterField_2dd8e7d04dd2, p_LinkedParameterField_Clear := TRUE, p_ExtraFilter := p_ExtraFilter_2dd8e7d04dd2, p_ExtraFilter_Clear := TRUE, p_EntityID := p_EntityID_2dd8e7d04dd2, p_EntityID_Clear := TRUE, p_RecordID := p_RecordID_2dd8e7d04dd2, p_RecordID_Clear := TRUE, p_OrderBy := p_OrderBy_2dd8e7d04dd2, p_OrderBy_Clear := TRUE, p_TemplateContentID := p_TemplateContentID_2dd8e7d04dd2, p_TemplateContentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Params (core SP call only)
DO $mj$
DECLARE
  p_ID_03fafa92238b UUID;
  p_TemplateID_03fafa92238b UUID;
  p_Name_03fafa92238b VARCHAR(255);
  p_Description_03fafa92238b TEXT;
  p_Type_03fafa92238b VARCHAR(20);
  p_DefaultValue_03fafa92238b TEXT;
  p_IsRequired_03fafa92238b BOOLEAN;
  p_LinkedParameterName_03fafa92238b VARCHAR(255);
  p_LinkedParameterField_03fafa92238b VARCHAR(500);
  p_ExtraFilter_03fafa92238b TEXT;
  p_EntityID_03fafa92238b UUID;
  p_RecordID_03fafa92238b VARCHAR(2000);
  p_OrderBy_03fafa92238b TEXT;
  p_TemplateContentID_03fafa92238b UUID;
BEGIN
  p_ID_03fafa92238b := '863a9077-10a9-44a0-957b-6bb46e1bd2ff';
  p_TemplateID_03fafa92238b := '9C7164E7-A21C-4B1A-97BD-335650F2450F';
  p_Name_03fafa92238b := 'templateJson';
  p_Description_03fafa92238b := 'Template scalar parameter ''templateJson''';
  p_Type_03fafa92238b := 'Scalar';
  p_IsRequired_03fafa92238b := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateParam"
                 WHERE "ID" = p_ID_03fafa92238b
                    OR ("TemplateID" = p_TemplateID_03fafa92238b AND "Name" = p_Name_03fafa92238b)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_data := jsonb_build_object(
    'ID', p_ID_03fafa92238b,
    'TemplateID', p_TemplateID_03fafa92238b,
    'Name', p_Name_03fafa92238b,
    'Description', p_Description_03fafa92238b,
    'Type', p_Type_03fafa92238b,
    'DefaultValue', p_DefaultValue_03fafa92238b,
    'IsRequired', p_IsRequired_03fafa92238b,
    'LinkedParameterName', p_LinkedParameterName_03fafa92238b,
    'LinkedParameterField', p_LinkedParameterField_03fafa92238b,
    'ExtraFilter', p_ExtraFilter_03fafa92238b,
    'EntityID', p_EntityID_03fafa92238b,
    'RecordID', p_RecordID_03fafa92238b,
    'OrderBy', p_OrderBy_03fafa92238b,
    'TemplateContentID', p_TemplateContentID_03fafa92238b
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_ID := p_ID_03fafa92238b, p_TemplateID := p_TemplateID_03fafa92238b, p_Name := p_Name_03fafa92238b, p_Description := p_Description_03fafa92238b, p_Type := p_Type_03fafa92238b, p_DefaultValue := p_DefaultValue_03fafa92238b, p_DefaultValue_Clear := TRUE, p_IsRequired := p_IsRequired_03fafa92238b, p_LinkedParameterName := p_LinkedParameterName_03fafa92238b, p_LinkedParameterName_Clear := TRUE, p_LinkedParameterField := p_LinkedParameterField_03fafa92238b, p_LinkedParameterField_Clear := TRUE, p_ExtraFilter := p_ExtraFilter_03fafa92238b, p_ExtraFilter_Clear := TRUE, p_EntityID := p_EntityID_03fafa92238b, p_EntityID_Clear := TRUE, p_RecordID := p_RecordID_03fafa92238b, p_RecordID_Clear := TRUE, p_OrderBy := p_OrderBy_03fafa92238b, p_OrderBy_Clear := TRUE, p_TemplateContentID := p_TemplateContentID_03fafa92238b, p_TemplateContentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Template Params (core SP call only)
DO $mj$
DECLARE
  p_ID_5a50c9cd6a20 UUID;
  p_TemplateID_5a50c9cd6a20 UUID;
  p_Name_5a50c9cd6a20 VARCHAR(255);
  p_Description_5a50c9cd6a20 TEXT;
  p_Type_5a50c9cd6a20 VARCHAR(20);
  p_DefaultValue_5a50c9cd6a20 TEXT;
  p_IsRequired_5a50c9cd6a20 BOOLEAN;
  p_LinkedParameterName_5a50c9cd6a20 VARCHAR(255);
  p_LinkedParameterField_5a50c9cd6a20 VARCHAR(500);
  p_ExtraFilter_5a50c9cd6a20 TEXT;
  p_EntityID_5a50c9cd6a20 UUID;
  p_RecordID_5a50c9cd6a20 VARCHAR(2000);
  p_OrderBy_5a50c9cd6a20 TEXT;
  p_TemplateContentID_5a50c9cd6a20 UUID;
BEGIN
  p_ID_5a50c9cd6a20 := 'd3a34db5-19ee-4ac3-a9cf-3d14a5419a3f';
  p_TemplateID_5a50c9cd6a20 := '9C7164E7-A21C-4B1A-97BD-335650F2450F';
  p_Name_5a50c9cd6a20 := 'unfinishedItemsJson';
  p_Description_5a50c9cd6a20 := 'Template scalar parameter ''unfinishedItemsJson''';
  p_Type_5a50c9cd6a20 := 'Scalar';
  p_IsRequired_5a50c9cd6a20 := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."TemplateParam"
                 WHERE "ID" = p_ID_5a50c9cd6a20
                    OR ("TemplateID" = p_TemplateID_5a50c9cd6a20 AND "Name" = p_Name_5a50c9cd6a20)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateTemplateParam'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_data := jsonb_build_object(
    'ID', p_ID_5a50c9cd6a20,
    'TemplateID', p_TemplateID_5a50c9cd6a20,
    'Name', p_Name_5a50c9cd6a20,
    'Description', p_Description_5a50c9cd6a20,
    'Type', p_Type_5a50c9cd6a20,
    'DefaultValue', p_DefaultValue_5a50c9cd6a20,
    'IsRequired', p_IsRequired_5a50c9cd6a20,
    'LinkedParameterName', p_LinkedParameterName_5a50c9cd6a20,
    'LinkedParameterField', p_LinkedParameterField_5a50c9cd6a20,
    'ExtraFilter', p_ExtraFilter_5a50c9cd6a20,
    'EntityID', p_EntityID_5a50c9cd6a20,
    'RecordID', p_RecordID_5a50c9cd6a20,
    'OrderBy', p_OrderBy_5a50c9cd6a20,
    'TemplateContentID', p_TemplateContentID_5a50c9cd6a20
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateTemplateParam"(p_ID := p_ID_5a50c9cd6a20, p_TemplateID := p_TemplateID_5a50c9cd6a20, p_Name := p_Name_5a50c9cd6a20, p_Description := p_Description_5a50c9cd6a20, p_Type := p_Type_5a50c9cd6a20, p_DefaultValue := p_DefaultValue_5a50c9cd6a20, p_DefaultValue_Clear := TRUE, p_IsRequired := p_IsRequired_5a50c9cd6a20, p_LinkedParameterName := p_LinkedParameterName_5a50c9cd6a20, p_LinkedParameterName_Clear := TRUE, p_LinkedParameterField := p_LinkedParameterField_5a50c9cd6a20, p_LinkedParameterField_Clear := TRUE, p_ExtraFilter := p_ExtraFilter_5a50c9cd6a20, p_ExtraFilter_Clear := TRUE, p_EntityID := p_EntityID_5a50c9cd6a20, p_EntityID_Clear := TRUE, p_RecordID := p_RecordID_5a50c9cd6a20, p_RecordID_Clear := TRUE, p_OrderBy := p_OrderBy_5a50c9cd6a20, p_OrderBy_Clear := TRUE, p_TemplateContentID := p_TemplateContentID_5a50c9cd6a20, p_TemplateContentID_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ: AI Prompts (core SP call only)
DO $mj$
DECLARE
  p_ID_3cb0b576b680 UUID;
  p_Name_3cb0b576b680 VARCHAR(255);
  p_Description_3cb0b576b680 TEXT;
  p_TemplateID_3cb0b576b680 UUID;
  p_CategoryID_3cb0b576b680 UUID;
  p_TypeID_3cb0b576b680 UUID;
  p_Status_3cb0b576b680 VARCHAR(50);
  p_ResponseFormat_3cb0b576b680 VARCHAR(20);
  p_ModelSpecificResponseFormat_3cb0b576b680 TEXT;
  p_AIModelTypeID_3cb0b576b680 UUID;
  p_MinPowerRank_3cb0b576b680 INTEGER;
  p_SelectionStrategy_3cb0b576b680 VARCHAR(20);
  p_PowerPreference_3cb0b576b680 VARCHAR(20);
  p_ParallelizationMode_3cb0b576b680 VARCHAR(20);
  p_ParallelCount_3cb0b576b680 INTEGER;
  p_ParallelConfigParam_3cb0b576b680 VARCHAR(100);
  p_OutputType_3cb0b576b680 VARCHAR(50);
  p_OutputExample_3cb0b576b680 TEXT;
  p_ValidationBehavior_3cb0b576b680 VARCHAR(50);
  p_MaxRetries_3cb0b576b680 INTEGER;
  p_RetryDelayMS_3cb0b576b680 INTEGER;
  p_RetryStrategy_3cb0b576b680 VARCHAR(20);
  p_ResultSelectorPromptID_3cb0b576b680 UUID;
  p_EnableCaching_3cb0b576b680 BOOLEAN;
  p_CacheTTLSeconds_3cb0b576b680 INTEGER;
  p_CacheMatchType_3cb0b576b680 VARCHAR(20);
  p_CacheSimilarityThreshold_3cb0b576b680 DOUBLE PRECISION;
  p_CacheMustMatchModel_3cb0b576b680 BOOLEAN;
  p_CacheMustMatchVendor_3cb0b576b680 BOOLEAN;
  p_CacheMustMatchAgent_3cb0b576b680 BOOLEAN;
  p_CacheMustMatchConfig_3cb0b576b680 BOOLEAN;
  p_PromptRole_3cb0b576b680 VARCHAR(20);
  p_PromptPosition_3cb0b576b680 VARCHAR(20);
  p_Temperature_3cb0b576b680 NUMERIC(3,2);
  p_TopP_3cb0b576b680 NUMERIC(3,2);
  p_TopK_3cb0b576b680 INTEGER;
  p_MinP_3cb0b576b680 NUMERIC(3,2);
  p_FrequencyPenalty_3cb0b576b680 NUMERIC(3,2);
  p_PresencePenalty_3cb0b576b680 NUMERIC(3,2);
  p_Seed_3cb0b576b680 INTEGER;
  p_StopSequences_3cb0b576b680 VARCHAR(1000);
  p_IncludeLogProbs_3cb0b576b680 BOOLEAN;
  p_TopLogProbs_3cb0b576b680 INTEGER;
  p_FailoverStrategy_3cb0b576b680 VARCHAR(50);
  p_FailoverMaxAttempts_3cb0b576b680 INTEGER;
  p_FailoverDelaySeconds_3cb0b576b680 INTEGER;
  p_FailoverModelStrategy_3cb0b576b680 VARCHAR(50);
  p_FailoverErrorScope_3cb0b576b680 VARCHAR(50);
  p_EffortLevel_3cb0b576b680 INTEGER;
  p_AssistantPrefill_3cb0b576b680 TEXT;
  p_PrefillFallbackMode_3cb0b576b680 VARCHAR(20);
  p_RequireSpecificModels_3cb0b576b680 BOOLEAN;
  p_PromptConfiguration_3cb0b576b680 TEXT;
  p_TemplateDataCapture_3cb0b576b680 VARCHAR(20);
BEGIN
  p_ID_3cb0b576b680 := 'E1A00001-0000-4000-8000-000000000002';
  p_Name_3cb0b576b680 := 'Tasks: Draft Meeting Agenda';
  p_Description_3cb0b576b680 := 'Drafts a structured meeting agenda from the meeting type''s template, open linked tasks, and unfinished items from prior occurrences.';
  p_TemplateID_3cb0b576b680 := '9C7164E7-A21C-4B1A-97BD-335650F2450F';
  p_TypeID_3cb0b576b680 := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."AIPromptType"
    WHERE
      LOWER("Name") = LOWER('Chat')
  );
  p_Status_3cb0b576b680 := 'Active';
  p_ResponseFormat_3cb0b576b680 := 'JSON';
  p_MinPowerRank_3cb0b576b680 := 0;
  p_SelectionStrategy_3cb0b576b680 := 'Default';
  p_PowerPreference_3cb0b576b680 := 'Highest';
  p_ParallelizationMode_3cb0b576b680 := 'None';
  p_OutputType_3cb0b576b680 := 'string';
  p_ValidationBehavior_3cb0b576b680 := 'Warn';
  p_MaxRetries_3cb0b576b680 := 0;
  p_RetryDelayMS_3cb0b576b680 := 0;
  p_RetryStrategy_3cb0b576b680 := 'Fixed';
  p_EnableCaching_3cb0b576b680 := FALSE;
  p_CacheMatchType_3cb0b576b680 := 'Exact';
  p_CacheMustMatchModel_3cb0b576b680 := TRUE;
  p_CacheMustMatchVendor_3cb0b576b680 := TRUE;
  p_CacheMustMatchAgent_3cb0b576b680 := FALSE;
  p_CacheMustMatchConfig_3cb0b576b680 := FALSE;
  p_PromptRole_3cb0b576b680 := 'System';
  p_PromptPosition_3cb0b576b680 := 'First';
  p_IncludeLogProbs_3cb0b576b680 := FALSE;
  p_FailoverStrategy_3cb0b576b680 := 'SameModelDifferentVendor';
  p_FailoverMaxAttempts_3cb0b576b680 := 3;
  p_FailoverDelaySeconds_3cb0b576b680 := 5;
  p_FailoverModelStrategy_3cb0b576b680 := 'PreferSameModel';
  p_FailoverErrorScope_3cb0b576b680 := 'All';
  p_PrefillFallbackMode_3cb0b576b680 := 'Ignore';
  p_RequireSpecificModels_3cb0b576b680 := FALSE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."AIPrompt"
                 WHERE "ID" = p_ID_3cb0b576b680
                    OR ("Name" = p_Name_3cb0b576b680)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateAIPrompt'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateAIPrompt"(p_data := jsonb_build_object(
    'ID', p_ID_3cb0b576b680,
    'Name', p_Name_3cb0b576b680,
    'Description', p_Description_3cb0b576b680,
    'TemplateID', p_TemplateID_3cb0b576b680,
    'CategoryID', p_CategoryID_3cb0b576b680,
    'TypeID', p_TypeID_3cb0b576b680,
    'Status', p_Status_3cb0b576b680,
    'ResponseFormat', p_ResponseFormat_3cb0b576b680,
    'ModelSpecificResponseFormat', p_ModelSpecificResponseFormat_3cb0b576b680,
    'AIModelTypeID', p_AIModelTypeID_3cb0b576b680,
    'MinPowerRank', p_MinPowerRank_3cb0b576b680,
    'SelectionStrategy', p_SelectionStrategy_3cb0b576b680,
    'PowerPreference', p_PowerPreference_3cb0b576b680,
    'ParallelizationMode', p_ParallelizationMode_3cb0b576b680,
    'ParallelCount', p_ParallelCount_3cb0b576b680,
    'ParallelConfigParam', p_ParallelConfigParam_3cb0b576b680,
    'OutputType', p_OutputType_3cb0b576b680,
    'OutputExample', p_OutputExample_3cb0b576b680,
    'ValidationBehavior', p_ValidationBehavior_3cb0b576b680,
    'MaxRetries', p_MaxRetries_3cb0b576b680,
    'RetryDelayMS', p_RetryDelayMS_3cb0b576b680,
    'RetryStrategy', p_RetryStrategy_3cb0b576b680,
    'ResultSelectorPromptID', p_ResultSelectorPromptID_3cb0b576b680,
    'EnableCaching', p_EnableCaching_3cb0b576b680,
    'CacheTTLSeconds', p_CacheTTLSeconds_3cb0b576b680,
    'CacheMatchType', p_CacheMatchType_3cb0b576b680,
    'CacheSimilarityThreshold', p_CacheSimilarityThreshold_3cb0b576b680,
    'CacheMustMatchModel', p_CacheMustMatchModel_3cb0b576b680,
    'CacheMustMatchVendor', p_CacheMustMatchVendor_3cb0b576b680,
    'CacheMustMatchAgent', p_CacheMustMatchAgent_3cb0b576b680,
    'CacheMustMatchConfig', p_CacheMustMatchConfig_3cb0b576b680,
    'PromptRole', p_PromptRole_3cb0b576b680,
    'PromptPosition', p_PromptPosition_3cb0b576b680,
    'Temperature', p_Temperature_3cb0b576b680,
    'TopP', p_TopP_3cb0b576b680,
    'TopK', p_TopK_3cb0b576b680,
    'MinP', p_MinP_3cb0b576b680,
    'FrequencyPenalty', p_FrequencyPenalty_3cb0b576b680,
    'PresencePenalty', p_PresencePenalty_3cb0b576b680,
    'Seed', p_Seed_3cb0b576b680,
    'StopSequences', p_StopSequences_3cb0b576b680,
    'IncludeLogProbs', p_IncludeLogProbs_3cb0b576b680,
    'TopLogProbs', p_TopLogProbs_3cb0b576b680,
    'FailoverStrategy', p_FailoverStrategy_3cb0b576b680,
    'FailoverMaxAttempts', p_FailoverMaxAttempts_3cb0b576b680,
    'FailoverDelaySeconds', p_FailoverDelaySeconds_3cb0b576b680,
    'FailoverModelStrategy', p_FailoverModelStrategy_3cb0b576b680,
    'FailoverErrorScope', p_FailoverErrorScope_3cb0b576b680,
    'EffortLevel', p_EffortLevel_3cb0b576b680,
    'AssistantPrefill', p_AssistantPrefill_3cb0b576b680
  ) ||
  jsonb_build_object(
    'PrefillFallbackMode', p_PrefillFallbackMode_3cb0b576b680,
    'RequireSpecificModels', p_RequireSpecificModels_3cb0b576b680,
    'PromptConfiguration', p_PromptConfiguration_3cb0b576b680,
    'TemplateDataCapture', p_TemplateDataCapture_3cb0b576b680
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateAIPrompt"(p_ID := p_ID_3cb0b576b680, p_Name := p_Name_3cb0b576b680, p_Description := p_Description_3cb0b576b680, p_TemplateID := p_TemplateID_3cb0b576b680, p_CategoryID := p_CategoryID_3cb0b576b680, p_CategoryID_Clear := TRUE, p_TypeID := p_TypeID_3cb0b576b680, p_Status := p_Status_3cb0b576b680, p_ResponseFormat := p_ResponseFormat_3cb0b576b680, p_ModelSpecificResponseFormat := p_ModelSpecificResponseFormat_3cb0b576b680, p_ModelSpecificResponseFormat_Clear := TRUE, p_AIModelTypeID := p_AIModelTypeID_3cb0b576b680, p_AIModelTypeID_Clear := TRUE, p_MinPowerRank := p_MinPowerRank_3cb0b576b680, p_SelectionStrategy := p_SelectionStrategy_3cb0b576b680, p_PowerPreference := p_PowerPreference_3cb0b576b680, p_ParallelizationMode := p_ParallelizationMode_3cb0b576b680, p_ParallelCount := p_ParallelCount_3cb0b576b680, p_ParallelCount_Clear := TRUE, p_ParallelConfigParam := p_ParallelConfigParam_3cb0b576b680, p_ParallelConfigParam_Clear := TRUE, p_OutputType := p_OutputType_3cb0b576b680, p_OutputExample := p_OutputExample_3cb0b576b680, p_OutputExample_Clear := TRUE, p_ValidationBehavior := p_ValidationBehavior_3cb0b576b680, p_MaxRetries := p_MaxRetries_3cb0b576b680, p_RetryDelayMS := p_RetryDelayMS_3cb0b576b680, p_RetryStrategy := p_RetryStrategy_3cb0b576b680, p_ResultSelectorPromptID := p_ResultSelectorPromptID_3cb0b576b680, p_ResultSelectorPromptID_Clear := TRUE, p_EnableCaching := p_EnableCaching_3cb0b576b680, p_CacheTTLSeconds := p_CacheTTLSeconds_3cb0b576b680, p_CacheTTLSeconds_Clear := TRUE, p_CacheMatchType := p_CacheMatchType_3cb0b576b680, p_CacheSimilarityThreshold := p_CacheSimilarityThreshold_3cb0b576b680, p_CacheSimilarityThreshold_Clear := TRUE, p_CacheMustMatchModel := p_CacheMustMatchModel_3cb0b576b680, p_CacheMustMatchVendor := p_CacheMustMatchVendor_3cb0b576b680, p_CacheMustMatchAgent := p_CacheMustMatchAgent_3cb0b576b680, p_CacheMustMatchConfig := p_CacheMustMatchConfig_3cb0b576b680, p_PromptRole := p_PromptRole_3cb0b576b680, p_PromptPosition := p_PromptPosition_3cb0b576b680, p_Temperature := p_Temperature_3cb0b576b680, p_Temperature_Clear := TRUE, p_TopP := p_TopP_3cb0b576b680, p_TopP_Clear := TRUE, p_TopK := p_TopK_3cb0b576b680, p_TopK_Clear := TRUE, p_MinP := p_MinP_3cb0b576b680, p_MinP_Clear := TRUE, p_FrequencyPenalty := p_FrequencyPenalty_3cb0b576b680, p_FrequencyPenalty_Clear := TRUE, p_PresencePenalty := p_PresencePenalty_3cb0b576b680, p_PresencePenalty_Clear := TRUE, p_Seed := p_Seed_3cb0b576b680, p_Seed_Clear := TRUE, p_StopSequences := p_StopSequences_3cb0b576b680, p_StopSequences_Clear := TRUE, p_IncludeLogProbs := p_IncludeLogProbs_3cb0b576b680, p_TopLogProbs := p_TopLogProbs_3cb0b576b680, p_TopLogProbs_Clear := TRUE, p_FailoverStrategy := p_FailoverStrategy_3cb0b576b680, p_FailoverMaxAttempts := p_FailoverMaxAttempts_3cb0b576b680, p_FailoverDelaySeconds := p_FailoverDelaySeconds_3cb0b576b680, p_FailoverModelStrategy := p_FailoverModelStrategy_3cb0b576b680, p_FailoverErrorScope := p_FailoverErrorScope_3cb0b576b680, p_EffortLevel := p_EffortLevel_3cb0b576b680, p_EffortLevel_Clear := TRUE, p_AssistantPrefill := p_AssistantPrefill_3cb0b576b680, p_AssistantPrefill_Clear := TRUE, p_PrefillFallbackMode := p_PrefillFallbackMode_3cb0b576b680, p_RequireSpecificModels := p_RequireSpecificModels_3cb0b576b680, p_PromptConfiguration := p_PromptConfiguration_3cb0b576b680, p_PromptConfiguration_Clear := TRUE, p_TemplateDataCapture := p_TemplateDataCapture_3cb0b576b680, p_TemplateDataCapture_Clear := TRUE);
    END IF;
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Meeting Agenda Item Types (core SP call only)
DO $mj$
DECLARE
  p_ID_70c533beddd8 UUID;
  p_Name_70c533beddd8 VARCHAR(100);
  p_Code_70c533beddd8 VARCHAR(50);
  p_Description_70c533beddd8 TEXT;
  p_IconClass_70c533beddd8 VARCHAR(100);
  p_DefaultDurationMinutes_70c533beddd8 INTEGER;
  p_IsActive_70c533beddd8 BOOLEAN;
  p_Sequence_70c533beddd8 INTEGER;
BEGIN
  p_ID_70c533beddd8 := 'CA657C84-DF86-47A0-B096-9294E9E5689A';
  p_Name_70c533beddd8 := 'Information';
  p_Code_70c533beddd8 := 'INFORMATION';
  p_Description_70c533beddd8 := 'Something the meeting is told, with no decision asked.';
  p_IconClass_70c533beddd8 := 'fa-solid fa-circle-info';
  p_DefaultDurationMinutes_70c533beddd8 := 5;
  p_IsActive_70c533beddd8 := TRUE;
  p_Sequence_70c533beddd8 := 100;
  IF NOT EXISTS (SELECT 1 FROM __mj_BizAppsTasks."MeetingAgendaItemType"
                 WHERE "ID" = p_ID_70c533beddd8
                    OR ("Name" = p_Name_70c533beddd8)
                    OR ("Code" = p_Code_70c533beddd8)) THEN
    -- Written directly: the Meetings PostgreSQL migration ships no CRUD functions for this table.
    INSERT INTO __mj_BizAppsTasks."MeetingAgendaItemType" ("ID", "Name", "Code", "Description", "IconClass", "DefaultDurationMinutes", "IsActive", "Sequence")
    VALUES (p_ID_70c533beddd8, p_Name_70c533beddd8, p_Code_70c533beddd8, p_Description_70c533beddd8, p_IconClass_70c533beddd8, p_DefaultDurationMinutes_70c533beddd8, p_IsActive_70c533beddd8, p_Sequence_70c533beddd8);
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Meeting Agenda Item Types (core SP call only)
DO $mj$
DECLARE
  p_ID_dc2aa7460d3c UUID;
  p_Name_dc2aa7460d3c VARCHAR(100);
  p_Code_dc2aa7460d3c VARCHAR(50);
  p_Description_dc2aa7460d3c TEXT;
  p_IconClass_dc2aa7460d3c VARCHAR(100);
  p_DefaultDurationMinutes_dc2aa7460d3c INTEGER;
  p_IsActive_dc2aa7460d3c BOOLEAN;
  p_Sequence_dc2aa7460d3c INTEGER;
BEGIN
  p_ID_dc2aa7460d3c := 'C9B934EA-D3B7-4C57-B514-ADA190D23EA0';
  p_Name_dc2aa7460d3c := 'Discussion';
  p_Code_dc2aa7460d3c := 'DISCUSSION';
  p_Description_dc2aa7460d3c := 'Something the meeting talks through.';
  p_IconClass_dc2aa7460d3c := 'fa-solid fa-comments';
  p_DefaultDurationMinutes_dc2aa7460d3c := 15;
  p_IsActive_dc2aa7460d3c := TRUE;
  p_Sequence_dc2aa7460d3c := 200;
  IF NOT EXISTS (SELECT 1 FROM __mj_BizAppsTasks."MeetingAgendaItemType"
                 WHERE "ID" = p_ID_dc2aa7460d3c
                    OR ("Name" = p_Name_dc2aa7460d3c)
                    OR ("Code" = p_Code_dc2aa7460d3c)) THEN
    -- Written directly: the Meetings PostgreSQL migration ships no CRUD functions for this table.
    INSERT INTO __mj_BizAppsTasks."MeetingAgendaItemType" ("ID", "Name", "Code", "Description", "IconClass", "DefaultDurationMinutes", "IsActive", "Sequence")
    VALUES (p_ID_dc2aa7460d3c, p_Name_dc2aa7460d3c, p_Code_dc2aa7460d3c, p_Description_dc2aa7460d3c, p_IconClass_dc2aa7460d3c, p_DefaultDurationMinutes_dc2aa7460d3c, p_IsActive_dc2aa7460d3c, p_Sequence_dc2aa7460d3c);
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Meeting Agenda Item Types (core SP call only)
DO $mj$
DECLARE
  p_ID_e44c58e353f1 UUID;
  p_Name_e44c58e353f1 VARCHAR(100);
  p_Code_e44c58e353f1 VARCHAR(50);
  p_Description_e44c58e353f1 TEXT;
  p_IconClass_e44c58e353f1 VARCHAR(100);
  p_DefaultDurationMinutes_e44c58e353f1 INTEGER;
  p_IsActive_e44c58e353f1 BOOLEAN;
  p_Sequence_e44c58e353f1 INTEGER;
BEGIN
  p_ID_e44c58e353f1 := 'D3613068-B072-447B-B487-3F9BE27BCD25';
  p_Name_e44c58e353f1 := 'Decision';
  p_Code_e44c58e353f1 := 'DECISION';
  p_Description_e44c58e353f1 := 'Something the meeting settles; its outcome is recorded on the item.';
  p_IconClass_e44c58e353f1 := 'fa-solid fa-gavel';
  p_DefaultDurationMinutes_e44c58e353f1 := 10;
  p_IsActive_e44c58e353f1 := TRUE;
  p_Sequence_e44c58e353f1 := 300;
  IF NOT EXISTS (SELECT 1 FROM __mj_BizAppsTasks."MeetingAgendaItemType"
                 WHERE "ID" = p_ID_e44c58e353f1
                    OR ("Name" = p_Name_e44c58e353f1)
                    OR ("Code" = p_Code_e44c58e353f1)) THEN
    -- Written directly: the Meetings PostgreSQL migration ships no CRUD functions for this table.
    INSERT INTO __mj_BizAppsTasks."MeetingAgendaItemType" ("ID", "Name", "Code", "Description", "IconClass", "DefaultDurationMinutes", "IsActive", "Sequence")
    VALUES (p_ID_e44c58e353f1, p_Name_e44c58e353f1, p_Code_e44c58e353f1, p_Description_e44c58e353f1, p_IconClass_e44c58e353f1, p_DefaultDurationMinutes_e44c58e353f1, p_IsActive_e44c58e353f1, p_Sequence_e44c58e353f1);
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Meeting Agenda Item Types (core SP call only)
DO $mj$
DECLARE
  p_ID_5442aaa0f6b7 UUID;
  p_Name_5442aaa0f6b7 VARCHAR(100);
  p_Code_5442aaa0f6b7 VARCHAR(50);
  p_Description_5442aaa0f6b7 TEXT;
  p_IconClass_5442aaa0f6b7 VARCHAR(100);
  p_DefaultDurationMinutes_5442aaa0f6b7 INTEGER;
  p_IsActive_5442aaa0f6b7 BOOLEAN;
  p_Sequence_5442aaa0f6b7 INTEGER;
BEGIN
  p_ID_5442aaa0f6b7 := '64177922-416C-41E9-991E-C50AF765C81E';
  p_Name_5442aaa0f6b7 := 'Report';
  p_Code_5442aaa0f6b7 := 'REPORT';
  p_Description_5442aaa0f6b7 := 'A report given to the meeting.';
  p_IconClass_5442aaa0f6b7 := 'fa-solid fa-file-lines';
  p_DefaultDurationMinutes_5442aaa0f6b7 := 10;
  p_IsActive_5442aaa0f6b7 := TRUE;
  p_Sequence_5442aaa0f6b7 := 400;
  IF NOT EXISTS (SELECT 1 FROM __mj_BizAppsTasks."MeetingAgendaItemType"
                 WHERE "ID" = p_ID_5442aaa0f6b7
                    OR ("Name" = p_Name_5442aaa0f6b7)
                    OR ("Code" = p_Code_5442aaa0f6b7)) THEN
    -- Written directly: the Meetings PostgreSQL migration ships no CRUD functions for this table.
    INSERT INTO __mj_BizAppsTasks."MeetingAgendaItemType" ("ID", "Name", "Code", "Description", "IconClass", "DefaultDurationMinutes", "IsActive", "Sequence")
    VALUES (p_ID_5442aaa0f6b7, p_Name_5442aaa0f6b7, p_Code_5442aaa0f6b7, p_Description_5442aaa0f6b7, p_IconClass_5442aaa0f6b7, p_DefaultDurationMinutes_5442aaa0f6b7, p_IsActive_5442aaa0f6b7, p_Sequence_5442aaa0f6b7);
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Meeting Agenda Item Types (core SP call only)
DO $mj$
DECLARE
  p_ID_e2a43675ea1d UUID;
  p_Name_e2a43675ea1d VARCHAR(100);
  p_Code_e2a43675ea1d VARCHAR(50);
  p_Description_e2a43675ea1d TEXT;
  p_IconClass_e2a43675ea1d VARCHAR(100);
  p_DefaultDurationMinutes_e2a43675ea1d INTEGER;
  p_IsActive_e2a43675ea1d BOOLEAN;
  p_Sequence_e2a43675ea1d INTEGER;
BEGIN
  p_ID_e2a43675ea1d := '18F5F490-D474-43BF-92EF-036E32C7A9C8';
  p_Name_e2a43675ea1d := 'Presentation';
  p_Code_e2a43675ea1d := 'PRESENTATION';
  p_Description_e2a43675ea1d := 'Something shown to the meeting.';
  p_IconClass_e2a43675ea1d := 'fa-solid fa-chalkboard-user';
  p_DefaultDurationMinutes_e2a43675ea1d := 20;
  p_IsActive_e2a43675ea1d := TRUE;
  p_Sequence_e2a43675ea1d := 500;
  IF NOT EXISTS (SELECT 1 FROM __mj_BizAppsTasks."MeetingAgendaItemType"
                 WHERE "ID" = p_ID_e2a43675ea1d
                    OR ("Name" = p_Name_e2a43675ea1d)
                    OR ("Code" = p_Code_e2a43675ea1d)) THEN
    -- Written directly: the Meetings PostgreSQL migration ships no CRUD functions for this table.
    INSERT INTO __mj_BizAppsTasks."MeetingAgendaItemType" ("ID", "Name", "Code", "Description", "IconClass", "DefaultDurationMinutes", "IsActive", "Sequence")
    VALUES (p_ID_e2a43675ea1d, p_Name_e2a43675ea1d, p_Code_e2a43675ea1d, p_Description_e2a43675ea1d, p_IconClass_e2a43675ea1d, p_DefaultDurationMinutes_e2a43675ea1d, p_IsActive_e2a43675ea1d, p_Sequence_e2a43675ea1d);
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Meeting Agenda Item Types (core SP call only)
DO $mj$
DECLARE
  p_ID_f6a94b2f57aa UUID;
  p_Name_f6a94b2f57aa VARCHAR(100);
  p_Code_f6a94b2f57aa VARCHAR(50);
  p_Description_f6a94b2f57aa TEXT;
  p_IconClass_f6a94b2f57aa VARCHAR(100);
  p_DefaultDurationMinutes_f6a94b2f57aa INTEGER;
  p_IsActive_f6a94b2f57aa BOOLEAN;
  p_Sequence_f6a94b2f57aa INTEGER;
BEGIN
  p_ID_f6a94b2f57aa := '59B4E080-8DE4-41EF-ABA2-1EDA4A4B0E86';
  p_Name_f6a94b2f57aa := 'Action review';
  p_Code_f6a94b2f57aa := 'ACTION_REVIEW';
  p_Description_f6a94b2f57aa := 'The follow-ups from last time and the ones captured today.';
  p_IconClass_f6a94b2f57aa := 'fa-solid fa-list-check';
  p_DefaultDurationMinutes_f6a94b2f57aa := 10;
  p_IsActive_f6a94b2f57aa := TRUE;
  p_Sequence_f6a94b2f57aa := 600;
  IF NOT EXISTS (SELECT 1 FROM __mj_BizAppsTasks."MeetingAgendaItemType"
                 WHERE "ID" = p_ID_f6a94b2f57aa
                    OR ("Name" = p_Name_f6a94b2f57aa)
                    OR ("Code" = p_Code_f6a94b2f57aa)) THEN
    -- Written directly: the Meetings PostgreSQL migration ships no CRUD functions for this table.
    INSERT INTO __mj_BizAppsTasks."MeetingAgendaItemType" ("ID", "Name", "Code", "Description", "IconClass", "DefaultDurationMinutes", "IsActive", "Sequence")
    VALUES (p_ID_f6a94b2f57aa, p_Name_f6a94b2f57aa, p_Code_f6a94b2f57aa, p_Description_f6a94b2f57aa, p_IconClass_f6a94b2f57aa, p_DefaultDurationMinutes_f6a94b2f57aa, p_IsActive_f6a94b2f57aa, p_Sequence_f6a94b2f57aa);
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Meeting Agenda Item Types (core SP call only)
DO $mj$
DECLARE
  p_ID_064a71ad6b35 UUID;
  p_Name_064a71ad6b35 VARCHAR(100);
  p_Code_064a71ad6b35 VARCHAR(50);
  p_Description_064a71ad6b35 TEXT;
  p_IconClass_064a71ad6b35 VARCHAR(100);
  p_DefaultDurationMinutes_064a71ad6b35 INTEGER;
  p_IsActive_064a71ad6b35 BOOLEAN;
  p_Sequence_064a71ad6b35 INTEGER;
BEGIN
  p_ID_064a71ad6b35 := '8A326396-C37C-4A80-8D1F-D74128AC4114';
  p_Name_064a71ad6b35 := 'Break';
  p_Code_064a71ad6b35 := 'BREAK';
  p_Description_064a71ad6b35 := 'A pause.';
  p_IconClass_064a71ad6b35 := 'fa-solid fa-mug-hot';
  p_DefaultDurationMinutes_064a71ad6b35 := 10;
  p_IsActive_064a71ad6b35 := TRUE;
  p_Sequence_064a71ad6b35 := 700;
  IF NOT EXISTS (SELECT 1 FROM __mj_BizAppsTasks."MeetingAgendaItemType"
                 WHERE "ID" = p_ID_064a71ad6b35
                    OR ("Name" = p_Name_064a71ad6b35)
                    OR ("Code" = p_Code_064a71ad6b35)) THEN
    -- Written directly: the Meetings PostgreSQL migration ships no CRUD functions for this table.
    INSERT INTO __mj_BizAppsTasks."MeetingAgendaItemType" ("ID", "Name", "Code", "Description", "IconClass", "DefaultDurationMinutes", "IsActive", "Sequence")
    VALUES (p_ID_064a71ad6b35, p_Name_064a71ad6b35, p_Code_064a71ad6b35, p_Description_064a71ad6b35, p_IconClass_064a71ad6b35, p_DefaultDurationMinutes_064a71ad6b35, p_IsActive_064a71ad6b35, p_Sequence_064a71ad6b35);
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Meeting Types (core SP call only)
DO $mj$
DECLARE
  p_ID_5cc2354db354 UUID;
  p_Name_5cc2354db354 VARCHAR(100);
  p_Code_5cc2354db354 VARCHAR(50);
  p_Description_5cc2354db354 TEXT;
  p_IconClass_5cc2354db354 VARCHAR(100);
  p_DefaultDurationMinutes_5cc2354db354 INTEGER;
  p_DefaultLocationType_5cc2354db354 VARCHAR(20);
  p_DefaultVideoProviderID_5cc2354db354 UUID;
  p_DefaultVisibility_5cc2354db354 VARCHAR(20);
  p_AgendaTemplate_5cc2354db354 TEXT;
  p_NotesPromptID_5cc2354db354 UUID;
  p_IsActive_5cc2354db354 BOOLEAN;
  p_Sequence_5cc2354db354 INTEGER;
BEGIN
  p_ID_5cc2354db354 := '712D5318-E123-49AE-918A-1BA0901DACFC';
  p_Name_5cc2354db354 := 'General';
  p_Code_5cc2354db354 := 'GENERAL';
  p_Description_5cc2354db354 := 'A meeting with no particular shape: a title, a time, the people and an agenda.';
  p_IconClass_5cc2354db354 := 'fa-solid fa-calendar-day';
  p_DefaultDurationMinutes_5cc2354db354 := 30;
  p_DefaultLocationType_5cc2354db354 := 'Virtual';
  p_DefaultVisibility_5cc2354db354 := 'Standard';
  p_AgendaTemplate_5cc2354db354 := '{"items": [{"title": "Purpose", "typeCode": "INFORMATION", "durationMinutes": 5}, {"title": "Discussion", "typeCode": "DISCUSSION", "durationMinutes": 20}, {"title": "Next steps", "typeCode": "ACTION_REVIEW", "durationMinutes": 5}]}';
  p_IsActive_5cc2354db354 := TRUE;
  p_Sequence_5cc2354db354 := 100;
  IF NOT EXISTS (SELECT 1 FROM __mj_BizAppsTasks."MeetingType"
                 WHERE "ID" = p_ID_5cc2354db354
                    OR ("Name" = p_Name_5cc2354db354)
                    OR ("Code" = p_Code_5cc2354db354)) THEN
    -- Written directly: the Meetings PostgreSQL migration ships no CRUD functions for this table.
    INSERT INTO __mj_BizAppsTasks."MeetingType" ("ID", "Name", "Code", "Description", "IconClass", "DefaultDurationMinutes", "DefaultLocationType", "DefaultVideoProviderID", "DefaultVisibility", "AgendaTemplate", "NotesPromptID", "IsActive", "Sequence")
    VALUES (p_ID_5cc2354db354, p_Name_5cc2354db354, p_Code_5cc2354db354, p_Description_5cc2354db354, p_IconClass_5cc2354db354, p_DefaultDurationMinutes_5cc2354db354, p_DefaultLocationType_5cc2354db354, p_DefaultVideoProviderID_5cc2354db354, p_DefaultVisibility_5cc2354db354, p_AgendaTemplate_5cc2354db354, p_NotesPromptID_5cc2354db354, p_IsActive_5cc2354db354, p_Sequence_5cc2354db354);
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Meeting Types (core SP call only)
DO $mj$
DECLARE
  p_ID_88137a53752d UUID;
  p_Name_88137a53752d VARCHAR(100);
  p_Code_88137a53752d VARCHAR(50);
  p_Description_88137a53752d TEXT;
  p_IconClass_88137a53752d VARCHAR(100);
  p_DefaultDurationMinutes_88137a53752d INTEGER;
  p_DefaultLocationType_88137a53752d VARCHAR(20);
  p_DefaultVideoProviderID_88137a53752d UUID;
  p_DefaultVisibility_88137a53752d VARCHAR(20);
  p_AgendaTemplate_88137a53752d TEXT;
  p_NotesPromptID_88137a53752d UUID;
  p_IsActive_88137a53752d BOOLEAN;
  p_Sequence_88137a53752d INTEGER;
BEGIN
  p_ID_88137a53752d := '6294489D-D3BF-4E9D-84C1-DD75B70D0E4A';
  p_Name_88137a53752d := 'One-on-one';
  p_Code_88137a53752d := 'ONE_ON_ONE';
  p_Description_88137a53752d := 'Two people, in private: the meeting and its notes are seen by its attendees only.';
  p_IconClass_88137a53752d := 'fa-solid fa-user-group';
  p_DefaultDurationMinutes_88137a53752d := 30;
  p_DefaultLocationType_88137a53752d := 'Virtual';
  p_DefaultVisibility_88137a53752d := 'Private';
  p_AgendaTemplate_88137a53752d := '{"items": [{"title": "How things are going", "typeCode": "DISCUSSION", "durationMinutes": 10}, {"title": "Priorities", "typeCode": "DISCUSSION", "durationMinutes": 10}, {"title": "Follow-ups", "typeCode": "ACTION_REVIEW", "durationMinutes": 10}]}';
  p_IsActive_88137a53752d := TRUE;
  p_Sequence_88137a53752d := 200;
  IF NOT EXISTS (SELECT 1 FROM __mj_BizAppsTasks."MeetingType"
                 WHERE "ID" = p_ID_88137a53752d
                    OR ("Name" = p_Name_88137a53752d)
                    OR ("Code" = p_Code_88137a53752d)) THEN
    -- Written directly: the Meetings PostgreSQL migration ships no CRUD functions for this table.
    INSERT INTO __mj_BizAppsTasks."MeetingType" ("ID", "Name", "Code", "Description", "IconClass", "DefaultDurationMinutes", "DefaultLocationType", "DefaultVideoProviderID", "DefaultVisibility", "AgendaTemplate", "NotesPromptID", "IsActive", "Sequence")
    VALUES (p_ID_88137a53752d, p_Name_88137a53752d, p_Code_88137a53752d, p_Description_88137a53752d, p_IconClass_88137a53752d, p_DefaultDurationMinutes_88137a53752d, p_DefaultLocationType_88137a53752d, p_DefaultVideoProviderID_88137a53752d, p_DefaultVisibility_88137a53752d, p_AgendaTemplate_88137a53752d, p_NotesPromptID_88137a53752d, p_IsActive_88137a53752d, p_Sequence_88137a53752d);
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Meeting Types (core SP call only)
DO $mj$
DECLARE
  p_ID_2ad1c4cdf7f5 UUID;
  p_Name_2ad1c4cdf7f5 VARCHAR(100);
  p_Code_2ad1c4cdf7f5 VARCHAR(50);
  p_Description_2ad1c4cdf7f5 TEXT;
  p_IconClass_2ad1c4cdf7f5 VARCHAR(100);
  p_DefaultDurationMinutes_2ad1c4cdf7f5 INTEGER;
  p_DefaultLocationType_2ad1c4cdf7f5 VARCHAR(20);
  p_DefaultVideoProviderID_2ad1c4cdf7f5 UUID;
  p_DefaultVisibility_2ad1c4cdf7f5 VARCHAR(20);
  p_AgendaTemplate_2ad1c4cdf7f5 TEXT;
  p_NotesPromptID_2ad1c4cdf7f5 UUID;
  p_IsActive_2ad1c4cdf7f5 BOOLEAN;
  p_Sequence_2ad1c4cdf7f5 INTEGER;
BEGIN
  p_ID_2ad1c4cdf7f5 := '6A15935E-7BE8-4703-9A24-FA099818B318';
  p_Name_2ad1c4cdf7f5 := 'Team';
  p_Code_2ad1c4cdf7f5 := 'TEAM';
  p_Description_2ad1c4cdf7f5 := 'A team''s regular meeting: what moved, what is blocked, what is next.';
  p_IconClass_2ad1c4cdf7f5 := 'fa-solid fa-people-group';
  p_DefaultDurationMinutes_2ad1c4cdf7f5 := 60;
  p_DefaultLocationType_2ad1c4cdf7f5 := 'Virtual';
  p_DefaultVisibility_2ad1c4cdf7f5 := 'Standard';
  p_AgendaTemplate_2ad1c4cdf7f5 := '{"items": [{"title": "Updates", "typeCode": "REPORT", "durationMinutes": 15}, {"title": "Blockers", "typeCode": "DISCUSSION", "durationMinutes": 20}, {"title": "Decisions", "typeCode": "DECISION", "durationMinutes": 15}, {"title": "Action items", "typeCode": "ACTION_REVIEW", "durationMinutes": 10}]}';
  p_IsActive_2ad1c4cdf7f5 := TRUE;
  p_Sequence_2ad1c4cdf7f5 := 300;
  IF NOT EXISTS (SELECT 1 FROM __mj_BizAppsTasks."MeetingType"
                 WHERE "ID" = p_ID_2ad1c4cdf7f5
                    OR ("Name" = p_Name_2ad1c4cdf7f5)
                    OR ("Code" = p_Code_2ad1c4cdf7f5)) THEN
    -- Written directly: the Meetings PostgreSQL migration ships no CRUD functions for this table.
    INSERT INTO __mj_BizAppsTasks."MeetingType" ("ID", "Name", "Code", "Description", "IconClass", "DefaultDurationMinutes", "DefaultLocationType", "DefaultVideoProviderID", "DefaultVisibility", "AgendaTemplate", "NotesPromptID", "IsActive", "Sequence")
    VALUES (p_ID_2ad1c4cdf7f5, p_Name_2ad1c4cdf7f5, p_Code_2ad1c4cdf7f5, p_Description_2ad1c4cdf7f5, p_IconClass_2ad1c4cdf7f5, p_DefaultDurationMinutes_2ad1c4cdf7f5, p_DefaultLocationType_2ad1c4cdf7f5, p_DefaultVideoProviderID_2ad1c4cdf7f5, p_DefaultVisibility_2ad1c4cdf7f5, p_AgendaTemplate_2ad1c4cdf7f5, p_NotesPromptID_2ad1c4cdf7f5, p_IsActive_2ad1c4cdf7f5, p_Sequence_2ad1c4cdf7f5);
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Meeting Types (core SP call only)
DO $mj$
DECLARE
  p_ID_2d2a46d0319d UUID;
  p_Name_2d2a46d0319d VARCHAR(100);
  p_Code_2d2a46d0319d VARCHAR(50);
  p_Description_2d2a46d0319d TEXT;
  p_IconClass_2d2a46d0319d VARCHAR(100);
  p_DefaultDurationMinutes_2d2a46d0319d INTEGER;
  p_DefaultLocationType_2d2a46d0319d VARCHAR(20);
  p_DefaultVideoProviderID_2d2a46d0319d UUID;
  p_DefaultVisibility_2d2a46d0319d VARCHAR(20);
  p_AgendaTemplate_2d2a46d0319d TEXT;
  p_NotesPromptID_2d2a46d0319d UUID;
  p_IsActive_2d2a46d0319d BOOLEAN;
  p_Sequence_2d2a46d0319d INTEGER;
BEGIN
  p_ID_2d2a46d0319d := 'A66B95B4-20AF-4E42-915F-94BC1FB6E2D5';
  p_Name_2d2a46d0319d := 'Client';
  p_Code_2d2a46d0319d := 'CLIENT';
  p_Description_2d2a46d0319d := 'A meeting with a client or a partner, with the record it belongs to linked.';
  p_IconClass_2d2a46d0319d := 'fa-solid fa-handshake';
  p_DefaultDurationMinutes_2d2a46d0319d := 60;
  p_DefaultLocationType_2d2a46d0319d := 'Virtual';
  p_DefaultVisibility_2d2a46d0319d := 'Standard';
  p_AgendaTemplate_2d2a46d0319d := '{"items": [{"title": "Welcome and goals", "typeCode": "INFORMATION", "durationMinutes": 5}, {"title": "Review", "typeCode": "PRESENTATION", "durationMinutes": 25}, {"title": "Questions", "typeCode": "DISCUSSION", "durationMinutes": 20}, {"title": "Next steps", "typeCode": "ACTION_REVIEW", "durationMinutes": 10}]}';
  p_IsActive_2d2a46d0319d := TRUE;
  p_Sequence_2d2a46d0319d := 400;
  IF NOT EXISTS (SELECT 1 FROM __mj_BizAppsTasks."MeetingType"
                 WHERE "ID" = p_ID_2d2a46d0319d
                    OR ("Name" = p_Name_2d2a46d0319d)
                    OR ("Code" = p_Code_2d2a46d0319d)) THEN
    -- Written directly: the Meetings PostgreSQL migration ships no CRUD functions for this table.
    INSERT INTO __mj_BizAppsTasks."MeetingType" ("ID", "Name", "Code", "Description", "IconClass", "DefaultDurationMinutes", "DefaultLocationType", "DefaultVideoProviderID", "DefaultVisibility", "AgendaTemplate", "NotesPromptID", "IsActive", "Sequence")
    VALUES (p_ID_2d2a46d0319d, p_Name_2d2a46d0319d, p_Code_2d2a46d0319d, p_Description_2d2a46d0319d, p_IconClass_2d2a46d0319d, p_DefaultDurationMinutes_2d2a46d0319d, p_DefaultLocationType_2d2a46d0319d, p_DefaultVideoProviderID_2d2a46d0319d, p_DefaultVisibility_2d2a46d0319d, p_AgendaTemplate_2d2a46d0319d, p_NotesPromptID_2d2a46d0319d, p_IsActive_2d2a46d0319d, p_Sequence_2d2a46d0319d);
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Meeting Types (core SP call only)
DO $mj$
DECLARE
  p_ID_9f0dde3db36e UUID;
  p_Name_9f0dde3db36e VARCHAR(100);
  p_Code_9f0dde3db36e VARCHAR(50);
  p_Description_9f0dde3db36e TEXT;
  p_IconClass_9f0dde3db36e VARCHAR(100);
  p_DefaultDurationMinutes_9f0dde3db36e INTEGER;
  p_DefaultLocationType_9f0dde3db36e VARCHAR(20);
  p_DefaultVideoProviderID_9f0dde3db36e UUID;
  p_DefaultVisibility_9f0dde3db36e VARCHAR(20);
  p_AgendaTemplate_9f0dde3db36e TEXT;
  p_NotesPromptID_9f0dde3db36e UUID;
  p_IsActive_9f0dde3db36e BOOLEAN;
  p_Sequence_9f0dde3db36e INTEGER;
BEGIN
  p_ID_9f0dde3db36e := '69917FB5-3B5F-4397-81E2-99A9732E25BB';
  p_Name_9f0dde3db36e := 'Review';
  p_Code_9f0dde3db36e := 'REVIEW';
  p_Description_9f0dde3db36e := 'A review of work done: what was delivered, what was learned, what changes.';
  p_IconClass_9f0dde3db36e := 'fa-solid fa-magnifying-glass-chart';
  p_DefaultDurationMinutes_9f0dde3db36e := 60;
  p_DefaultLocationType_9f0dde3db36e := 'Virtual';
  p_DefaultVisibility_9f0dde3db36e := 'Standard';
  p_AgendaTemplate_9f0dde3db36e := '{"items": [{"title": "What was delivered", "typeCode": "PRESENTATION", "durationMinutes": 20}, {"title": "What we learned", "typeCode": "DISCUSSION", "durationMinutes": 25}, {"title": "What changes", "typeCode": "DECISION", "durationMinutes": 15}]}';
  p_IsActive_9f0dde3db36e := TRUE;
  p_Sequence_9f0dde3db36e := 500;
  IF NOT EXISTS (SELECT 1 FROM __mj_BizAppsTasks."MeetingType"
                 WHERE "ID" = p_ID_9f0dde3db36e
                    OR ("Name" = p_Name_9f0dde3db36e)
                    OR ("Code" = p_Code_9f0dde3db36e)) THEN
    -- Written directly: the Meetings PostgreSQL migration ships no CRUD functions for this table.
    INSERT INTO __mj_BizAppsTasks."MeetingType" ("ID", "Name", "Code", "Description", "IconClass", "DefaultDurationMinutes", "DefaultLocationType", "DefaultVideoProviderID", "DefaultVisibility", "AgendaTemplate", "NotesPromptID", "IsActive", "Sequence")
    VALUES (p_ID_9f0dde3db36e, p_Name_9f0dde3db36e, p_Code_9f0dde3db36e, p_Description_9f0dde3db36e, p_IconClass_9f0dde3db36e, p_DefaultDurationMinutes_9f0dde3db36e, p_DefaultLocationType_9f0dde3db36e, p_DefaultVideoProviderID_9f0dde3db36e, p_DefaultVisibility_9f0dde3db36e, p_AgendaTemplate_9f0dde3db36e, p_NotesPromptID_9f0dde3db36e, p_IsActive_9f0dde3db36e, p_Sequence_9f0dde3db36e);
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Video Providers (core SP call only)
DO $mj$
DECLARE
  p_ID_bd644b7c45b5 UUID;
  p_Name_bd644b7c45b5 VARCHAR(100);
  p_Code_bd644b7c45b5 VARCHAR(50);
  p_DriverClass_bd644b7c45b5 VARCHAR(255);
  p_Description_bd644b7c45b5 TEXT;
  p_IconClass_bd644b7c45b5 VARCHAR(100);
  p_CredentialID_bd644b7c45b5 UUID;
  p_Configuration_bd644b7c45b5 TEXT;
  p_SupportsTranscripts_bd644b7c45b5 BOOLEAN;
  p_IsDefault_bd644b7c45b5 BOOLEAN;
  p_IsActive_bd644b7c45b5 BOOLEAN;
BEGIN
  p_ID_bd644b7c45b5 := '7CF590BE-5C5D-4873-A1E5-4F1AE51FA549';
  p_Name_bd644b7c45b5 := 'Zoom';
  p_Code_bd644b7c45b5 := 'ZOOM';
  p_DriverClass_bd644b7c45b5 := 'ZoomVideoProvider';
  p_Description_bd644b7c45b5 := 'Zoom, through a Server-to-Server OAuth app. Creates and deletes the meeting, registers attendees, and fetches the transcript of a recorded meeting.';
  p_IconClass_bd644b7c45b5 := 'fa-solid fa-video';
  p_SupportsTranscripts_bd644b7c45b5 := TRUE;
  p_IsDefault_bd644b7c45b5 := FALSE;
  p_IsActive_bd644b7c45b5 := FALSE;
  IF NOT EXISTS (SELECT 1 FROM __mj_BizAppsTasks."VideoProvider"
                 WHERE "ID" = p_ID_bd644b7c45b5
                    OR ("Name" = p_Name_bd644b7c45b5)
                    OR ("Code" = p_Code_bd644b7c45b5)) THEN
    -- Written directly: the Meetings PostgreSQL migration ships no CRUD functions for this table.
    INSERT INTO __mj_BizAppsTasks."VideoProvider" ("ID", "Name", "Code", "DriverClass", "Description", "IconClass", "CredentialID", "Configuration", "SupportsTranscripts", "IsDefault", "IsActive")
    VALUES (p_ID_bd644b7c45b5, p_Name_bd644b7c45b5, p_Code_bd644b7c45b5, p_DriverClass_bd644b7c45b5, p_Description_bd644b7c45b5, p_IconClass_bd644b7c45b5, p_CredentialID_bd644b7c45b5, p_Configuration_bd644b7c45b5, p_SupportsTranscripts_bd644b7c45b5, p_IsDefault_bd644b7c45b5, p_IsActive_bd644b7c45b5);
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Video Providers (core SP call only)
DO $mj$
DECLARE
  p_ID_afad5a02c0f5 UUID;
  p_Name_afad5a02c0f5 VARCHAR(100);
  p_Code_afad5a02c0f5 VARCHAR(50);
  p_DriverClass_afad5a02c0f5 VARCHAR(255);
  p_Description_afad5a02c0f5 TEXT;
  p_IconClass_afad5a02c0f5 VARCHAR(100);
  p_CredentialID_afad5a02c0f5 UUID;
  p_Configuration_afad5a02c0f5 TEXT;
  p_SupportsTranscripts_afad5a02c0f5 BOOLEAN;
  p_IsDefault_afad5a02c0f5 BOOLEAN;
  p_IsActive_afad5a02c0f5 BOOLEAN;
BEGIN
  p_ID_afad5a02c0f5 := '41DB5054-D2DF-4068-BA5D-D692340F6D2C';
  p_Name_afad5a02c0f5 := 'Microsoft Teams';
  p_Code_afad5a02c0f5 := 'TEAMS';
  p_DriverClass_afad5a02c0f5 := '';
  p_Description_afad5a02c0f5 := 'Microsoft Teams. Calendar-native via MemberJunction''s calendar sync (A18), which creates the online meeting with the calendar event and reads the join details back.';
  p_IconClass_afad5a02c0f5 := 'fa-brands fa-microsoft';
  p_SupportsTranscripts_afad5a02c0f5 := FALSE;
  p_IsDefault_afad5a02c0f5 := FALSE;
  p_IsActive_afad5a02c0f5 := FALSE;
  IF NOT EXISTS (SELECT 1 FROM __mj_BizAppsTasks."VideoProvider"
                 WHERE "ID" = p_ID_afad5a02c0f5
                    OR ("Name" = p_Name_afad5a02c0f5)
                    OR ("Code" = p_Code_afad5a02c0f5)) THEN
    -- Written directly: the Meetings PostgreSQL migration ships no CRUD functions for this table.
    INSERT INTO __mj_BizAppsTasks."VideoProvider" ("ID", "Name", "Code", "DriverClass", "Description", "IconClass", "CredentialID", "Configuration", "SupportsTranscripts", "IsDefault", "IsActive")
    VALUES (p_ID_afad5a02c0f5, p_Name_afad5a02c0f5, p_Code_afad5a02c0f5, p_DriverClass_afad5a02c0f5, p_Description_afad5a02c0f5, p_IconClass_afad5a02c0f5, p_CredentialID_afad5a02c0f5, p_Configuration_afad5a02c0f5, p_SupportsTranscripts_afad5a02c0f5, p_IsDefault_afad5a02c0f5, p_IsActive_afad5a02c0f5);
  END IF;
END $mj$;

-- Save MJ_BizApps_Tasks: Video Providers (core SP call only)
DO $mj$
DECLARE
  p_ID_c163f07e8ba1 UUID;
  p_Name_c163f07e8ba1 VARCHAR(100);
  p_Code_c163f07e8ba1 VARCHAR(50);
  p_DriverClass_c163f07e8ba1 VARCHAR(255);
  p_Description_c163f07e8ba1 TEXT;
  p_IconClass_c163f07e8ba1 VARCHAR(100);
  p_CredentialID_c163f07e8ba1 UUID;
  p_Configuration_c163f07e8ba1 TEXT;
  p_SupportsTranscripts_c163f07e8ba1 BOOLEAN;
  p_IsDefault_c163f07e8ba1 BOOLEAN;
  p_IsActive_c163f07e8ba1 BOOLEAN;
BEGIN
  p_ID_c163f07e8ba1 := '40540DFF-9A8F-4114-82EC-988CA8F00D00';
  p_Name_c163f07e8ba1 := 'Google Meet';
  p_Code_c163f07e8ba1 := 'GOOGLE_MEET';
  p_DriverClass_c163f07e8ba1 := '';
  p_Description_c163f07e8ba1 := 'Google Meet. Calendar-native via MemberJunction''s calendar sync (A18), which creates the conference with the calendar event and reads the join details back.';
  p_IconClass_c163f07e8ba1 := 'fa-brands fa-google';
  p_SupportsTranscripts_c163f07e8ba1 := FALSE;
  p_IsDefault_c163f07e8ba1 := FALSE;
  p_IsActive_c163f07e8ba1 := FALSE;
  IF NOT EXISTS (SELECT 1 FROM __mj_BizAppsTasks."VideoProvider"
                 WHERE "ID" = p_ID_c163f07e8ba1
                    OR ("Name" = p_Name_c163f07e8ba1)
                    OR ("Code" = p_Code_c163f07e8ba1)) THEN
    -- Written directly: the Meetings PostgreSQL migration ships no CRUD functions for this table.
    INSERT INTO __mj_BizAppsTasks."VideoProvider" ("ID", "Name", "Code", "DriverClass", "Description", "IconClass", "CredentialID", "Configuration", "SupportsTranscripts", "IsDefault", "IsActive")
    VALUES (p_ID_c163f07e8ba1, p_Name_c163f07e8ba1, p_Code_c163f07e8ba1, p_DriverClass_c163f07e8ba1, p_Description_c163f07e8ba1, p_IconClass_c163f07e8ba1, p_CredentialID_c163f07e8ba1, p_Configuration_c163f07e8ba1, p_SupportsTranscripts_c163f07e8ba1, p_IsDefault_c163f07e8ba1, p_IsActive_c163f07e8ba1);
  END IF;
END $mj$;

-- Save MJ: Scheduled Job Types (core SP call only)
DO $mj$
DECLARE
  p_ID_3cebbb424528 UUID;
  p_Name_3cebbb424528 VARCHAR(100);
  p_Description_3cebbb424528 TEXT;
  p_DriverClass_3cebbb424528 VARCHAR(255);
  p_DomainRunEntity_3cebbb424528 VARCHAR(255);
  p_DomainRunEntityFKey_3cebbb424528 VARCHAR(100);
  p_NotificationsAvailable_3cebbb424528 BOOLEAN;
BEGIN
  p_ID_3cebbb424528 := '28024F60-CF1D-4168-900E-852D83E28E7B';
  p_Name_3cebbb424528 := 'Meeting Series Materialization';
  p_Description_3cebbb424528 := 'Extends each active meeting series'' occurrences up to the horizon: a slot with no meeting gets one, an untouched future meeting takes the series'' current values, and a series whose rule has run out is marked Ended. Optional Configuration: { "HorizonDays": <number> }, default 90.';
  p_DriverClass_3cebbb424528 := 'ScheduledJobMeetingSeriesMaterialization';
  p_NotificationsAvailable_3cebbb424528 := TRUE;
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ScheduledJobType"
                 WHERE "ID" = p_ID_3cebbb424528
                    OR ("Name" = p_Name_3cebbb424528)
                    OR ("DriverClass" = p_DriverClass_3cebbb424528)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateScheduledJobType'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateScheduledJobType"(p_data := jsonb_build_object(
    'ID', p_ID_3cebbb424528,
    'Name', p_Name_3cebbb424528,
    'Description', p_Description_3cebbb424528,
    'DriverClass', p_DriverClass_3cebbb424528,
    'DomainRunEntity', p_DomainRunEntity_3cebbb424528,
    'DomainRunEntityFKey', p_DomainRunEntityFKey_3cebbb424528,
    'NotificationsAvailable', p_NotificationsAvailable_3cebbb424528
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateScheduledJobType"(p_ID := p_ID_3cebbb424528, p_Name := p_Name_3cebbb424528, p_Description := p_Description_3cebbb424528, p_DriverClass := p_DriverClass_3cebbb424528, p_DomainRunEntity := p_DomainRunEntity_3cebbb424528, p_DomainRunEntity_Clear := TRUE, p_DomainRunEntityFKey := p_DomainRunEntityFKey_3cebbb424528, p_DomainRunEntityFKey_Clear := TRUE, p_NotificationsAvailable := p_NotificationsAvailable_3cebbb424528);
    END IF;
  END IF;
END $mj$;

-- Save MJ: Scheduled Jobs (core SP call only)
DO $mj$
DECLARE
  p_ID_732cecb56138 UUID;
  p_JobTypeID_732cecb56138 UUID;
  p_Name_732cecb56138 VARCHAR(200);
  p_Description_732cecb56138 TEXT;
  p_CronExpression_732cecb56138 VARCHAR(120);
  p_Timezone_732cecb56138 VARCHAR(64);
  p_StartAt_732cecb56138 TIMESTAMPTZ;
  p_EndAt_732cecb56138 TIMESTAMPTZ;
  p_Status_732cecb56138 VARCHAR(20);
  p_Configuration_732cecb56138 TEXT;
  p_OwnerUserID_732cecb56138 UUID;
  p_LastRunAt_732cecb56138 TIMESTAMPTZ;
  p_NextRunAt_732cecb56138 TIMESTAMPTZ;
  p_RunCount_732cecb56138 INTEGER;
  p_SuccessCount_732cecb56138 INTEGER;
  p_FailureCount_732cecb56138 INTEGER;
  p_NotifyOnSuccess_732cecb56138 BOOLEAN;
  p_NotifyOnFailure_732cecb56138 BOOLEAN;
  p_NotifyUserID_732cecb56138 UUID;
  p_NotifyViaEmail_732cecb56138 BOOLEAN;
  p_NotifyViaInApp_732cecb56138 BOOLEAN;
  p_LockToken_732cecb56138 UUID;
  p_LockedAt_732cecb56138 TIMESTAMPTZ;
  p_LockedByInstance_732cecb56138 VARCHAR(255);
  p_ExpectedCompletionAt_732cecb56138 TIMESTAMPTZ;
  p_ConcurrencyMode_732cecb56138 VARCHAR(20);
  p_RunImmediatelyIfNeverRun_732cecb56138 BOOLEAN;
  p_MaxRuntimeMinutes_732cecb56138 INTEGER;
  p_MissedRunPolicy_732cecb56138 VARCHAR(20);
BEGIN
  p_ID_732cecb56138 := '61EC03B3-7F04-486B-9646-1DD9583DE8AC';
  p_JobTypeID_732cecb56138 := (
    SELECT
      "ID"
    FROM
      "${mjSchema}"."ScheduledJobType"
    WHERE
      LOWER("DriverClass") = LOWER('ScheduledJobMeetingSeriesMaterialization')
  );
  p_Name_732cecb56138 := 'Tasks — Meeting Series (daily)';
  p_Description_732cecb56138 := 'Extends every active meeting series'' occurrences up to 90 days ahead, through the Meeting Series Materialization job type.';
  p_CronExpression_732cecb56138 := '0 0 3 * * *';
  p_Timezone_732cecb56138 := 'UTC';
  p_Status_732cecb56138 := 'Active';
  p_Configuration_732cecb56138 := '{
  "HorizonDays": 90
}';
  p_RunCount_732cecb56138 := 0;
  p_SuccessCount_732cecb56138 := 0;
  p_FailureCount_732cecb56138 := 0;
  p_NotifyOnSuccess_732cecb56138 := FALSE;
  p_NotifyOnFailure_732cecb56138 := FALSE;
  p_NotifyViaEmail_732cecb56138 := FALSE;
  p_NotifyViaInApp_732cecb56138 := FALSE;
  p_ConcurrencyMode_732cecb56138 := 'Skip';
  p_RunImmediatelyIfNeverRun_732cecb56138 := FALSE;
  p_MaxRuntimeMinutes_732cecb56138 := 30;
  p_MissedRunPolicy_732cecb56138 := 'RunOnce';
  IF NOT EXISTS (SELECT 1 FROM "${mjSchema}"."ScheduledJob"
                 WHERE "ID" = p_ID_732cecb56138
                    OR ("Name" = p_Name_732cecb56138)) THEN
    IF EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = '${mjSchema}' AND p.proname = 'spCreateScheduledJob'
         AND p.pronargs = 1 AND p.proargtypes[0] = 'jsonb'::regtype
    ) THEN
      PERFORM "${mjSchema}"."spCreateScheduledJob"(p_data := jsonb_build_object(
    'ID', p_ID_732cecb56138,
    'JobTypeID', p_JobTypeID_732cecb56138,
    'Name', p_Name_732cecb56138,
    'Description', p_Description_732cecb56138,
    'CronExpression', p_CronExpression_732cecb56138,
    'Timezone', p_Timezone_732cecb56138,
    'StartAt', p_StartAt_732cecb56138,
    'EndAt', p_EndAt_732cecb56138,
    'Status', p_Status_732cecb56138,
    'Configuration', p_Configuration_732cecb56138,
    'OwnerUserID', p_OwnerUserID_732cecb56138,
    'LastRunAt', p_LastRunAt_732cecb56138,
    'NextRunAt', p_NextRunAt_732cecb56138,
    'RunCount', p_RunCount_732cecb56138,
    'SuccessCount', p_SuccessCount_732cecb56138,
    'FailureCount', p_FailureCount_732cecb56138,
    'NotifyOnSuccess', p_NotifyOnSuccess_732cecb56138,
    'NotifyOnFailure', p_NotifyOnFailure_732cecb56138,
    'NotifyUserID', p_NotifyUserID_732cecb56138,
    'NotifyViaEmail', p_NotifyViaEmail_732cecb56138,
    'NotifyViaInApp', p_NotifyViaInApp_732cecb56138,
    'LockToken', p_LockToken_732cecb56138,
    'LockedAt', p_LockedAt_732cecb56138,
    'LockedByInstance', p_LockedByInstance_732cecb56138,
    'ExpectedCompletionAt', p_ExpectedCompletionAt_732cecb56138,
    'ConcurrencyMode', p_ConcurrencyMode_732cecb56138,
    'RunImmediatelyIfNeverRun', p_RunImmediatelyIfNeverRun_732cecb56138,
    'MaxRuntimeMinutes', p_MaxRuntimeMinutes_732cecb56138,
    'MissedRunPolicy', p_MissedRunPolicy_732cecb56138
  ));
    ELSE
      PERFORM "${mjSchema}"."spCreateScheduledJob"(p_ID := p_ID_732cecb56138, p_JobTypeID := p_JobTypeID_732cecb56138, p_Name := p_Name_732cecb56138, p_Description := p_Description_732cecb56138, p_CronExpression := p_CronExpression_732cecb56138, p_Timezone := p_Timezone_732cecb56138, p_StartAt := p_StartAt_732cecb56138, p_StartAt_Clear := TRUE, p_EndAt := p_EndAt_732cecb56138, p_EndAt_Clear := TRUE, p_Status := p_Status_732cecb56138, p_Configuration := p_Configuration_732cecb56138, p_OwnerUserID := p_OwnerUserID_732cecb56138, p_OwnerUserID_Clear := TRUE, p_LastRunAt := p_LastRunAt_732cecb56138, p_LastRunAt_Clear := TRUE, p_NextRunAt := p_NextRunAt_732cecb56138, p_NextRunAt_Clear := TRUE, p_RunCount := p_RunCount_732cecb56138, p_SuccessCount := p_SuccessCount_732cecb56138, p_FailureCount := p_FailureCount_732cecb56138, p_NotifyOnSuccess := p_NotifyOnSuccess_732cecb56138, p_NotifyOnFailure := p_NotifyOnFailure_732cecb56138, p_NotifyUserID := p_NotifyUserID_732cecb56138, p_NotifyUserID_Clear := TRUE, p_NotifyViaEmail := p_NotifyViaEmail_732cecb56138, p_NotifyViaInApp := p_NotifyViaInApp_732cecb56138, p_LockToken := p_LockToken_732cecb56138, p_LockToken_Clear := TRUE, p_LockedAt := p_LockedAt_732cecb56138, p_LockedAt_Clear := TRUE, p_LockedByInstance := p_LockedByInstance_732cecb56138, p_LockedByInstance_Clear := TRUE, p_ExpectedCompletionAt := p_ExpectedCompletionAt_732cecb56138, p_ExpectedCompletionAt_Clear := TRUE, p_ConcurrencyMode := p_ConcurrencyMode_732cecb56138, p_RunImmediatelyIfNeverRun := p_RunImmediatelyIfNeverRun_732cecb56138, p_MaxRuntimeMinutes := p_MaxRuntimeMinutes_732cecb56138, p_MissedRunPolicy := p_MissedRunPolicy_732cecb56138);
    END IF;
  END IF;
END $mj$;
