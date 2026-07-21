-- ============================================================================
-- MemberJunction PostgreSQL Migration
-- Converted from SQL Server using TypeScript conversion pipeline
-- ============================================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Schema
CREATE SCHEMA IF NOT EXISTS __mj_bizappstasks;
SET search_path TO __mj_bizappstasks, public;

-- Ensure backslashes in string literals are treated literally (not as escape sequences)
SET standard_conforming_strings = on;

-- NOTE: Earlier converter versions made INTEGER to BOOLEAN cast implicit by
-- modifying the system catalog so SS-style INSERT INTO bool_col VALUES (1)
-- would work. That modification required pg_catalog write privileges, which
-- managed PG (RDS, Aurora, Cloud SQL, Azure) does not grant. As of v5.30 all
-- bulk INSERTs are emitted with native TRUE/FALSE values directly, so the
-- cast modification is no longer needed. Removed to support managed-PG
-- installs out of the box.


-- ===================== DDL: Tables, PKs, Indexes =====================

---------------------------------------------------------------------------
-- TaskDecisionOutcome: lookup of decision outcomes (Approved, Rejected, ...)
-- Seeded via metadata (metadata/task-decision-outcomes); extensible per
-- deployment without a migration.
---------------------------------------------------------------------------
CREATE TABLE __mj_bizappstasks."TaskDecisionOutcome" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "Name" VARCHAR(100) NOT NULL,
 "Code" VARCHAR(50) NOT NULL,
 "Description" TEXT,
 "Sequence" INTEGER NOT NULL DEFAULT 100,
 "IsTerminal" BOOLEAN NOT NULL DEFAULT TRUE,
 "IsActive" BOOLEAN NOT NULL DEFAULT TRUE,
 CONSTRAINT PK_TaskDecisionOutcome PRIMARY KEY ("ID"),
 CONSTRAINT UQ_TaskDecisionOutcome_Code UNIQUE ("Code"),
 CONSTRAINT UQ_TaskDecisionOutcome_Name UNIQUE ("Name")
);

---------------------------------------------------------------------------
-- TaskDecision: an approve/reject decision recorded against a task.
-- TaskAssignmentID is nullable to support per-assignee decisions for
-- multi-approver scenarios; null = a task-level decision.
---------------------------------------------------------------------------
CREATE TABLE __mj_bizappstasks."TaskDecision" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TaskID" UUID NOT NULL,
 "OutcomeID" UUID NOT NULL,
 "DecidedByPersonID" UUID,
 "DecidedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 "DecisionNotes" TEXT,
 "TaskAssignmentID" UUID,
 CONSTRAINT PK_TaskDecision PRIMARY KEY ("ID"),
 CONSTRAINT FK_TaskDecision_Task FOREIGN KEY ("TaskID") REFERENCES __mj_bizappstasks."Task"("ID"),
 CONSTRAINT FK_TaskDecision_Outcome FOREIGN KEY ("OutcomeID") REFERENCES __mj_bizappstasks."TaskDecisionOutcome"("ID"),
 CONSTRAINT FK_TaskDecision_DecidedByPerson FOREIGN KEY ("DecidedByPersonID") REFERENCES __mj_bizappscommon."Person"("ID"),
 CONSTRAINT FK_TaskDecision_TaskAssignment FOREIGN KEY ("TaskAssignmentID") REFERENCES __mj_bizappstasks."TaskAssignment"("ID")
);

---------------------------------------------------------------------------
-- TaskType: add reject/cancel action hooks (additive nullable columns).
---------------------------------------------------------------------------
ALTER TABLE __mj_bizappstasks."TaskType"
 ADD COLUMN IF NOT EXISTS "OnRejectActionID" UUID NULL,
 ADD COLUMN IF NOT EXISTS "OnCancelActionID" UUID NULL,
 ADD CONSTRAINT "FK_TaskType_OnRejectAction" FOREIGN KEY ("OnRejectActionID") REFERENCES ${mjSchema}."Action"("ID"),
 ADD CONSTRAINT "FK_TaskType_OnCancelAction" FOREIGN KEY ("OnCancelActionID") REFERENCES ${mjSchema}."Action"("ID");

---------------------------------------------------------------------------
-- TaskActivity: widen the ActivityType CHECK to include 'DecisionRecorded'.
-- Drop + re-add with a superset of allowed values (additive widening).
---------------------------------------------------------------------------
ALTER TABLE __mj_bizappstasks."TaskActivity" DROP CONSTRAINT "CK_TaskActivity_Type";

ALTER TABLE __mj_bizappstasks."TaskDecisionOutcome"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_bizappstasks."TaskDecisionOutcome" */
ALTER TABLE __mj_bizappstasks."TaskDecisionOutcome"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_bizappstasks."TaskDecision" */
ALTER TABLE __mj_bizappstasks."TaskDecision"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_bizappstasks."TaskDecision" */
ALTER TABLE __mj_bizappstasks."TaskDecision"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskDecision_TaskID" ON __mj_bizappstasks."TaskDecision" ("TaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskDecision_OutcomeID" ON __mj_bizappstasks."TaskDecision" ("OutcomeID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskDecision_DecidedByPersonID" ON __mj_bizappstasks."TaskDecision" ("DecidedByPersonID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskDecision_TaskAssignmentID" ON __mj_bizappstasks."TaskDecision" ("TaskAssignmentID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnAssignActionID" ON __mj_bizappstasks."TaskType" ("OnAssignActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnCompleteActionID" ON __mj_bizappstasks."TaskType" ("OnCompleteActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnOverdueActionID" ON __mj_bizappstasks."TaskType" ("OnOverdueActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnPercentChangeActionID" ON __mj_bizappstasks."TaskType" ("OnPercentChangeActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnRejectActionID" ON __mj_bizappstasks."TaskType" ("OnRejectActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnCancelActionID" ON __mj_bizappstasks."TaskType" ("OnCancelActionID");


-- ===================== Views =====================

DROP VIEW IF EXISTS __mj_bizappstasks."vwTaskDecisionOutcomes" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_bizappstasks';
  v_target_name CONSTANT TEXT := 'vwTaskDecisionOutcomes';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_bizappstasks."vwTaskDecisionOutcomes"
AS SELECT
    t.*
FROM
    __mj_bizappstasks."TaskDecisionOutcome" AS t$vsql$;
  v_target_oid OID;
  v_dep RECORD;
  v_captured JSONB[] := ARRAY[]::JSONB[];
  v_n INTEGER;
BEGIN
  EXECUTE vsql;
