-- =============================================================================
-- PostgreSQL counterpart of V202611201230__v1.15.x__SaveReturnMode_DatestampsOnly_StoredProcedures.sql
-- =============================================================================
-- Atomically enables SaveReturnMode = 'datestamps_only' and TrackRecordChanges = FALSE
-- on MJ_BizApps_Tasks: Task Activities and Task Notification Logs, and replaces their
-- spCreate*/spUpdate* PL/pgSQL functions (originally installed in B202604011500) with
-- native MJ 6.2.1 CodeGen datestamps_only functions returning
-- TABLE("ID" UUID, "__mj_CreatedAt" TIMESTAMPTZ, "__mj_UpdatedAt" TIMESTAMPTZ).
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE SCHEMA IF NOT EXISTS __mj_bizappstasks;
SET search_path TO __mj_bizappstasks, public;
SET standard_conforming_strings = on;

-- Atomically enable SaveReturnMode = datestamps_only and TrackRecordChanges = FALSE
-- to match metadata/entities/.save-return-datestamps-only.json.
UPDATE ${mjSchema}."Entity"
SET
    "TrackRecordChanges" = FALSE,
    "Configuration" = CASE
        WHEN NULLIF(BTRIM(COALESCE("Configuration", '')), '') IS NULL
            THEN '{
  "SaveReturnMode": "datestamps_only"
}'
        ELSE jsonb_pretty(jsonb_set("Configuration"::jsonb, '{SaveReturnMode}', '"datestamps_only"'::jsonb, TRUE))
    END
WHERE LOWER("SchemaName") = '__mj_bizappstasks'
  AND "BaseTable" IN ('TaskActivity', 'TaskNotificationLog');

-- =============================================================================
-- Native PostgreSQL CodeGen CRUD functions (SaveReturnMode = datestamps_only)
-- =============================================================================

------------------------------------------------------------
----- CREATE FUNCTION FOR TaskActivity
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spCreateTaskActivity'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION __mj_bizappstasks."spCreateTaskActivity"(
    p_id UUID DEFAULT NULL::uuid,
    p_taskid UUID DEFAULT NULL::uuid,
    p_personid_clear BOOLEAN DEFAULT FALSE,
    p_personid UUID DEFAULT NULL::uuid,
    p_activitytype VARCHAR DEFAULT NULL::character varying,
    p_previousvalue_clear BOOLEAN DEFAULT FALSE,
    p_previousvalue VARCHAR DEFAULT NULL::character varying,
    p_newvalue_clear BOOLEAN DEFAULT FALSE,
    p_newvalue VARCHAR DEFAULT NULL::character varying,
    p_description_clear BOOLEAN DEFAULT FALSE,
    p_description TEXT DEFAULT NULL::text
) RETURNS TABLE("ID" UUID, "__mj_CreatedAt" TIMESTAMPTZ, "__mj_UpdatedAt" TIMESTAMPTZ) AS $$
#variable_conflict use_column
DECLARE
    v_new_id UUID;
BEGIN
    v_new_id := COALESCE(p_id, gen_random_uuid());
    INSERT INTO __mj_bizappstasks."TaskActivity"
        (
            "ID",
            "TaskID",
            "PersonID",
            "ActivityType",
            "PreviousValue",
            "NewValue",
            "Description"
        )
    VALUES
        (
            v_new_id,
            p_taskid,
            CASE WHEN p_personid_clear = TRUE THEN NULL ELSE COALESCE(p_personid, NULL) END,
            p_activitytype,
            CASE WHEN p_previousvalue_clear = TRUE THEN NULL ELSE COALESCE(p_previousvalue, NULL) END,
            CASE WHEN p_newvalue_clear = TRUE THEN NULL ELSE COALESCE(p_newvalue, NULL) END,
            CASE WHEN p_description_clear = TRUE THEN NULL ELSE COALESCE(p_description, NULL) END
        );

    RETURN QUERY
    SELECT "ID", "__mj_CreatedAt", "__mj_UpdatedAt" FROM __mj_bizappstasks."TaskActivity"
    WHERE "ID" = v_new_id;
END;
$$ LANGUAGE plpgsql;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spCreateTaskActivity" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;

------------------------------------------------------------
----- UPDATE FUNCTION FOR TaskActivity
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spUpdateTaskActivity'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION __mj_bizappstasks."spUpdateTaskActivity"(
    p_id UUID,
    p_taskid UUID DEFAULT NULL::uuid,
    p_personid_clear BOOLEAN DEFAULT FALSE,
    p_personid UUID DEFAULT NULL::uuid,
    p_activitytype VARCHAR DEFAULT NULL::character varying,
    p_previousvalue_clear BOOLEAN DEFAULT FALSE,
    p_previousvalue VARCHAR DEFAULT NULL::character varying,
    p_newvalue_clear BOOLEAN DEFAULT FALSE,
    p_newvalue VARCHAR DEFAULT NULL::character varying,
    p_description_clear BOOLEAN DEFAULT FALSE,
    p_description TEXT DEFAULT NULL::text
) RETURNS TABLE("ID" UUID, "__mj_CreatedAt" TIMESTAMPTZ, "__mj_UpdatedAt" TIMESTAMPTZ) AS $$
#variable_conflict use_column
DECLARE
    v_updated_count INTEGER;
