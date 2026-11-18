-- ============================================================================
-- PostgreSQL counterpart of migrations/V202610051530__v1.7.x_TaskType_IsApproval.sql
-- The IsApproval column is written by hand from the T-SQL. Metadata DML is converted from the
-- T-SQL; the CodeGen sections are native PostgreSQL CodeGen (MJ 6.1.5), not translated T-SQL.
-- ============================================================================

SET search_path TO __mj_bizappstasks, public;
SET standard_conforming_strings = on;

-- BizAppsTasks: TaskType.IsApproval
-- Marks the task types whose tasks are approvals, so the approvals inbox lists every such type
-- rather than only the seeded Approval Request type. An app that routes approvals through its own
-- task type sets the flag on that type in its metadata.

ALTER TABLE __mj_bizappstasks."TaskType"
 ADD COLUMN "IsApproval" BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN __mj_bizappstasks."TaskType"."IsApproval" IS 'When true, tasks of this type are approvals: they appear in the approvals inbox of each assignee, who records a decision on them.';



















































DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '0aa2aa72-7ced-4302-86ce-41a1c06b810b' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'IsApproval')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('0aa2aa72-7ced-4302-86ce-41a1c06b810b', '1E30141A-826F-4278-BAA9-BBE14D29E606' /* Entity: MJ_BizApps_Tasks: Task Types */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606'), 'IsApproval', 'Is Approval', 'When true, tasks of this type are approvals: they appear in the approvals inbox of each assignee, who records a decision on them.', 'bit', 1, 1, 0, FALSE, '(0)', FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

-- ===================== CodeGen (native PG, baked) =====================

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Types
-- Item: Index for Foreign Keys
-- ============================================================
CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_type_on_assign_action_id"
    ON "__mj_bizappstasks"."TaskType" ("OnAssignActionID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_type_on_complete_action_id"
    ON "__mj_bizappstasks"."TaskType" ("OnCompleteActionID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_type_on_overdue_action_id"
    ON "__mj_bizappstasks"."TaskType" ("OnOverdueActionID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_type_on_percent_change_action_id"
    ON "__mj_bizappstasks"."TaskType" ("OnPercentChangeActionID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_type_on_reject_action_id"
    ON "__mj_bizappstasks"."TaskType" ("OnRejectActionID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_type_on_cancel_action_id"
    ON "__mj_bizappstasks"."TaskType" ("OnCancelActionID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_type_on_create_action_id"
    ON "__mj_bizappstasks"."TaskType" ("OnCreateActionID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_type_on_status_change_action_id"
    ON "__mj_bizappstasks"."TaskType" ("OnStatusChangeActionID");

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Types
-- Item: vwTaskTypes
-- ============================================================

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Types
-----               SCHEMA:      __mj_bizappstasks
-----               BASE TABLE:  TaskType
-----               PRIMARY KEY: ID
------------------------------------------------------------
DO $vw_regen$
DECLARE
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_bizappstasks"."vwTaskTypes"
AS
SELECT
    t.*,
    MJAction_OnAssignActionID."Name" AS "OnAssignAction",
    MJAction_OnCompleteActionID."Name" AS "OnCompleteAction",
    MJAction_OnOverdueActionID."Name" AS "OnOverdueAction",
    MJAction_OnPercentChangeActionID."Name" AS "OnPercentChangeAction",
    MJAction_OnRejectActionID."Name" AS "OnRejectAction",
    MJAction_OnCancelActionID."Name" AS "OnCancelAction",
    MJAction_OnCreateActionID."Name" AS "OnCreateAction",
    MJAction_OnStatusChangeActionID."Name" AS "OnStatusChangeAction"
FROM
    "__mj_bizappstasks"."TaskType" AS t
LEFT OUTER JOIN
    ${mjSchema}."Action" AS MJAction_OnAssignActionID
  ON
    "t"."OnAssignActionID" = MJAction_OnAssignActionID."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS MJAction_OnCompleteActionID
  ON
    "t"."OnCompleteActionID" = MJAction_OnCompleteActionID."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS MJAction_OnOverdueActionID
  ON
    "t"."OnOverdueActionID" = MJAction_OnOverdueActionID."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS MJAction_OnPercentChangeActionID
  ON
    "t"."OnPercentChangeActionID" = MJAction_OnPercentChangeActionID."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS MJAction_OnRejectActionID
  ON
    "t"."OnRejectActionID" = MJAction_OnRejectActionID."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS MJAction_OnCancelActionID
  ON
    "t"."OnCancelActionID" = MJAction_OnCancelActionID."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS MJAction_OnCreateActionID
  ON
    "t"."OnCreateActionID" = MJAction_OnCreateActionID."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS MJAction_OnStatusChangeActionID
  ON
    "t"."OnStatusChangeActionID" = MJAction_OnStatusChangeActionID."ID"
$vsql$;
  rec RECORD;
BEGIN
  EXECUTE vsql;
EXCEPTION WHEN invalid_table_definition THEN
  -- 42P16: column rename/reorder/type change. CREATE OR REPLACE can't handle
  -- non-additive shape changes — must DROP CASCADE + recreate. CASCADE drops
  -- every dependent view (anything that JOINs this view in its body), so we
  -- capture each dependent's definition + grants BEFORE the drop and replay
  -- them afterward (best-effort). Without this, on a fresh-DB replay where
  -- one entity's wrapper triggers (e.g. vwAIModelTypes shape changed since
  -- baseline V202605021056), CASCADE wipes downstream views (vwAIModels)
  -- that the wrapper for this entity doesn't know how to recreate, and
  -- those views stay permanently missing.
  CREATE TEMP TABLE IF NOT EXISTS _vw_regen_deps (
    schema_name TEXT,
    view_name   TEXT,
    relkind     CHAR(1),
    definition  TEXT,
    grants_sql  TEXT
  ) ON COMMIT DROP;
  DELETE FROM _vw_regen_deps;

  -- Capture dependent FUNCTIONS too. CASCADE drops every function with
  -- RETURNS SETOF <view> (the codegen-emitted spCreate/spUpdate/spDelete
  -- pattern) when the target view is dropped. Without restoring them,
  -- post-codegen CRUD validation reports those routines as missing —
  -- e.g. "MJ: Recommendation Items → missing create routine
  -- spCreateRecommendationItem" — even though the next codegen pass
  -- emits them. The restored definitions are pg_get_functiondef() output
  -- which is a complete CREATE OR REPLACE FUNCTION statement plus a
  -- trailing semicolon; replaying them verbatim recreates the function
  -- with its original body, parameter list, and return type.
  CREATE TEMP TABLE IF NOT EXISTS _vw_regen_fn_deps (
    schema_name TEXT,
    fn_name     TEXT,
    fn_oid      OID,
    definition  TEXT
  ) ON COMMIT DROP;
  DELETE FROM _vw_regen_fn_deps;

  -- Capture dependents. NOTES on the grants_sql build:
  --   - Resolve role name via pg_get_userbyid(oid) — returns the bare,
  --     unquoted role name (or 'unknown (OID=N)' if the oid no longer
  --     exists). pg_get_userbyid is a public catalog function available to
  --     every database user, including unprivileged accounts on managed
  --     PostgreSQL services (Amazon RDS, Azure Database for PostgreSQL,
  --     Cloud SQL) where pg_authid is restricted to the rds_superuser /
  --     azure_pg_admin / cloudsqlsuperuser group. Earlier revisions joined
  --     to pg_authid which works on self-hosted PG but fails with
  --     "permission denied for table pg_authid" on managed services.
  --   - The earlier (broken) approach cast (aclexplode).grantee::regrole::text
  --     which RETURNS the role name pre-quoted when it contains uppercase
  --     (e.g. cdp_Developer comes back already wrapped); calling quote_ident
  --     on the already-quoted string double-wrapped and the GRANT failed at
  --     replay with "role does not exist". Using
  --     pg_get_userbyid returns a bare name and lets quote_ident wrap it
  --     correctly exactly once.
  --   - PUBLIC is grantee oid 0; pg_get_userbyid(0) returns 'unknown
  --     (OID=0)' so handle the PUBLIC case explicitly and use it as the
  --     literal 'PUBLIC' rather than quote_ident on the synthetic name.
  INSERT INTO _vw_regen_deps (schema_name, view_name, relkind, definition, grants_sql)
  SELECT DISTINCT
      dn.nspname,
      dc.relname,
      dc.relkind,
      pg_get_viewdef(dc.oid),
      (SELECT string_agg(
          'GRANT ' || g.privilege || ' ON ' || quote_ident(dn.nspname) || '.' || quote_ident(dc.relname) ||
          ' TO ' || (CASE WHEN g.grantee_oid = 0 THEN 'PUBLIC' ELSE quote_ident(pg_get_userbyid(g.grantee_oid)) END) || ';',
          E'
')
       FROM (
           SELECT (aclexplode(dc.relacl)).grantee AS grantee_oid,
                  (aclexplode(dc.relacl)).privilege_type AS privilege
       ) g
       WHERE g.privilege IN ('SELECT', 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES', 'TRIGGER'))
  FROM pg_depend d
  JOIN pg_rewrite r ON r.oid = d.objid AND d.classid = 'pg_rewrite'::regclass
  JOIN pg_class dc ON dc.oid = r.ev_class AND dc.relkind IN ('v', 'm')
  JOIN pg_namespace dn ON dn.oid = dc.relnamespace
  JOIN pg_class tc ON tc.oid = d.refobjid
  JOIN pg_namespace tn ON tn.oid = tc.relnamespace
  WHERE tn.nspname = '__mj_bizappstasks'
    AND tc.relname = 'vwTaskTypes'
    AND tc.relkind IN ('v', 'm')
    AND dc.oid <> tc.oid;

  -- Capture dependent functions. Two paths matter on PG:
  --   1. Functions whose RETURN type references the view (RETURNS SETOF
  --      <view>) — pg_depend records this as type=pg_type → pg_class.
  --   2. Functions whose body references the view (used by sql functions
  --      and by some plpgsql edge cases) — pg_depend records this as
  --      pg_proc → pg_class.
  -- pg_get_functiondef returns a complete CREATE OR REPLACE FUNCTION
  -- statement that we replay verbatim. We DO include RETURNS-only
  -- references because that's the dominant codegen pattern (sp* CRUD
  -- functions all RETURNS SETOF the matching vwX).
  INSERT INTO _vw_regen_fn_deps (schema_name, fn_name, fn_oid, definition)
  SELECT DISTINCT
      pn.nspname,
      pp.proname,
      pp.oid,
      pg_get_functiondef(pp.oid)
  FROM pg_depend d
  JOIN pg_proc pp ON pp.oid = d.objid AND d.classid = 'pg_proc'::regclass
  JOIN pg_namespace pn ON pn.oid = pp.pronamespace
  JOIN pg_class tc ON tc.oid = d.refobjid
  JOIN pg_namespace tn ON tn.oid = tc.relnamespace
  WHERE tn.nspname = '__mj_bizappstasks'
    AND tc.relname = 'vwTaskTypes'
    AND tc.relkind IN ('v', 'm')
  UNION
  SELECT DISTINCT
      pn.nspname,
      pp.proname,
      pp.oid,
      pg_get_functiondef(pp.oid)
  FROM pg_depend d
  JOIN pg_type pt ON pt.oid = d.refobjid AND d.refclassid = 'pg_type'::regclass
  JOIN pg_proc pp ON pp.prorettype = pt.oid OR pt.typrelid = pp.oid
  JOIN pg_namespace pn ON pn.oid = pp.pronamespace
  WHERE EXISTS (
      SELECT 1 FROM pg_class tc
      JOIN pg_namespace tn ON tn.oid = tc.relnamespace
      WHERE tc.reltype = pt.oid
        AND tn.nspname = '__mj_bizappstasks'
        AND tc.relname = 'vwTaskTypes'
        AND tc.relkind IN ('v', 'm')
  );

  DROP VIEW IF EXISTS "__mj_bizappstasks"."vwTaskTypes" CASCADE;
  EXECUTE vsql;

  -- Replay captured dependents. Best-effort: log + continue on failure.
  -- IMPORTANT: the CREATE VIEW and the GRANTs run in SEPARATE inner BEGIN
  -- blocks. PL/pgSQL's BEGIN ... EXCEPTION creates an implicit savepoint
  -- and rolls back EVERY statement in the block on any exception. If we
  -- combined CREATE+GRANT in one block and a GRANT failed (e.g. role not
  -- present in target environment), the just-recreated VIEW would also
  -- get rolled back and stay missing — the exact failure mode this
  -- wrapper exists to prevent.
  FOR rec IN SELECT schema_name, view_name, relkind, definition, grants_sql FROM _vw_regen_deps LOOP
    BEGIN
      IF rec.relkind = 'm' THEN
        EXECUTE 'CREATE MATERIALIZED VIEW ' || quote_ident(rec.schema_name) || '.' || quote_ident(rec.view_name) || ' AS ' || rec.definition;
      ELSE
        EXECUTE 'CREATE VIEW ' || quote_ident(rec.schema_name) || '.' || quote_ident(rec.view_name) || ' AS ' || rec.definition;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Best-effort restore skipped dependent %.%: %', rec.schema_name, rec.view_name, SQLERRM;
    END;

    IF rec.grants_sql IS NOT NULL THEN
      BEGIN
        EXECUTE rec.grants_sql;
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Best-effort grant restore skipped %.%: %', rec.schema_name, rec.view_name, SQLERRM;
      END;
    END IF;
  END LOOP;

  -- Replay captured dependent functions AFTER all dependent views are
  -- restored — most codegen-emitted sp* functions reference both the
  -- target view AND the dependent views in their bodies/return types.
  -- Wrapped per-function in its own savepoint so a single failure
  -- doesn't poison subsequent restores or the just-recreated target.
  FOR rec IN SELECT schema_name, fn_name, definition FROM _vw_regen_fn_deps LOOP
    BEGIN
      EXECUTE rec.definition;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Best-effort restore skipped dependent function %.%: %', rec.schema_name, rec.fn_name, SQLERRM;
    END;
  END LOOP;

  DROP TABLE _vw_regen_deps;
  DROP TABLE _vw_regen_fn_deps;
END $vw_regen$;
GRANT SELECT ON "__mj_bizappstasks"."vwTaskTypes" TO "cdp_UI";
GRANT SELECT ON "__mj_bizappstasks"."vwTaskTypes" TO "cdp_Developer";
GRANT SELECT ON "__mj_bizappstasks"."vwTaskTypes" TO "cdp_Integration";

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Types
-- Item: spCreateTaskType
-- ============================================================

------------------------------------------------------------
----- CREATE FUNCTION FOR TaskType
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spCreateTaskType'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spCreateTaskType"(
    p_id UUID DEFAULT NULL,
    p_name varchar(100) DEFAULT NULL,
    p_description_clear boolean DEFAULT false,
    p_description TEXT DEFAULT NULL,
    p_iconclass_clear boolean DEFAULT false,
    p_iconclass varchar(100) DEFAULT NULL,
    p_defaultpriority varchar(20) DEFAULT NULL,
    p_onassignactionid_clear boolean DEFAULT false,
    p_onassignactionid UUID DEFAULT NULL,
    p_oncompleteactionid_clear boolean DEFAULT false,
    p_oncompleteactionid UUID DEFAULT NULL,
    p_onoverdueactionid_clear boolean DEFAULT false,
    p_onoverdueactionid UUID DEFAULT NULL,
    p_onpercentchangeactionid_clear boolean DEFAULT false,
    p_onpercentchangeactionid UUID DEFAULT NULL,
    p_isactive BOOLEAN DEFAULT NULL,
    p_onrejectactionid_clear boolean DEFAULT false,
    p_onrejectactionid UUID DEFAULT NULL,
    p_oncancelactionid_clear boolean DEFAULT false,
    p_oncancelactionid UUID DEFAULT NULL,
    p_code varchar(50) DEFAULT NULL,
    p_oncreateactionid_clear boolean DEFAULT false,
    p_oncreateactionid UUID DEFAULT NULL,
    p_onstatuschangeactionid_clear boolean DEFAULT false,
    p_onstatuschangeactionid UUID DEFAULT NULL,
    p_isapproval BOOLEAN DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwTaskTypes" AS $$
DECLARE
    v_new_id UUID;
BEGIN
    v_new_id := COALESCE(p_id, gen_random_uuid());
    INSERT INTO "__mj_bizappstasks"."TaskType"
        (
            "ID",
            "Name",
                "Description",
                "IconClass",
                "DefaultPriority",
                "OnAssignActionID",
                "OnCompleteActionID",
                "OnOverdueActionID",
                "OnPercentChangeActionID",
                "IsActive",
                "OnRejectActionID",
                "OnCancelActionID",
                "Code",
                "OnCreateActionID",
                "OnStatusChangeActionID",
                "IsApproval"
        )
    VALUES
        (
            v_new_id,
            p_name,
                CASE WHEN p_description_clear = true THEN NULL ELSE COALESCE(p_description, NULL) END,
                CASE WHEN p_iconclass_clear = true THEN NULL ELSE COALESCE(p_iconclass, NULL) END,
                COALESCE(p_defaultpriority, 'Medium'),
                CASE WHEN p_onassignactionid_clear = true THEN NULL ELSE COALESCE(p_onassignactionid, NULL) END,
                CASE WHEN p_oncompleteactionid_clear = true THEN NULL ELSE COALESCE(p_oncompleteactionid, NULL) END,
                CASE WHEN p_onoverdueactionid_clear = true THEN NULL ELSE COALESCE(p_onoverdueactionid, NULL) END,
                CASE WHEN p_onpercentchangeactionid_clear = true THEN NULL ELSE COALESCE(p_onpercentchangeactionid, NULL) END,
                COALESCE(p_isactive, TRUE),
                CASE WHEN p_onrejectactionid_clear = true THEN NULL ELSE COALESCE(p_onrejectactionid, NULL) END,
                CASE WHEN p_oncancelactionid_clear = true THEN NULL ELSE COALESCE(p_oncancelactionid, NULL) END,
                p_code,
                CASE WHEN p_oncreateactionid_clear = true THEN NULL ELSE COALESCE(p_oncreateactionid, NULL) END,
                CASE WHEN p_onstatuschangeactionid_clear = true THEN NULL ELSE COALESCE(p_onstatuschangeactionid, NULL) END,
                COALESCE(p_isapproval, FALSE)
        )
    ;

    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwTaskTypes"
    WHERE "ID" = v_new_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTaskType" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTaskType" TO "cdp_Integration";


-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Types
-- Item: spUpdateTaskType
-- ============================================================

------------------------------------------------------------
----- UPDATE FUNCTION FOR TaskType
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spUpdateTaskType'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spUpdateTaskType"(
    p_id UUID,
    p_name varchar(100) DEFAULT NULL,
    p_description_clear boolean DEFAULT false,
    p_description TEXT DEFAULT NULL,
    p_iconclass_clear boolean DEFAULT false,
    p_iconclass varchar(100) DEFAULT NULL,
    p_defaultpriority varchar(20) DEFAULT NULL,
    p_onassignactionid_clear boolean DEFAULT false,
    p_onassignactionid UUID DEFAULT NULL,
    p_oncompleteactionid_clear boolean DEFAULT false,
    p_oncompleteactionid UUID DEFAULT NULL,
    p_onoverdueactionid_clear boolean DEFAULT false,
    p_onoverdueactionid UUID DEFAULT NULL,
    p_onpercentchangeactionid_clear boolean DEFAULT false,
    p_onpercentchangeactionid UUID DEFAULT NULL,
    p_isactive BOOLEAN DEFAULT NULL,
    p_onrejectactionid_clear boolean DEFAULT false,
    p_onrejectactionid UUID DEFAULT NULL,
    p_oncancelactionid_clear boolean DEFAULT false,
    p_oncancelactionid UUID DEFAULT NULL,
    p_code varchar(50) DEFAULT NULL,
    p_oncreateactionid_clear boolean DEFAULT false,
    p_oncreateactionid UUID DEFAULT NULL,
    p_onstatuschangeactionid_clear boolean DEFAULT false,
    p_onstatuschangeactionid UUID DEFAULT NULL,
    p_isapproval BOOLEAN DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwTaskTypes" AS $$
DECLARE
    v_updated_count INTEGER;
BEGIN
    UPDATE "__mj_bizappstasks"."TaskType"
    SET
        "Name" = COALESCE(p_name, "Name"),
        "Description" = CASE WHEN p_description_clear = true THEN NULL ELSE COALESCE(p_description, "Description") END,
        "IconClass" = CASE WHEN p_iconclass_clear = true THEN NULL ELSE COALESCE(p_iconclass, "IconClass") END,
        "DefaultPriority" = COALESCE(p_defaultpriority, "DefaultPriority"),
        "OnAssignActionID" = CASE WHEN p_onassignactionid_clear = true THEN NULL ELSE COALESCE(p_onassignactionid, "OnAssignActionID") END,
        "OnCompleteActionID" = CASE WHEN p_oncompleteactionid_clear = true THEN NULL ELSE COALESCE(p_oncompleteactionid, "OnCompleteActionID") END,
        "OnOverdueActionID" = CASE WHEN p_onoverdueactionid_clear = true THEN NULL ELSE COALESCE(p_onoverdueactionid, "OnOverdueActionID") END,
        "OnPercentChangeActionID" = CASE WHEN p_onpercentchangeactionid_clear = true THEN NULL ELSE COALESCE(p_onpercentchangeactionid, "OnPercentChangeActionID") END,
        "IsActive" = COALESCE(p_isactive, "IsActive"),
        "OnRejectActionID" = CASE WHEN p_onrejectactionid_clear = true THEN NULL ELSE COALESCE(p_onrejectactionid, "OnRejectActionID") END,
        "OnCancelActionID" = CASE WHEN p_oncancelactionid_clear = true THEN NULL ELSE COALESCE(p_oncancelactionid, "OnCancelActionID") END,
        "Code" = COALESCE(p_code, "Code"),
        "OnCreateActionID" = CASE WHEN p_oncreateactionid_clear = true THEN NULL ELSE COALESCE(p_oncreateactionid, "OnCreateActionID") END,
        "OnStatusChangeActionID" = CASE WHEN p_onstatuschangeactionid_clear = true THEN NULL ELSE COALESCE(p_onstatuschangeactionid, "OnStatusChangeActionID") END,
        "IsApproval" = COALESCE(p_isapproval, "IsApproval")
    WHERE
        "ID" = p_id;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    IF v_updated_count = 0 THEN
        -- Nothing was updated, return empty result set
        RETURN;
    END IF;

    -- Return the updated record from the base view
    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwTaskTypes"
    WHERE "ID" = p_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateTaskType" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateTaskType" TO "cdp_Integration";


------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskType table
------------------------------------------------------------
CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."fn_trg_update_task_type"()
RETURNS TRIGGER AS $$
BEGIN
    NEW."__mj_UpdatedAt" := NOW() AT TIME ZONE 'UTC';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS "trg_update_task_type" ON "__mj_bizappstasks"."TaskType";

CREATE TRIGGER "trg_update_task_type"
BEFORE UPDATE ON "__mj_bizappstasks"."TaskType"
FOR EACH ROW
EXECUTE FUNCTION "__mj_bizappstasks"."fn_trg_update_task_type"();



-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Types
-- Item: spDeleteTaskType
-- ============================================================

------------------------------------------------------------
----- DELETE FUNCTION FOR TaskType
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spDeleteTaskType'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spDeleteTaskType"(
    p_id UUID
) RETURNS TABLE("ID" UUID) AS $$
#variable_conflict use_column
DECLARE
    v_affected_count INTEGER;
BEGIN

    DELETE FROM "__mj_bizappstasks"."TaskType"
    WHERE "ID" = p_id;

    GET DIAGNOSTICS v_affected_count = ROW_COUNT;

    IF v_affected_count = 0 THEN
        RETURN QUERY SELECT NULL::UUID AS "ID";
    ELSE
        RETURN QUERY SELECT p_id AS "ID";
    END IF;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteTaskType" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteTaskType" TO "cdp_Integration";