EXCEPTION WHEN invalid_table_definition THEN
  -- Column list changed; need CASCADE. Preserve dependent views first.
  SELECT c.oid INTO v_target_oid
  FROM pg_class c JOIN pg_namespace n ON c.relnamespace = n.oid
  WHERE n.nspname = v_target_schema AND c.relname = v_target_name AND c.relkind = 'v';
  IF v_target_oid IS NOT NULL THEN
    FOR v_dep IN
      WITH RECURSIVE deps AS (
        SELECT c.oid, c.relname AS name, n.nspname AS schema, 1 AS depth
        FROM pg_rewrite r
        JOIN pg_depend d ON d.objid = r.oid
        JOIN pg_class c ON c.oid = r.ev_class
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE d.refobjid = v_target_oid AND d.deptype = 'n'
          AND c.oid <> v_target_oid AND c.relkind = 'v'
        UNION
        SELECT c.oid, c.relname, n.nspname, p.depth + 1
        FROM deps p
        JOIN pg_rewrite r ON TRUE
        JOIN pg_depend d ON d.objid = r.oid AND d.refobjid = p.oid
        JOIN pg_class c ON c.oid = r.ev_class
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE c.relkind = 'v' AND c.oid <> p.oid
      )
      SELECT oid, name, schema, MAX(depth) AS max_depth,
             pg_catalog.pg_get_viewdef(oid, true) AS viewdef
      FROM deps GROUP BY oid, name, schema
      ORDER BY MAX(depth) ASC
    LOOP
      v_captured := v_captured || jsonb_build_object(
        'schema', v_dep.schema, 'name', v_dep.name, 'def', v_dep.viewdef);
    END LOOP;
  END IF;
  EXECUTE format('DROP VIEW IF EXISTS %I.%I CASCADE', v_target_schema, v_target_name);
  EXECUTE vsql;
  IF v_captured IS NOT NULL AND array_length(v_captured, 1) > 0 THEN
    FOR v_n IN 1..array_length(v_captured, 1) LOOP
      BEGIN
        EXECUTE format('CREATE VIEW %I.%I AS %s',
          v_captured[v_n]->>'schema', v_captured[v_n]->>'name', v_captured[v_n]->>'def');
      EXCEPTION WHEN others THEN
        RAISE WARNING 'Could not restore dependent view %.%: %',
          v_captured[v_n]->>'schema', v_captured[v_n]->>'name', SQLERRM;
      END;
    END LOOP;
  END IF;
END;
$do$;

DROP VIEW IF EXISTS __mj_bizappstasks."vwTaskDecisions" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_bizappstasks';
  v_target_name CONSTANT TEXT := 'vwTaskDecisions';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_bizappstasks."vwTaskDecisions"
AS SELECT t."ID",
    t."TaskID",
    t."OutcomeID",
    t."DecidedByPersonID",
    t."DecidedAt",
    t."DecisionNotes",
    t."TaskAssignmentID",
    t."__mj_CreatedAt",
    t."__mj_UpdatedAt",
    mjbizappstaskstask_taskid."Name" AS "Task",
    mjbizappstaskstaskdecisionoutcome_outcomeid."Name" AS "Outcome",
    mjbizappscommonperson_decidedbypersonid."DisplayName" AS "DecidedByPerson"
   FROM __mj_bizappstasks."TaskDecision" t
     JOIN __mj_bizappstasks."Task" mjbizappstaskstask_taskid ON t."TaskID" = mjbizappstaskstask_taskid."ID"
     JOIN __mj_bizappstasks."TaskDecisionOutcome" mjbizappstaskstaskdecisionoutcome_outcomeid ON t."OutcomeID" = mjbizappstaskstaskdecisionoutcome_outcomeid."ID"
     LEFT JOIN __mj_bizappscommon."Person" mjbizappscommonperson_decidedbypersonid ON t."DecidedByPersonID" = mjbizappscommonperson_decidedbypersonid."ID";$vsql$;
  v_target_oid OID;
  v_dep RECORD;
  v_captured JSONB[] := ARRAY[]::JSONB[];
  v_n INTEGER;
BEGIN
  EXECUTE vsql;
EXCEPTION WHEN invalid_table_definition THEN
  -- Column list changed; need CASCADE. Preserve dependent views first.
  SELECT c.oid INTO v_target_oid
  FROM pg_class c JOIN pg_namespace n ON c.relnamespace = n.oid
  WHERE n.nspname = v_target_schema AND c.relname = v_target_name AND c.relkind = 'v';
  IF v_target_oid IS NOT NULL THEN
    FOR v_dep IN
      WITH RECURSIVE deps AS (
        SELECT c.oid, c.relname AS name, n.nspname AS schema, 1 AS depth
        FROM pg_rewrite r
        JOIN pg_depend d ON d.objid = r.oid
        JOIN pg_class c ON c.oid = r.ev_class
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE d.refobjid = v_target_oid AND d.deptype = 'n'
          AND c.oid <> v_target_oid AND c.relkind = 'v'
        UNION
        SELECT c.oid, c.relname, n.nspname, p.depth + 1
        FROM deps p
        JOIN pg_rewrite r ON TRUE
        JOIN pg_depend d ON d.objid = r.oid AND d.refobjid = p.oid
        JOIN pg_class c ON c.oid = r.ev_class
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE c.relkind = 'v' AND c.oid <> p.oid
      )
      SELECT oid, name, schema, MAX(depth) AS max_depth,
             pg_catalog.pg_get_viewdef(oid, true) AS viewdef
      FROM deps GROUP BY oid, name, schema
      ORDER BY MAX(depth) ASC
    LOOP
      v_captured := v_captured || jsonb_build_object(
        'schema', v_dep.schema, 'name', v_dep.name, 'def', v_dep.viewdef);
    END LOOP;
  END IF;
  EXECUTE format('DROP VIEW IF EXISTS %I.%I CASCADE', v_target_schema, v_target_name);
  EXECUTE vsql;
  IF v_captured IS NOT NULL AND array_length(v_captured, 1) > 0 THEN
    FOR v_n IN 1..array_length(v_captured, 1) LOOP
      BEGIN
        EXECUTE format('CREATE VIEW %I.%I AS %s',
          v_captured[v_n]->>'schema', v_captured[v_n]->>'name', v_captured[v_n]->>'def');
      EXCEPTION WHEN others THEN
        RAISE WARNING 'Could not restore dependent view %.%: %',
          v_captured[v_n]->>'schema', v_captured[v_n]->>'name', SQLERRM;
      END;
    END LOOP;
  END IF;
END;
$do$;

DROP VIEW IF EXISTS __mj_bizappstasks."vwTaskTypes" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_bizappstasks';
  v_target_name CONSTANT TEXT := 'vwTaskTypes';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_bizappstasks."vwTaskTypes"
AS SELECT t."ID",
    t."Name",
    t."Description",
    t."IconClass",
    t."DefaultPriority",
    t."OnAssignActionID",
    t."OnCompleteActionID",
    t."OnOverdueActionID",
    t."OnPercentChangeActionID",
    t."IsActive",
    t."__mj_CreatedAt",
    t."__mj_UpdatedAt",
    t."OnRejectActionID",
    t."OnCancelActionID",
    mjaction_onassignactionid."Name" AS "OnAssignAction",
    mjaction_oncompleteactionid."Name" AS "OnCompleteAction",
    mjaction_onoverdueactionid."Name" AS "OnOverdueAction",
    mjaction_onpercentchangeactionid."Name" AS "OnPercentChangeAction",
    mjaction_onrejectactionid."Name" AS "OnRejectAction",
    mjaction_oncancelactionid."Name" AS "OnCancelAction"
   FROM __mj_bizappstasks."TaskType" t
     LEFT JOIN ${mjSchema}."Action" mjaction_onassignactionid ON t."OnAssignActionID" = mjaction_onassignactionid."ID"
     LEFT JOIN ${mjSchema}."Action" mjaction_oncompleteactionid ON t."OnCompleteActionID" = mjaction_oncompleteactionid."ID"
     LEFT JOIN ${mjSchema}."Action" mjaction_onoverdueactionid ON t."OnOverdueActionID" = mjaction_onoverdueactionid."ID"
     LEFT JOIN ${mjSchema}."Action" mjaction_onpercentchangeactionid ON t."OnPercentChangeActionID" = mjaction_onpercentchangeactionid."ID"
     LEFT JOIN ${mjSchema}."Action" mjaction_onrejectactionid ON t."OnRejectActionID" = mjaction_onrejectactionid."ID"
     LEFT JOIN ${mjSchema}."Action" mjaction_oncancelactionid ON t."OnCancelActionID" = mjaction_oncancelactionid."ID";$vsql$;
  v_target_oid OID;
  v_dep RECORD;
  v_captured JSONB[] := ARRAY[]::JSONB[];
  v_n INTEGER;