BEGIN
    UPDATE __mj_bizappstasks."TaskActivity"
    SET
        "TaskID" = COALESCE(p_taskid, "TaskID"),
        "PersonID" = CASE WHEN p_personid_clear = TRUE THEN NULL ELSE COALESCE(p_personid, "PersonID") END,
        "ActivityType" = COALESCE(p_activitytype, "ActivityType"),
        "PreviousValue" = CASE WHEN p_previousvalue_clear = TRUE THEN NULL ELSE COALESCE(p_previousvalue, "PreviousValue") END,
        "NewValue" = CASE WHEN p_newvalue_clear = TRUE THEN NULL ELSE COALESCE(p_newvalue, "NewValue") END,
        "Description" = CASE WHEN p_description_clear = TRUE THEN NULL ELSE COALESCE(p_description, "Description") END
    WHERE
        "ID" = p_id;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    IF v_updated_count = 0 THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT "ID", "__mj_CreatedAt", "__mj_UpdatedAt" FROM __mj_bizappstasks."TaskActivity"
    WHERE "ID" = p_id;
END;
$$ LANGUAGE plpgsql;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spUpdateTaskActivity" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;

------------------------------------------------------------
----- CREATE FUNCTION FOR TaskNotificationLog
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spCreateTaskNotificationLog'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION __mj_bizappstasks."spCreateTaskNotificationLog"(
    p_id UUID DEFAULT NULL::uuid,
    p_taskid UUID DEFAULT NULL::uuid,
    p_notificationtype VARCHAR DEFAULT NULL::character varying,
    p_notifieduserid UUID DEFAULT NULL::uuid,
    p_notifiedat TIMESTAMPTZ DEFAULT NULL::timestamp with time zone
) RETURNS TABLE("ID" UUID, "__mj_CreatedAt" TIMESTAMPTZ, "__mj_UpdatedAt" TIMESTAMPTZ) AS $$
#variable_conflict use_column
DECLARE
    v_new_id UUID;
BEGIN
    v_new_id := COALESCE(p_id, gen_random_uuid());
    INSERT INTO __mj_bizappstasks."TaskNotificationLog"
        (
            "ID",
            "TaskID",
            "NotificationType",
            "NotifiedUserID",
            "NotifiedAt"
        )
    VALUES
        (
            v_new_id,
            p_taskid,
            p_notificationtype,
            p_notifieduserid,
            COALESCE(p_notifiedat, NOW())
        );

    RETURN QUERY
    SELECT "ID", "__mj_CreatedAt", "__mj_UpdatedAt" FROM __mj_bizappstasks."TaskNotificationLog"
    WHERE "ID" = v_new_id;
END;
$$ LANGUAGE plpgsql;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spCreateTaskNotificationLog" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;

------------------------------------------------------------
----- UPDATE FUNCTION FOR TaskNotificationLog
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spUpdateTaskNotificationLog'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION __mj_bizappstasks."spUpdateTaskNotificationLog"(
    p_id UUID,
    p_taskid UUID DEFAULT NULL::uuid,
    p_notificationtype VARCHAR DEFAULT NULL::character varying,
    p_notifieduserid UUID DEFAULT NULL::uuid,
    p_notifiedat TIMESTAMPTZ DEFAULT NULL::timestamp with time zone
) RETURNS TABLE("ID" UUID, "__mj_CreatedAt" TIMESTAMPTZ, "__mj_UpdatedAt" TIMESTAMPTZ) AS $$
#variable_conflict use_column
DECLARE
    v_updated_count INTEGER;
BEGIN
    UPDATE __mj_bizappstasks."TaskNotificationLog"
    SET
        "TaskID" = COALESCE(p_taskid, "TaskID"),
        "NotificationType" = COALESCE(p_notificationtype, "NotificationType"),
        "NotifiedUserID" = COALESCE(p_notifieduserid, "NotifiedUserID"),
        "NotifiedAt" = COALESCE(p_notifiedat, "NotifiedAt")
    WHERE
        "ID" = p_id;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    IF v_updated_count = 0 THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT "ID", "__mj_CreatedAt", "__mj_UpdatedAt" FROM __mj_bizappstasks."TaskNotificationLog"
    WHERE "ID" = p_id;
END;
$$ LANGUAGE plpgsql;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spUpdateTaskNotificationLog" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