BEGIN
  EXECUTE vsql;
EXCEPTION WHEN invalid_table_definition THEN
  -- Column list changed; need CASCADE. Preserve dependent views first.
  SELECT c.oid INTO v_target_oid
  FROM pg_class c JOIN pg_namespace n ON c.relnamespace = n.oid
  WHERE n.nspname = v_target_schema AND c.relname = v_target_name AND c.relkind = 'v';
  IF v_target_oid IS NOT NULL THEN
    FOR v_dep IN
      WITH RECURSIVE deps AS (
        SELECT c.oid, c.relname AS name, n.nspname AS schema, 1 AS depth
        FROM pg_rewrite r
        JOIN pg_depend d ON d.objid = r.oid
        JOIN pg_class c ON c.oid = r.ev_class
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE d.refobjid = v_target_oid AND d.deptype = 'n'
          AND c.oid <> v_target_oid AND c.relkind = 'v'
        UNION
        SELECT c.oid, c.relname, n.nspname, p.depth + 1
        FROM deps p
        JOIN pg_rewrite r ON TRUE
        JOIN pg_depend d ON d.objid = r.oid AND d.refobjid = p.oid
        JOIN pg_class c ON c.oid = r.ev_class
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE c.relkind = 'v' AND c.oid <> p.oid
      )
      SELECT oid, name, schema, MAX(depth) AS max_depth,
             pg_catalog.pg_get_viewdef(oid, true) AS viewdef
      FROM deps GROUP BY oid, name, schema
      ORDER BY MAX(depth) ASC
    LOOP
      v_captured := v_captured || jsonb_build_object(
        'schema', v_dep.schema, 'name', v_dep.name, 'def', v_dep.viewdef);
    END LOOP;
  END IF;
  EXECUTE format('DROP VIEW IF EXISTS %I.%I CASCADE', v_target_schema, v_target_name);
  EXECUTE vsql;
  IF v_captured IS NOT NULL AND array_length(v_captured, 1) > 0 THEN
    FOR v_n IN 1..array_length(v_captured, 1) LOOP
      BEGIN
        EXECUTE format('CREATE VIEW %I.%I AS %s',
          v_captured[v_n]->>'schema', v_captured[v_n]->>'name', v_captured[v_n]->>'def');
      EXCEPTION WHEN others THEN
        RAISE WARNING 'Could not restore dependent view %.%: %',
          v_captured[v_n]->>'schema', v_captured[v_n]->>'name', SQLERRM;
      END;
    END LOOP;
  END IF;
END;
$do$;


-- ===================== Stored Procedures (sp*) =====================

-- spCreateTaskDecisionOutcome: native plpgsql as emitted by MJ CodeGen (replaces the skipped T-SQL procedure)
CREATE OR REPLACE FUNCTION __mj_bizappstasks."spCreateTaskDecisionOutcome"(p_id uuid DEFAULT NULL::uuid, p_name character varying DEFAULT NULL::character varying, p_code character varying DEFAULT NULL::character varying, p_description_clear boolean DEFAULT false, p_description text DEFAULT NULL::text, p_sequence integer DEFAULT NULL::integer, p_isterminal boolean DEFAULT NULL::boolean, p_isactive boolean DEFAULT NULL::boolean)
 RETURNS SETOF __mj_bizappstasks."vwTaskDecisionOutcomes"
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_new_id UUID;
BEGIN
    v_new_id := COALESCE(p_id, gen_random_uuid());
    INSERT INTO __mj_bizappstasks."TaskDecisionOutcome"
        (
            "ID",
            "Name",
                "Code",
                "Description",
                "Sequence",
                "IsTerminal",
                "IsActive"
        )
    VALUES
        (
            v_new_id,
            p_name,
                p_code,
                CASE WHEN p_description_clear = true THEN NULL ELSE COALESCE(p_description, NULL) END,
                COALESCE(p_sequence, 100),
                COALESCE(p_isterminal, TRUE),
                COALESCE(p_isactive, TRUE)
        )
    ;

    RETURN QUERY
    SELECT * FROM __mj_bizappstasks."vwTaskDecisionOutcomes"
    WHERE "ID" = v_new_id;
END;
$function$;

-- spUpdateTaskDecisionOutcome: native plpgsql as emitted by MJ CodeGen (replaces the skipped T-SQL procedure)
CREATE OR REPLACE FUNCTION __mj_bizappstasks."spUpdateTaskDecisionOutcome"(p_id uuid, p_name character varying DEFAULT NULL::character varying, p_code character varying DEFAULT NULL::character varying, p_description_clear boolean DEFAULT false, p_description text DEFAULT NULL::text, p_sequence integer DEFAULT NULL::integer, p_isterminal boolean DEFAULT NULL::boolean, p_isactive boolean DEFAULT NULL::boolean)
 RETURNS SETOF __mj_bizappstasks."vwTaskDecisionOutcomes"
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_updated_count INTEGER;
BEGIN
    UPDATE __mj_bizappstasks."TaskDecisionOutcome"
    SET
        "Name" = COALESCE(p_name, "Name"),
        "Code" = COALESCE(p_code, "Code"),
        "Description" = CASE WHEN p_description_clear = true THEN NULL ELSE COALESCE(p_description, "Description") END,
        "Sequence" = COALESCE(p_sequence, "Sequence"),
        "IsTerminal" = COALESCE(p_isterminal, "IsTerminal"),
        "IsActive" = COALESCE(p_isactive, "IsActive")
    WHERE
        "ID" = p_id;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    IF v_updated_count = 0 THEN
        -- Nothing was updated, return empty result set
        RETURN;
    END IF;

    -- Return the updated record from the base view
    RETURN QUERY
    SELECT * FROM __mj_bizappstasks."vwTaskDecisionOutcomes"
    WHERE "ID" = p_id;
END;
$function$;

-- spDeleteTaskDecisionOutcome: native plpgsql as emitted by MJ CodeGen (replaces the skipped T-SQL procedure)
CREATE OR REPLACE FUNCTION __mj_bizappstasks."spDeleteTaskDecisionOutcome"(p_id uuid)
 RETURNS TABLE("ID" uuid)
 LANGUAGE plpgsql
AS $function$
#variable_conflict use_column
DECLARE
    v_affected_count INTEGER;
BEGIN

    DELETE FROM __mj_bizappstasks."TaskDecisionOutcome"
    WHERE "ID" = p_id;

    GET DIAGNOSTICS v_affected_count = ROW_COUNT;

    IF v_affected_count = 0 THEN
        RETURN QUERY SELECT NULL::UUID AS "ID";
    ELSE
        RETURN QUERY SELECT p_id AS "ID";
    END IF;
END;
$function$;

-- spCreateTaskDecision: native plpgsql as emitted by MJ CodeGen (replaces the skipped T-SQL procedure)
CREATE OR REPLACE FUNCTION __mj_bizappstasks."spCreateTaskDecision"(p_id uuid DEFAULT NULL::uuid, p_taskid uuid DEFAULT NULL::uuid, p_outcomeid uuid DEFAULT NULL::uuid, p_decidedbypersonid_clear boolean DEFAULT false, p_decidedbypersonid uuid DEFAULT NULL::uuid, p_decidedat timestamp with time zone DEFAULT NULL::timestamp with time zone, p_decisionnotes_clear boolean DEFAULT false, p_decisionnotes text DEFAULT NULL::text, p_taskassignmentid_clear boolean DEFAULT false, p_taskassignmentid uuid DEFAULT NULL::uuid)
 RETURNS SETOF __mj_bizappstasks."vwTaskDecisions"
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_new_id UUID;
BEGIN
    v_new_id := COALESCE(p_id, gen_random_uuid());
    INSERT INTO __mj_bizappstasks."TaskDecision"
        (
            "ID",
            "TaskID",
                "OutcomeID",
                "DecidedByPersonID",
                "DecidedAt",
                "DecisionNotes",
                "TaskAssignmentID"
        )
    VALUES
        (
            v_new_id,
            p_taskid,
                p_outcomeid,
                CASE WHEN p_decidedbypersonid_clear = true THEN NULL ELSE COALESCE(p_decidedbypersonid, NULL) END,
                COALESCE(p_decidedat, NOW()),
                CASE WHEN p_decisionnotes_clear = true THEN NULL ELSE COALESCE(p_decisionnotes, NULL) END,
                CASE WHEN p_taskassignmentid_clear = true THEN NULL ELSE COALESCE(p_taskassignmentid, NULL) END
        )
    ;

    RETURN QUERY
    SELECT * FROM __mj_bizappstasks."vwTaskDecisions"
    WHERE "ID" = v_new_id;
END;
$function$;

-- spUpdateTaskDecision: native plpgsql as emitted by MJ CodeGen (replaces the skipped T-SQL procedure)
CREATE OR REPLACE FUNCTION __mj_bizappstasks."spUpdateTaskDecision"(p_id uuid, p_taskid uuid DEFAULT NULL::uuid, p_outcomeid uuid DEFAULT NULL::uuid, p_decidedbypersonid_clear boolean DEFAULT false, p_decidedbypersonid uuid DEFAULT NULL::uuid, p_decidedat timestamp with time zone DEFAULT NULL::timestamp with time zone, p_decisionnotes_clear boolean DEFAULT false, p_decisionnotes text DEFAULT NULL::text, p_taskassignmentid_clear boolean DEFAULT false, p_taskassignmentid uuid DEFAULT NULL::uuid)
 RETURNS SETOF __mj_bizappstasks."vwTaskDecisions"
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_updated_count INTEGER;
BEGIN
    UPDATE __mj_bizappstasks."TaskDecision"
    SET
        "TaskID" = COALESCE(p_taskid, "TaskID"),
        "OutcomeID" = COALESCE(p_outcomeid, "OutcomeID"),
        "DecidedByPersonID" = CASE WHEN p_decidedbypersonid_clear = true THEN NULL ELSE COALESCE(p_decidedbypersonid, "DecidedByPersonID") END,
        "DecidedAt" = COALESCE(p_decidedat, "DecidedAt"),
        "DecisionNotes" = CASE WHEN p_decisionnotes_clear = true THEN NULL ELSE COALESCE(p_decisionnotes, "DecisionNotes") END,
        "TaskAssignmentID" = CASE WHEN p_taskassignmentid_clear = true THEN NULL ELSE COALESCE(p_taskassignmentid, "TaskAssignmentID") END
    WHERE
        "ID" = p_id;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    IF v_updated_count = 0 THEN
        -- Nothing was updated, return empty result set
        RETURN;
    END IF;

    -- Return the updated record from the base view
    RETURN QUERY
    SELECT * FROM __mj_bizappstasks."vwTaskDecisions"
    WHERE "ID" = p_id;
END;
$function$;

-- spDeleteTaskDecision: native plpgsql as emitted by MJ CodeGen (replaces the skipped T-SQL procedure)
CREATE OR REPLACE FUNCTION __mj_bizappstasks."spDeleteTaskDecision"(p_id uuid)
 RETURNS TABLE("ID" uuid)
 LANGUAGE plpgsql
AS $function$
#variable_conflict use_column
DECLARE
    v_affected_count INTEGER;
BEGIN

    DELETE FROM __mj_bizappstasks."TaskDecision"
    WHERE "ID" = p_id;

    GET DIAGNOSTICS v_affected_count = ROW_COUNT;

    IF v_affected_count = 0 THEN
        RETURN QUERY SELECT NULL::UUID AS "ID";
    ELSE
        RETURN QUERY SELECT p_id AS "ID";
    END IF;
END;
$function$;

-- spCreateTaskType: native plpgsql as emitted by MJ CodeGen (replaces the skipped T-SQL procedure)
CREATE OR REPLACE FUNCTION __mj_bizappstasks."spCreateTaskType"(p_id uuid DEFAULT NULL::uuid, p_name character varying DEFAULT NULL::character varying, p_description_clear boolean DEFAULT false, p_description text DEFAULT NULL::text, p_iconclass_clear boolean DEFAULT false, p_iconclass character varying DEFAULT NULL::character varying, p_defaultpriority character varying DEFAULT NULL::character varying, p_onassignactionid_clear boolean DEFAULT false, p_onassignactionid uuid DEFAULT NULL::uuid, p_oncompleteactionid_clear boolean DEFAULT false, p_oncompleteactionid uuid DEFAULT NULL::uuid, p_onoverdueactionid_clear boolean DEFAULT false, p_onoverdueactionid uuid DEFAULT NULL::uuid, p_onpercentchangeactionid_clear boolean DEFAULT false, p_onpercentchangeactionid uuid DEFAULT NULL::uuid, p_isactive boolean DEFAULT NULL::boolean, p_onrejectactionid_clear boolean DEFAULT false, p_onrejectactionid uuid DEFAULT NULL::uuid, p_oncancelactionid_clear boolean DEFAULT false, p_oncancelactionid uuid DEFAULT NULL::uuid)
 RETURNS SETOF __mj_bizappstasks."vwTaskTypes"
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_new_id UUID;
BEGIN
    v_new_id := COALESCE(p_id, gen_random_uuid());
    INSERT INTO __mj_bizappstasks."TaskType"
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
                "OnCancelActionID"
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
                CASE WHEN p_oncancelactionid_clear = true THEN NULL ELSE COALESCE(p_oncancelactionid, NULL) END
        )
    ;

    RETURN QUERY
    SELECT * FROM __mj_bizappstasks."vwTaskTypes"
    WHERE "ID" = v_new_id;
END;
$function$;

-- spUpdateTaskType: native plpgsql as emitted by MJ CodeGen (replaces the skipped T-SQL procedure)
CREATE OR REPLACE FUNCTION __mj_bizappstasks."spUpdateTaskType"(p_id uuid, p_name character varying DEFAULT NULL::character varying, p_description_clear boolean DEFAULT false, p_description text DEFAULT NULL::text, p_iconclass_clear boolean DEFAULT false, p_iconclass character varying DEFAULT NULL::character varying, p_defaultpriority character varying DEFAULT NULL::character varying, p_onassignactionid_clear boolean DEFAULT false, p_onassignactionid uuid DEFAULT NULL::uuid, p_oncompleteactionid_clear boolean DEFAULT false, p_oncompleteactionid uuid DEFAULT NULL::uuid, p_onoverdueactionid_clear boolean DEFAULT false, p_onoverdueactionid uuid DEFAULT NULL::uuid, p_onpercentchangeactionid_clear boolean DEFAULT false, p_onpercentchangeactionid uuid DEFAULT NULL::uuid, p_isactive boolean DEFAULT NULL::boolean, p_onrejectactionid_clear boolean DEFAULT false, p_onrejectactionid uuid DEFAULT NULL::uuid, p_oncancelactionid_clear boolean DEFAULT false, p_oncancelactionid uuid DEFAULT NULL::uuid)
 RETURNS SETOF __mj_bizappstasks."vwTaskTypes"
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_updated_count INTEGER;
BEGIN
    UPDATE __mj_bizappstasks."TaskType"
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
        "OnCancelActionID" = CASE WHEN p_oncancelactionid_clear = true THEN NULL ELSE COALESCE(p_oncancelactionid, "OnCancelActionID") END
    WHERE
        "ID" = p_id;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    IF v_updated_count = 0 THEN
        -- Nothing was updated, return empty result set
        RETURN;
    END IF;

    -- Return the updated record from the base view
    RETURN QUERY
    SELECT * FROM __mj_bizappstasks."vwTaskTypes"
    WHERE "ID" = p_id;
END;
$function$;

-- spDeleteTaskType: native plpgsql as emitted by MJ CodeGen (replaces the skipped T-SQL procedure)
CREATE OR REPLACE FUNCTION __mj_bizappstasks."spDeleteTaskType"(p_id uuid)
 RETURNS TABLE("ID" uuid)
 LANGUAGE plpgsql
AS $function$
#variable_conflict use_column
DECLARE
    v_affected_count INTEGER;
BEGIN

    DELETE FROM __mj_bizappstasks."TaskType"
    WHERE "ID" = p_id;

    GET DIAGNOSTICS v_affected_count = ROW_COUNT;

    IF v_affected_count = 0 THEN
        RETURN QUERY SELECT NULL::UUID AS "ID";
    ELSE
        RETURN QUERY SELECT p_id AS "ID";
    END IF;
END;
$function$;


-- ===================== Triggers =====================

-- trg_update_task_decision_outcome: native row-touch trigger as emitted by MJ CodeGen (replaces the skipped T-SQL trigger)
CREATE OR REPLACE FUNCTION __mj_bizappstasks.fn_trg_update_task_decision_outcome()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW."__mj_UpdatedAt" := NOW() AT TIME ZONE 'UTC';
    RETURN NEW;
END;
$function$;
CREATE OR REPLACE TRIGGER trg_update_task_decision_outcome BEFORE UPDATE ON __mj_bizappstasks."TaskDecisionOutcome" FOR EACH ROW EXECUTE FUNCTION __mj_bizappstasks.fn_trg_update_task_decision_outcome();

-- trg_update_task_decision: native row-touch trigger as emitted by MJ CodeGen (replaces the skipped T-SQL trigger)
CREATE OR REPLACE FUNCTION __mj_bizappstasks.fn_trg_update_task_decision()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW."__mj_UpdatedAt" := NOW() AT TIME ZONE 'UTC';
    RETURN NEW;
END;
$function$;
CREATE OR REPLACE TRIGGER trg_update_task_decision BEFORE UPDATE ON __mj_bizappstasks."TaskDecision" FOR EACH ROW EXECUTE FUNCTION __mj_bizappstasks.fn_trg_update_task_decision();
 

-- trg_update_task_type: native row-touch trigger as emitted by MJ CodeGen (replaces the skipped T-SQL trigger)
CREATE OR REPLACE FUNCTION __mj_bizappstasks.fn_trg_update_task_type()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW."__mj_UpdatedAt" := NOW() AT TIME ZONE 'UTC';
    RETURN NEW;
END;
$function$;
CREATE OR REPLACE TRIGGER trg_update_task_type BEFORE UPDATE ON __mj_bizappstasks."TaskType" FOR EACH ROW EXECUTE FUNCTION __mj_bizappstasks.fn_trg_update_task_type();


-- ===================== Data (INSERT/UPDATE/DELETE) =====================

INSERT INTO "${mjSchema}"."Entity" (
         "ID",
         "Name",
         "DisplayName",
         "Description",
         "NameSuffix",
         "BaseTable",
         "BaseView",
         "SchemaName",
         "IncludeInAPI",
         "AllowUserSearchAPI",
         "AllowCaching"
         , "TrackRecordChanges"
         , "AuditRecordAccess"
         , "AuditViewRuns"
         , "AllowAllRowsAPI"
         , "AllowCreateAPI"
         , "AllowUpdateAPI"
         , "AllowDeleteAPI"
         , "UserViewMaxRows"
         , "__mj_CreatedAt"
         , "__mj_UpdatedAt"
      )
      VALUES (
         'd3868906-e957-4061-a79d-6ce7a96dc0ed',
         'MJ_BizApps_Tasks: Task Decision Outcomes',
         'Task Decision Outcomes',
         NULL,
         NULL,
         'TaskDecisionOutcome',
         'vwTaskDecisionOutcomes',
         '__mj_bizappstasks',
         TRUE,
         TRUE,
         FALSE
         , TRUE
         , FALSE
         , FALSE
         , FALSE
         , TRUE
         , TRUE
         , TRUE
         , 1000
         , NOW()
         , NOW()
      );

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Decision Outcomes to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'd3868906-e957-4061-a79d-6ce7a96dc0ed', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Decision Outcomes for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('d3868906-e957-4061-a79d-6ce7a96dc0ed', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Decision Outcomes for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('d3868906-e957-4061-a79d-6ce7a96dc0ed', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Decision Outcomes for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('d3868906-e957-4061-a79d-6ce7a96dc0ed', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Decisions */

INSERT INTO "${mjSchema}"."Entity" (
         "ID",
         "Name",
         "DisplayName",
         "Description",
         "NameSuffix",
         "BaseTable",
         "BaseView",
         "SchemaName",
         "IncludeInAPI",
         "AllowUserSearchAPI",
         "AllowCaching"
         , "TrackRecordChanges"
         , "AuditRecordAccess"
         , "AuditViewRuns"
         , "AllowAllRowsAPI"
         , "AllowCreateAPI"
         , "AllowUpdateAPI"
         , "AllowDeleteAPI"
         , "UserViewMaxRows"
         , "__mj_CreatedAt"
         , "__mj_UpdatedAt"
      )
      VALUES (
         '78ef0be0-1a0b-48d3-be06-8524e3cd7fdf',
         'MJ_BizApps_Tasks: Task Decisions',
         'Task Decisions',
         NULL,
         NULL,
         'TaskDecision',
         'vwTaskDecisions',
         '__mj_bizappstasks',
         TRUE,
         TRUE,
         FALSE
         , TRUE
         , FALSE
         , FALSE
         , FALSE
         , TRUE
         , TRUE
         , TRUE
         , 1000
         , NOW()
         , NOW()
      );

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Decisions to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '78ef0be0-1a0b-48d3-be06-8524e3cd7fdf', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Decisions for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('78ef0be0-1a0b-48d3-be06-8524e3cd7fdf', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Decisions for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('78ef0be0-1a0b-48d3-be06-8524e3cd7fdf', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Decisions for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('78ef0be0-1a0b-48d3-be06-8524e3cd7fdf', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL text to update existing entities from schema */

/* SQL text to add special date field __mj_CreatedAt to entity __mj_bizappstasks."TaskDecisionOutcome" */
UPDATE __mj_bizappstasks."TaskDecisionOutcome" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_bizappstasks."TaskDecisionOutcome" */
ALTER TABLE __mj_bizappstasks."TaskDecisionOutcome" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE __mj_bizappstasks."TaskDecisionOutcome"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_bizappstasks."TaskDecisionOutcome" */
UPDATE __mj_bizappstasks."TaskDecisionOutcome" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_bizappstasks."TaskDecisionOutcome" */
ALTER TABLE __mj_bizappstasks."TaskDecisionOutcome" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE __mj_bizappstasks."TaskDecisionOutcome"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity __mj_bizappstasks."TaskDecision" */
UPDATE __mj_bizappstasks."TaskDecision" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_bizappstasks."TaskDecision" */
ALTER TABLE __mj_bizappstasks."TaskDecision" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE __mj_bizappstasks."TaskDecision"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_bizappstasks."TaskDecision" */
UPDATE __mj_bizappstasks."TaskDecision" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_bizappstasks."TaskDecision" */
ALTER TABLE __mj_bizappstasks."TaskDecision" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE __mj_bizappstasks."TaskDecision"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '062009d5-6662-48ce-8db6-ee9b68ef38c2' OR ("EntityID" = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND "Name" = 'ID')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '062009d5-6662-48ce-8db6-ee9b68ef38c2',
        'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decision" "Outcomes"
        100001,
        'ID',
        'ID',
        NULL,
        'UUID',
        16,
        0,
        0,
        FALSE,
        'gen_random_uuid()',
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        TRUE,
        TRUE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '13307cb7-4c4c-49b1-9ddd-bc6bf31d5aa2' OR ("EntityID" = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND "Name" = 'Name')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '13307cb7-4c4c-49b1-9ddd-bc6bf31d5aa2',
        'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decision" "Outcomes"
        100002,
        'Name',
        'Name',
        'Human-readable outcome label (e.g. Approved, Rejected, Approved With Conditions).',
        'TEXT',
        200,
        0,
        0,
        FALSE,
        NULL,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        NULL,
        NULL,
        TRUE,
        TRUE,
        FALSE,
        TRUE,
        FALSE,
        TRUE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '1ccf7e45-4e05-4621-ade8-dec702a85f30' OR ("EntityID" = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND "Name" = 'Code')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '1ccf7e45-4e05-4621-ade8-dec702a85f30',
        'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decision" "Outcomes"
        100003,
        'Code',
        'Code',
        'Stable machine code for the outcome, used by orchestration code to map outcome to task status (e.g. Approved, Rejected, ApprovedWithConditions).',
        'TEXT',
        100,
        0,
        0,
        FALSE,
        NULL,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        TRUE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '72a08d0c-73c9-4de6-b8bd-98b6dc25b95b' OR ("EntityID" = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND "Name" = 'Description')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '72a08d0c-73c9-4de6-b8bd-98b6dc25b95b',
        'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decision" "Outcomes"
        100004,
        'Description',
        'Description',
        NULL,
        'TEXT',
        -1,
        0,
        0,
        TRUE,
        NULL,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '61499937-ee87-4b0e-94f0-b3abe411dcd9' OR ("EntityID" = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND "Name" = 'Sequence')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '61499937-ee87-4b0e-94f0-b3abe411dcd9',
        'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decision" "Outcomes"
        100005,
        'Sequence',
        'Sequence',
        'Display ordering for the outcome in decision pickers.',
        'INTEGER',
        4,
        10,
        0,
        FALSE,
        '(100)',
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '6ea8984b-1218-49d5-874d-2a39bec98316' OR ("EntityID" = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND "Name" = 'IsTerminal')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '6ea8984b-1218-49d5-874d-2a39bec98316',
        'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decision" "Outcomes"
        100006,
        'IsTerminal',
        'Is Terminal',
        'When 1, recording this outcome closes the approval (terminal). When 0, the decision is interim and the task remains open.',
        'BOOLEAN',
        1,
        1,
        0,
        FALSE,
        '(1)',
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'bfa5d2b0-3d60-4acd-9478-e8fe5d02a820' OR ("EntityID" = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND "Name" = 'IsActive')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        'bfa5d2b0-3d60-4acd-9478-e8fe5d02a820',
        'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decision" "Outcomes"
        100007,
        'IsActive',
        'Is Active',
        'When 0, the outcome is hidden from new decision pickers but preserved on historical decisions.',
        'BOOLEAN',
        1,
        1,
        0,
        FALSE,
        '(1)',
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '7c4cdb23-ab35-488d-84aa-3a54f8c4112f' OR ("EntityID" = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND "Name" = '__mj_CreatedAt')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '7c4cdb23-ab35-488d-84aa-3a54f8c4112f',
        'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decision" "Outcomes"
        100008,
        '__mj_CreatedAt',
        'Created At',
        NULL,
        'TIMESTAMPTZ',
        10,
        34,
        7,
        FALSE,
        'NOW()',
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '9cdef81f-e064-48fb-ac86-0ea86123a499' OR ("EntityID" = 'D3868906-E957-4061-A79D-6CE7A96DC0ED' AND "Name" = '__mj_UpdatedAt')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '9cdef81f-e064-48fb-ac86-0ea86123a499',
        'D3868906-E957-4061-A79D-6CE7A96DC0ED', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decision" "Outcomes"
        100009,
        '__mj_UpdatedAt',
        'Updated At',
        NULL,
        'TIMESTAMPTZ',
        10,
        34,
        7,
        FALSE,
        'NOW()',
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '9e1a5e43-07a2-4f96-bca6-0c47444ecff9' OR ("EntityID" = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND "Name" = 'ID')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '9e1a5e43-07a2-4f96-bca6-0c47444ecff9',
        '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decisions"
        100001,
        'ID',
        'ID',
        NULL,
        'UUID',
        16,
        0,
        0,
        FALSE,
        'gen_random_uuid()',
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        TRUE,
        TRUE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '16b9251a-bcb9-454b-99bc-29cb6c39d590' OR ("EntityID" = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND "Name" = 'TaskID')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '16b9251a-bcb9-454b-99bc-29cb6c39d590',
        '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decisions"
        100002,
        'TaskID',
        'Task ID',
        'The task this decision was recorded against.',
        'UUID',
        16,
        0,
        0,
        FALSE,
        NULL,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
        'ID',
        FALSE,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '1f74f328-548c-418d-ac2b-ade7cd40907c' OR ("EntityID" = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND "Name" = 'OutcomeID')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '1f74f328-548c-418d-ac2b-ade7cd40907c',
        '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decisions"
        100003,
        'OutcomeID',
        'Outcome ID',
        'The decision outcome (FK to TaskDecisionOutcome).',
        'UUID',
        16,
        0,
        0,
        FALSE,
        NULL,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        'D3868906-E957-4061-A79D-6CE7A96DC0ED',
        'ID',
        FALSE,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'de230ab6-50c3-47ee-9bd8-761caac10a01' OR ("EntityID" = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND "Name" = 'DecidedByPersonID')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        'de230ab6-50c3-47ee-9bd8-761caac10a01',
        '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decisions"
        100004,
        'DecidedByPersonID',
        'Decided By Person ID',
        'The Person who made the decision.',
        'UUID',
        16,
        0,
        0,
        TRUE,
        NULL,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F',
        'ID',
        FALSE,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'd00f04d1-2af0-439a-806a-eae9e4321fb8' OR ("EntityID" = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND "Name" = 'DecidedAt')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        'd00f04d1-2af0-439a-806a-eae9e4321fb8',
        '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decisions"
        100005,
        'DecidedAt',
        'Decided At',
        'When the decision was recorded.',
        'TIMESTAMPTZ',
        10,
        34,
        7,
        FALSE,
        'NOW()',
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '97659d3f-72d7-4e58-9af4-e6deeea7fa50' OR ("EntityID" = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND "Name" = 'DecisionNotes')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '97659d3f-72d7-4e58-9af4-e6deeea7fa50',
        '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decisions"
        100006,
        'DecisionNotes',
        'Decision Notes',
        'Free-text rationale or conditions attached to the decision.',
        'TEXT',
        -1,
        0,
        0,
        TRUE,
        NULL,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'b075c87d-5e21-4b94-b77a-cc5d2e59d909' OR ("EntityID" = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND "Name" = 'TaskAssignmentID')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        'b075c87d-5e21-4b94-b77a-cc5d2e59d909',
        '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decisions"
        100007,
        'TaskAssignmentID',
        'Task Assignment ID',
        'Optional link to the specific TaskAssignment this decision belongs to, for per-assignee decisions in multi-approver flows. Null for a task-level decision.',
        'UUID',
        16,
        0,
        0,
        TRUE,
        NULL,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        'DF98E700-1992-442B-B93E-E47379F2CA52',
        'ID',
        FALSE,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'da3abe83-4369-46e2-ac33-811e32a57ff2' OR ("EntityID" = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND "Name" = '__mj_CreatedAt')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        'da3abe83-4369-46e2-ac33-811e32a57ff2',
        '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decisions"
        100008,
        '__mj_CreatedAt',
        'Created At',
        NULL,
        'TIMESTAMPTZ',
        10,
        34,
        7,
        FALSE,
        'NOW()',
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'e16ec915-fde1-452e-bf76-77ffb6f2f6c9' OR ("EntityID" = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND "Name" = '__mj_UpdatedAt')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        'e16ec915-fde1-452e-bf76-77ffb6f2f6c9',
        '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decisions"
        100009,
        '__mj_UpdatedAt',
        'Updated At',
        NULL,
        'TIMESTAMPTZ',
        10,
        34,
        7,
        FALSE,
        'NOW()',
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '04b4f98d-f79d-4a84-9f63-fb5ffac014d5' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'OnRejectActionID')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '04b4f98d-f79d-4a84-9f63-fb5ffac014d5',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100029,
        'OnRejectActionID',
        'On Reject Action ID',
        'Action invoked when a task of this type transitions to a rejected decision (post-commit, non-blocking). Used by approval workflows.',
        'UUID',
        16,
        0,
        0,
        TRUE,
        NULL,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        '38248F34-2837-EF11-86D4-6045BDEE16E6',
        'ID',
        FALSE,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'a86f3057-5e26-450f-a958-2c1f63dd2a88' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'OnCancelActionID')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        'a86f3057-5e26-450f-a958-2c1f63dd2a88',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100030,
        'OnCancelActionID',
        'On Cancel Action ID',
        'Action invoked when a task of this type transitions to Cancelled (post-commit, non-blocking).',
        'UUID',
        16,
        0,
        0,
        TRUE,
        NULL,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        '38248F34-2837-EF11-86D4-6045BDEE16E6',
        'ID',
        FALSE,
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('8ae2a9c0-e952-4271-a1c2-3853347bf37b', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 5, 'DecisionRecorded', 'DecisionRecorded', NOW(), NOW());

/* SQL text to update entity field value sequence */

UPDATE "${mjSchema}"."EntityFieldValue" SET "Sequence"=6 WHERE "ID"='3B04B519-5C74-45B1-BA4B-94372125B7E5';

/* SQL text to update entity field value sequence */

UPDATE "${mjSchema}"."EntityFieldValue" SET "Sequence"=7 WHERE "ID"='F0EC7C9E-9646-491F-929E-165449D8929E';

/* SQL text to update entity field value sequence */

UPDATE "${mjSchema}"."EntityFieldValue" SET "Sequence"=8 WHERE "ID"='F86D7D4F-2042-4A2B-A984-6C6C073D1CB1';

/* SQL text to update entity field value sequence */

UPDATE "${mjSchema}"."EntityFieldValue" SET "Sequence"=9 WHERE "ID"='40B53F38-2CE5-41B1-8116-D2340BF0B78B';

/* SQL text to update entity field value sequence */

UPDATE "${mjSchema}"."EntityFieldValue" SET "Sequence"=10 WHERE "ID"='DD9E09D4-FF5D-44DC-8AC4-7554FEEE32FB';

/* SQL text to update entity field value sequence */

UPDATE "${mjSchema}"."EntityFieldValue" SET "Sequence"=11 WHERE "ID"='20257078-873D-4C95-9DD9-078E4E856FCB';


/* Create Entity Relationship: MJ: Actions -> MJ_BizApps_Tasks: Task Types (One To Many via OnCancelActionID) */

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '06b9d0ba-ab58-43bb-84f9-20632810000c'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('06b9d0ba-ab58-43bb-84f9-20632810000c', '38248F34-2837-EF11-86D4-6045BDEE16E6', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'OnCancelActionID', 'One To Many', TRUE, TRUE, 18, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '54960c7c-5267-4ddd-bd5a-7e9f3cc486ee'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('54960c7c-5267-4ddd-bd5a-7e9f3cc486ee', '38248F34-2837-EF11-86D4-6045BDEE16E6', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'OnRejectActionID', 'One To Many', TRUE, TRUE, 19, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = 'a608e0d6-054c-4924-9fd8-e627918068dd'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('a608e0d6-054c-4924-9fd8-e627918068dd', 'D3868906-E957-4061-A79D-6CE7A96DC0ED', '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', 'OutcomeID', 'One To Many', TRUE, TRUE, 1, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = 'e3400892-1304-4518-bf7a-cfd0eee4659e'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('e3400892-1304-4518-bf7a-cfd0eee4659e', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', 'DecidedByPersonID', 'One To Many', TRUE, TRUE, 8, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '26002101-79fe-4882-87a9-42ceea625ce3'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('26002101-79fe-4882-87a9-42ceea625ce3', 'DF98E700-1992-442B-B93E-E47379F2CA52', '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', 'TaskAssignmentID', 'One To Many', TRUE, TRUE, 1, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '533c0196-2fc5-4895-929e-a42be9dcac75'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('533c0196-2fc5-4895-929e-a42be9dcac75', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', 'TaskID', 'One To Many', TRUE, TRUE, 10, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '29dac57c-41b1-4159-ad13-3dcc45a48d87' OR ("EntityID" = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND "Name" = 'Task')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '29dac57c-41b1-4159-ad13-3dcc45a48d87',
        '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decisions"
        100019,
        'Task',
        'Task',
        NULL,
        'TEXT',
        510,
        0,
        0,
        FALSE,
        NULL,
        FALSE,
        FALSE,
        TRUE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '2ede228d-162d-4a86-858e-6ab3606a4096' OR ("EntityID" = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND "Name" = 'Outcome')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '2ede228d-162d-4a86-858e-6ab3606a4096',
        '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decisions"
        100020,
        'Outcome',
        'Outcome',
        NULL,
        'TEXT',
        200,
        0,
        0,
        FALSE,
        NULL,
        FALSE,
        FALSE,
        TRUE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '51c078ed-a99e-4472-8f05-f38fd92262fe' OR ("EntityID" = '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF' AND "Name" = 'DecidedByPerson')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '51c078ed-a99e-4472-8f05-f38fd92262fe',
        '78EF0BE0-1A0B-48D3-BE06-8524E3CD7FDF', -- "Entity": "MJ_BizApps_Tasks": "Task" "Decisions"
        100021,
        'DecidedByPerson',
        'Decided By Person',
        NULL,
        'TEXT',
        402,
        0,
        0,
        TRUE,
        NULL,
        FALSE,
        FALSE,
        TRUE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '4485192e-6dbc-4a4e-9a65-f4bc21a91daa' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'OnRejectAction')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        '4485192e-6dbc-4a4e-9a65-f4bc21a91daa',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100037,
        'OnRejectAction',
        'On Reject Action',
        NULL,
        'TEXT',
        850,
        0,
        0,
        TRUE,
        NULL,
        FALSE,
        FALSE,
        TRUE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'da3ea9e6-160b-48c7-940e-567dcbf04d7a' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'OnCancelAction')
    ) THEN
        INSERT INTO "${mjSchema}"."EntityField"
        (
        "ID",
        "EntityID",
        "Sequence",
        "Name",
        "DisplayName",
        "Description",
        "Type",
        "Length",
        "Precision",
        "Scale",
        "AllowsNull",
        "DefaultValue",
        "AutoIncrement",
        "AllowUpdateAPI",
        "IsVirtual",
        "IsComputed",
        "RelatedEntityID",
        "RelatedEntityFieldName",
        "IsNameField",
        "IncludeInUserSearchAPI",
        "IncludeRelatedEntityNameFieldInBaseView",
        "DefaultInView",
        "IsPrimaryKey",
        "IsUnique",
        "RelatedEntityDisplayType",
        "__mj_CreatedAt",
        "__mj_UpdatedAt"
        )
        VALUES
        (
        'da3ea9e6-160b-48c7-940e-567dcbf04d7a',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100038,
        'OnCancelAction',
        'On Cancel Action',
        NULL,
        'TEXT',
        850,
        0,
        0,
        TRUE,
        NULL,
        FALSE,
        FALSE,
        TRUE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        'Search',
        NOW(),
        NOW()
        );
    END IF;
END $$;


-- ===================== FK & CHECK Constraints =====================


-- Flush any pending deferred trigger events from prior DML so DDL below can proceed.
SET CONSTRAINTS ALL IMMEDIATE;

ALTER TABLE __mj_bizappstasks."TaskActivity"
 ADD CONSTRAINT "CK_TaskActivity_Type" CHECK ("ActivityType" IN (
    'StatusChange', 'AssignmentAdded', 'AssignmentRemoved',
    'DueDateChanged', 'PriorityChanged', 'PercentCompleteChanged',
    'DependencyAdded', 'DependencyRemoved', 'Created', 'Completed',
    'DecisionRecorded'
)) NOT VALID;


-- ===================== Grants =====================

DO $$ BEGIN GRANT SELECT ON __mj_bizappstasks."vwTaskDecisionOutcomes" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Decision Outcomes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
-- Item: Permissions for vwTaskDecisionOutcomes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_bizappstasks."vwTaskDecisionOutcomes" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Decision Outcomes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
-- Item: spCreateTaskDecisionOutcome
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskDecisionOutcome
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spCreateTaskDecisionOutcome" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Decision Outcomes */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spCreateTaskDecisionOutcome" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Decision Outcomes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
-- Item: spUpdateTaskDecisionOutcome
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskDecisionOutcome
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spUpdateTaskDecisionOutcome" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spUpdateTaskDecisionOutcome" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Decision Outcomes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decision Outcomes
-- Item: spDeleteTaskDecisionOutcome
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskDecisionOutcome
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spDeleteTaskDecisionOutcome" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Decision Outcomes */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spDeleteTaskDecisionOutcome" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Index for Foreign Keys for TaskDecision */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decisions
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskID in table TaskDecision;

DO $$ BEGIN GRANT SELECT ON __mj_bizappstasks."vwTaskDecisions" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Decisions */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decisions
-- Item: Permissions for vwTaskDecisions
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_bizappstasks."vwTaskDecisions" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Decisions */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decisions
-- Item: spCreateTaskDecision
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskDecision
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spCreateTaskDecision" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Decisions */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spCreateTaskDecision" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Decisions */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decisions
-- Item: spUpdateTaskDecision
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskDecision
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spUpdateTaskDecision" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spUpdateTaskDecision" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Decisions */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decisions
-- Item: spDeleteTaskDecision
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskDecision
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spDeleteTaskDecision" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Decisions */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spDeleteTaskDecision" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Index for Foreign Keys for TaskType */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Types
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key OnAssignActionID in table TaskType;

DO $$ BEGIN GRANT SELECT ON __mj_bizappstasks."vwTaskTypes" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Types
-- Item: Permissions for vwTaskTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_bizappstasks."vwTaskTypes" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Types
-- Item: spCreateTaskType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskType
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spCreateTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Types */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spCreateTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Types
-- Item: spUpdateTaskType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskType
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spUpdateTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spUpdateTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Types
-- Item: spDeleteTaskType
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskType
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spDeleteTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Types */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_bizappstasks."spDeleteTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* SQL text to delete unneeded entity fields (3 scoped entities) */


-- ===================== Comments =====================

COMMENT ON COLUMN __mj_bizappstasks."TaskDecisionOutcome"."Name" IS 'Human-readable outcome label (e.g. Approved, Rejected, Approved With Conditions).';

COMMENT ON COLUMN __mj_bizappstasks."TaskDecisionOutcome"."Code" IS 'Stable machine code for the outcome, used by orchestration code to map outcome to task status (e.g. Approved, Rejected, ApprovedWithConditions).';

COMMENT ON COLUMN __mj_bizappstasks."TaskDecisionOutcome"."Sequence" IS 'Display ordering for the outcome in decision pickers.';

COMMENT ON COLUMN __mj_bizappstasks."TaskDecisionOutcome"."IsTerminal" IS 'When 1, recording this outcome closes the approval (terminal). When 0, the decision is interim and the task remains open.';

COMMENT ON COLUMN __mj_bizappstasks."TaskDecisionOutcome"."IsActive" IS 'When 0, the outcome is hidden from new decision pickers but preserved on historical decisions.';

COMMENT ON COLUMN __mj_bizappstasks."TaskDecision"."TaskID" IS 'The task this decision was recorded against.';

COMMENT ON COLUMN __mj_bizappstasks."TaskDecision"."OutcomeID" IS 'The decision outcome (FK to TaskDecisionOutcome).';

COMMENT ON COLUMN __mj_bizappstasks."TaskDecision"."DecidedByPersonID" IS 'The Person who made the decision.';

COMMENT ON COLUMN __mj_bizappstasks."TaskDecision"."DecidedAt" IS 'When the decision was recorded.';

COMMENT ON COLUMN __mj_bizappstasks."TaskDecision"."DecisionNotes" IS 'Free-text rationale or conditions attached to the decision.';

COMMENT ON COLUMN __mj_bizappstasks."TaskDecision"."TaskAssignmentID" IS 'Optional link to the specific TaskAssignment this decision belongs to, for per-assignee decisions in multi-approver flows. Null for a task-level decision.';

COMMENT ON COLUMN __mj_bizappstasks."TaskType"."OnRejectActionID" IS 'Action invoked when a task of this type transitions to a rejected decision (post-commit, non-blocking). Used by approval workflows.';

COMMENT ON COLUMN __mj_bizappstasks."TaskType"."OnCancelActionID" IS 'Action invoked when a task of this type transitions to Cancelled (post-commit, non-blocking).';


-- ===================== Other =====================

-- BizAppsTasks: Approval / Decision Model (GitHub issue #8)
-- Additive only (published v1.0.x): new tables, new nullable columns, widened CHECK.
-- No drops/renames, no narrowed types, Task."Status" enum untouched.

/*----------------------------------------------------CODEGEN------------------------------------------*/
/* SQL generated to create new entity MJ_BizApps_Tasks: Task Decision Outcomes */

/* SQL text to insert new entity field */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Decision Outcomes */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Decisions */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Types */
