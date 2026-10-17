-- ============================================================================
-- MemberJunction PostgreSQL Migration
-- Converted from SQL Server using TypeScript conversion pipeline
-- ============================================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Schema
--
-- The schema name is emitted UNQUOTED, so PostgreSQL folds it to lowercase. That is deliberate and
-- self-consistent: everything downstream in a converted migration refers to it unquoted too, so
-- both definition and lookup land on the same folded name.
--
-- DOWNSTREAM NOTE for the build engineer: a PostgreSQL database that was populated by an EARLIER
-- converter — one that emitted a quoted, case-preserved name — already holds that mixed-case
-- schema: for a target named MySchema_Name, the quoted "MySchema_Name". Re-converting against
-- that database creates a SECOND, empty schema myschema_name rather than reusing the existing
-- one, because IF NOT EXISTS compares the folded name and finds no match. The repo's own committed
-- migrations-pg files are unaffected (the only quoted CREATE SCHEMAs there are the four pg_dump
-- baselines, which this path does not produce), so this is an open-app / downstream concern, not
-- one for this repo's Flyway history.
CREATE SCHEMA IF NOT EXISTS __mj_BizAppsTasks;
SET search_path TO __mj_BizAppsTasks, public;

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

-- =============================================================================
-- BizAppsTasks: Priority / OKR Tracking Columns on Task & TaskCheckIn Table
-- Extends Task to support Objectives & Key Results (OKRs) and structured
-- periodic check-ins (manual or Chief of Staff AI-authored).
-- =============================================================================

---------------------------------------------------------------------------
-- 1. Task: Add Priority / OKR & Check-In Rhythm Columns
---------------------------------------------------------------------------
ALTER TABLE __mj_BizAppsTasks."Task"
 ADD COLUMN IF NOT EXISTS "HealthStatus" VARCHAR(20) NULL,
 ADD COLUMN IF NOT EXISTS "ConfidenceScore" INTEGER NULL,
 ADD COLUMN IF NOT EXISTS "BaselineValue" DECIMAL(18, 4) NULL,
 ADD COLUMN IF NOT EXISTS "TargetValue" DECIMAL(18, 4) NULL,
 ADD COLUMN IF NOT EXISTS "CurrentValue" DECIMAL(18, 4) NULL,
 ADD COLUMN IF NOT EXISTS "UnitOfMeasure" VARCHAR(50) NULL,
 ADD COLUMN IF NOT EXISTS "MetricDirection" VARCHAR(20) NULL,
 ADD COLUMN IF NOT EXISTS "RollupWeight" DECIMAL(8, 2) NOT NULL CONSTRAINT "DF_Task_RollupWeight" DEFAULT (1.00),
 ADD COLUMN IF NOT EXISTS "PlanningPeriod" VARCHAR(50) NULL,
 ADD COLUMN IF NOT EXISTS "CheckInCadence" VARCHAR(20) NULL,
 ADD COLUMN IF NOT EXISTS "LastCheckInAt" TIMESTAMPTZ NULL,
 ADD COLUMN IF NOT EXISTS "NextCheckInDueAt" TIMESTAMPTZ NULL;

---------------------------------------------------------------------------
-- 2. TaskCheckIn: Structured periodic progress updates for Tasks / OKRs
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks."TaskCheckIn" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TaskID" UUID NOT NULL,
 "AuthorPersonID" UUID NULL,
 "AuthorUserID" UUID NULL,
 "ReportedByAIAgentID" UUID NULL,
 "CheckInAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 "HealthStatus" VARCHAR(20) NOT NULL DEFAULT 'OnTrack',
 "ConfidenceScore" INTEGER NULL,
 "PreviousValue" DECIMAL(18, 4) NULL,
 "NewValue" DECIMAL(18, 4) NULL,
 "PercentComplete" INTEGER NULL,
 "Summary" TEXT NOT NULL,
 "Blockers" TEXT NULL,
 "NextSteps" TEXT NULL,
 CONSTRAINT "PK_TaskCheckIn" PRIMARY KEY ("ID"),
 CONSTRAINT "FK_TaskCheckIn_Task" FOREIGN KEY ("TaskID") REFERENCES __mj_BizAppsTasks."Task"("ID"),
 CONSTRAINT "FK_TaskCheckIn_AuthorPerson" FOREIGN KEY ("AuthorPersonID") REFERENCES __mj_BizAppsCommon."Person"("ID"),
 CONSTRAINT "FK_TaskCheckIn_AuthorUser" FOREIGN KEY ("AuthorUserID") REFERENCES ${mjSchema}."User"("ID"),
 CONSTRAINT "FK_TaskCheckIn_AIAgent" FOREIGN KEY ("ReportedByAIAgentID") REFERENCES ${mjSchema}."AIAgent"("ID"),
 CONSTRAINT "CK_TaskCheckIn_HealthStatus" CHECK ("HealthStatus" IN ('OnTrack', 'AtRisk', 'OffTrack', 'Completed', 'Paused')),
 CONSTRAINT "CK_TaskCheckIn_ConfidenceScore" CHECK ("ConfidenceScore" IS NULL OR ("ConfidenceScore" >= 0 AND "ConfidenceScore" <= 100)),
 CONSTRAINT "CK_TaskCheckIn_PercentComplete" CHECK ("PercentComplete" IS NULL OR ("PercentComplete" >= 0 AND "PercentComplete" <= 100))
);

ALTER TABLE __mj_BizAppsTasks."TaskCheckIn"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TaskCheckIn */
ALTER TABLE __mj_BizAppsTasks."TaskCheckIn"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskCheckIn_TaskID" ON __mj_BizAppsTasks."TaskCheckIn" ("TaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskCheckIn_AuthorPersonID" ON __mj_BizAppsTasks."TaskCheckIn" ("AuthorPersonID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskCheckIn_AuthorUserID" ON __mj_BizAppsTasks."TaskCheckIn" ("AuthorUserID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskCheckIn_ReportedByAIAgentID" ON __mj_BizAppsTasks."TaskCheckIn" ("ReportedByAIAgentID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_TypeID" ON __mj_BizAppsTasks."Task" ("TypeID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_CategoryID" ON __mj_BizAppsTasks."Task" ("CategoryID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_ParentID" ON __mj_BizAppsTasks."Task" ("ParentID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_CreatedByPersonID" ON __mj_BizAppsTasks."Task" ("CreatedByPersonID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_TaskTypeStatusID" ON __mj_BizAppsTasks."Task" ("TaskTypeStatusID");


-- ===================== Views =====================

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTasksGenerated" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTasksGenerated';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTasksGenerated"
AS SELECT
    t.*,
    "mjBizAppsTasksTaskType_TypeID"."Name" AS "Type",
    "mjBizAppsTasksTaskCategory_CategoryID"."Name" AS "Category",
    "mjBizAppsTasksTask_ParentID"."Name" AS "Parent",
    "mjBizAppsCommonPerson_CreatedByPersonID"."DisplayName" AS "CreatedByPerson",
    "mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID"."Name" AS "TaskTypeStatus"
FROM
    __mj_BizAppsTasks."Task" AS t
INNER JOIN
    __mj_BizAppsTasks."TaskType" AS "mjBizAppsTasksTaskType_TypeID"
  ON
    t."TypeID" = "mjBizAppsTasksTaskType_TypeID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsTasks."TaskCategory" AS "mjBizAppsTasksTaskCategory_CategoryID"
  ON
    t."CategoryID" = "mjBizAppsTasksTaskCategory_CategoryID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_ParentID"
  ON
    t."ParentID" = "mjBizAppsTasksTask_ParentID"."ID"
LEFT OUTER JOIN
    ${mjSchema}_BizAppsCommon."Person" AS "mjBizAppsCommonPerson_CreatedByPersonID"
  ON
    t."CreatedByPersonID" = "mjBizAppsCommonPerson_CreatedByPersonID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsTasks."TaskTypeStatus" AS "mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID"
  ON
    t."TaskTypeStatusID" = "mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskCheckIns" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskCheckIns';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskCheckIns"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "mjBizAppsCommonPerson_AuthorPersonID"."DisplayName" AS "AuthorPerson",
    "MJUser_AuthorUserID"."Name" AS "AuthorUser",
    "MJAIAgent_ReportedByAIAgentID"."Name" AS "ReportedByAIAgent"
FROM
    __mj_BizAppsTasks."TaskCheckIn" AS t
INNER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
LEFT OUTER JOIN
    ${mjSchema}_BizAppsCommon."Person" AS "mjBizAppsCommonPerson_AuthorPersonID"
  ON
    t."AuthorPersonID" = "mjBizAppsCommonPerson_AuthorPersonID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."User" AS "MJUser_AuthorUserID"
  ON
    t."AuthorUserID" = "MJUser_AuthorUserID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."AIAgent" AS "MJAIAgent_ReportedByAIAgentID"
  ON
    t."ReportedByAIAgentID" = "MJAIAgent_ReportedByAIAgentID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTasksGenerated" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTasksGenerated';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTasksGenerated"
AS SELECT
    t.*,
    "mjBizAppsTasksTaskType_TypeID"."Name" AS "Type",
    "mjBizAppsTasksTaskCategory_CategoryID"."Name" AS "Category",
    "mjBizAppsTasksTask_ParentID"."Name" AS "Parent",
    "mjBizAppsCommonPerson_CreatedByPersonID"."DisplayName" AS "CreatedByPerson",
    "mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID"."Name" AS "TaskTypeStatus"
FROM
    __mj_BizAppsTasks."Task" AS t
INNER JOIN
    __mj_BizAppsTasks."TaskType" AS "mjBizAppsTasksTaskType_TypeID"
  ON
    t."TypeID" = "mjBizAppsTasksTaskType_TypeID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsTasks."TaskCategory" AS "mjBizAppsTasksTaskCategory_CategoryID"
  ON
    t."CategoryID" = "mjBizAppsTasksTaskCategory_CategoryID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_ParentID"
  ON
    t."ParentID" = "mjBizAppsTasksTask_ParentID"."ID"
LEFT OUTER JOIN
    ${mjSchema}_BizAppsCommon."Person" AS "mjBizAppsCommonPerson_CreatedByPersonID"
  ON
    t."CreatedByPersonID" = "mjBizAppsCommonPerson_CreatedByPersonID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsTasks."TaskTypeStatus" AS "mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID"
  ON
    t."TaskTypeStatusID" = "mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTasks" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTasks';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTasks"
AS SELECT
    g.*,
    "root_ParentID"."RootID" AS "RootParentID",
    CASE 
        WHEN g."CompletedAt" IS NOT NULL AND g."DueAt" IS NOT NULL THEN 
            CASE WHEN g."CompletedAt" > g."DueAt" THEN 'Breached' ELSE 'Met' END
        ELSE NULL 
    END AS "IsSLABreached",
    CASE 
        WHEN g."StartedAt" IS NOT NULL AND g."DueAt" IS NOT NULL THEN 
            EXTRACT(DAY FROM (g."DueAt"::TIMESTAMPTZ - g."StartedAt"::TIMESTAMPTZ)) 
        WHEN g."__mj_CreatedAt" IS NOT NULL AND g."DueAt" IS NOT NULL THEN 
            EXTRACT(DAY FROM (g."DueAt"::TIMESTAMPTZ - g."__mj_CreatedAt"::TIMESTAMPTZ)) 
        ELSE NULL 
    END AS "LeadDays",
    COALESCE(a."AssignmentsCount", 0) AS "AssignmentsCount",
    COALESCE(c."CommentsCount", 0) AS "CommentsCount"
FROM
    __mj_BizAppsTasks."vwTasksGenerated" AS g
LEFT JOIN LATERAL (SELECT * FROM __mj_BizAppsTasks."fnTaskParentID_GetRootID"(g."ID", g."ParentID")) AS "root_ParentID"
    ON TRUE
LEFT OUTER JOIN (
    SELECT "TaskID", COUNT(*) AS "AssignmentsCount"
    FROM __mj_BizAppsTasks."TaskAssignment"
    GROUP BY "TaskID"
) AS a ON a."TaskID" = g."ID"
LEFT OUTER JOIN (
    SELECT "TaskID", COUNT(*) AS "CommentsCount"
    FROM __mj_BizAppsTasks."TaskComment"
    GROUP BY "TaskID"
) AS c ON c."TaskID" = g."ID"$vsql$;
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

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskCheckIn]
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @AuthorPersonID_Clear bit = 0,
--     @AuthorPersonID UUID = NULL...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskCheckIn]
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @AuthorPersonID_Clear bit = 0,
--     @AuthorPersonID UUID = NULL...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskCheckIn]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskCheckIn]
--     WHERE
--         [ID] = @ID...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTask]
--     @ID UUID = NULL,
--     @Name VARCHAR(255),
--     @Description_Clear bit = 0,
--     @Description TEXT = NULL,
--     @TypeID uniquei...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTask]
--     @ID UUID,
--     @Name VARCHAR(255) = NULL,
--     @Description_Clear bit = 0,
--     @Description TEXT = NULL,
--     @TypeID uniquei...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTask]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[Task]
--     WHERE
--         [ID] = @ID
-- 
-- 
--     -- Chec...


-- ===================== Triggers =====================

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTaskCheckIn
-- ON __mj_BizAppsTasks."TaskCheckIn"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskCheckIn"
--     SET
    

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTask
-- ON __mj_BizAppsTasks."Task"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."Task"
--     SET
--         __mj_UpdatedAt = 


-- ===================== Data (INSERT/UPDATE/DELETE) =====================

INSERT INTO ${mjSchema}."Entity" (
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
         "AllowCaching",
         "TrackRecordChanges",
         "AuditRecordAccess",
         "AuditViewRuns",
         "AllowAllRowsAPI",
         "AllowCreateAPI",
         "AllowUpdateAPI",
         "AllowDeleteAPI",
         "UserViewMaxRows"
         , "__mj_CreatedAt"
         , "__mj_UpdatedAt"
      )
      VALUES (
         '360ce0db-7207-4d3c-a35f-2f45c22a5399',
         'MJ_BizApps_Tasks: Task Check Ins',
         'Task Check Ins',
         'Structured periodic progress check-ins for tasks, priorities, and OKRs, authored by users or AI agents such as Chief of Staff.',
         NULL,
         'TaskCheckIn',
         'vwTaskCheckIns',
         '__mj_BizAppsTasks',
         TRUE,
         TRUE,
         FALSE,
         TRUE,
         FALSE,
         FALSE,
         FALSE,
         TRUE,
         TRUE,
         TRUE,
         1000
         , NOW()
         , NOW()
      );

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Check Ins to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO ${mjSchema}."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '360ce0db-7207-4d3c-a35f-2f45c22a5399', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM ${mjSchema}."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Check Ins for role UI */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS UUID), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 0, 0, 0, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS UUID) AND "RoleID" = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Check Ins for role Developer */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS UUID), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS UUID) AND "RoleID" = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Check Ins for role Integration */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS UUID), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS UUID) AND "RoleID" = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL text to update existing entities from schema */

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks."TaskCheckIn" */
UPDATE __mj_BizAppsTasks."TaskCheckIn" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.TaskCheckIn */
ALTER TABLE __mj_BizAppsTasks."TaskCheckIn" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks."TaskCheckIn" */
UPDATE __mj_BizAppsTasks."TaskCheckIn" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TaskCheckIn */
ALTER TABLE __mj_BizAppsTasks."TaskCheckIn" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'b4b892af-baa4-4ecd-a99b-1a34bbb21723' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'ID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        'b4b892af-baa4-4ecd-a99b-1a34bbb21723',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
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
        FALSE,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '228c3ad3-a70a-44ab-8d35-49acd8450741' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'TaskID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '228c3ad3-a70a-44ab-8d35-49acd8450741',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
        'TaskID',
        'Task ID',
        'The task, priority objective, or key result this check-in updates.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'c7db972b-3cb3-48ab-81ef-ac4f4d9801a1' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'AuthorPersonID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        'c7db972b-3cb3-48ab-81ef-ac4f4d9801a1',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
        'AuthorPersonID',
        'Author Person ID',
        'Optional Person record who authored or approved the check-in.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '8b69c4d1-c536-4063-b775-fbee891cca7a' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'AuthorUserID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '8b69c4d1-c536-4063-b775-fbee891cca7a',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
        'AuthorUserID',
        'Author User ID',
        'Optional MemberJunction User who authored or submitted the check-in.',
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
        'E1238F34-2837-EF11-86D4-6045BDEE16E6',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '8d0d30ae-8449-4921-b155-3eb275e824d1' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'ReportedByAIAgentID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '8d0d30ae-8449-4921-b155-3eb275e824d1',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
        'ReportedByAIAgentID',
        'Reported By AI Agent ID',
        'Optional AI Agent (e.g., Chief of Staff) that synthesized and recorded this check-in.',
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
        'CDB135CC-6D3C-480B-90AE-25B7805F82C1',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '9637e429-90e1-4016-9be7-635b0c446dfc' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'CheckInAt')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '9637e429-90e1-4016-9be7-635b0c446dfc',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
        'CheckInAt',
        'Check In At',
        'Timestamp when the check-in occurred.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '7da8b600-d924-4822-b80b-b273cb41feab' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'HealthStatus')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '7da8b600-d924-4822-b80b-b273cb41feab',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
        'HealthStatus',
        'Health Status',
        'Health status reported at check-in: OnTrack, AtRisk, OffTrack, Completed, or Paused.',
        'TEXT',
        40,
        0,
        0,
        FALSE,
        'OnTrack',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '9fc7a284-c3df-4b94-910d-c2460dbde8ab' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'ConfidenceScore')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '9fc7a284-c3df-4b94-910d-c2460dbde8ab',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
        'ConfidenceScore',
        'Confidence Score',
        'Confidence score (0-100) reported at the time of check-in.',
        'INTEGER',
        4,
        10,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '6df3ec7b-6920-4a83-a2f0-afc43a64a91b' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'PreviousValue')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '6df3ec7b-6920-4a83-a2f0-afc43a64a91b',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
        'PreviousValue',
        'Previous Value',
        'Metric value prior to this check-in.',
        'decimal',
        9,
        18,
        4,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '3db75504-f5f0-4f85-8bbf-5e8ff7e6932b' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'NewValue')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '3db75504-f5f0-4f85-8bbf-5e8ff7e6932b',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
        'NewValue',
        'New Value',
        'Updated metric value reported in this check-in.',
        'decimal',
        9,
        18,
        4,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'd4261555-e5e9-4b47-9c76-c212559758de' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'PercentComplete')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        'd4261555-e5e9-4b47-9c76-c212559758de',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
        'PercentComplete',
        'Percent Complete',
        'Percent complete (0-100) reported or computed in this check-in.',
        'INTEGER',
        4,
        10,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '5bd1ecac-1336-4545-82b7-54f7d773c10c' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'Summary')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '5bd1ecac-1336-4545-82b7-54f7d773c10c',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
        'Summary',
        'Summary',
        'Narrative summary of accomplishments and status since the last check-in.',
        'TEXT',
        -1,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '05563452-fab1-4bbc-81c1-4c0949f62e87' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'Blockers')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '05563452-fab1-4bbc-81c1-4c0949f62e87',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
        'Blockers',
        'Blockers',
        'Risks, impediments, or cross-team blockers surfaced during the check-in.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '393f9b09-36a3-4bc2-9b79-8dd6218d265d' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'NextSteps')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '393f9b09-36a3-4bc2-9b79-8dd6218d265d',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
        'NextSteps',
        'Next Steps',
        'Planned next steps and commitments before the next check-in.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '515acc10-2c6a-4cc7-a720-0fc2d8427ef0' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = '__mj_CreatedAt')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '515acc10-2c6a-4cc7-a720-0fc2d8427ef0',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'd6ec2e84-5bf9-495a-a614-6221af56e9ba' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = '__mj_UpdatedAt')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        'd6ec2e84-5bf9-495a-a614-6221af56e9ba',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '7532fdf8-d979-441e-9dad-8d3f9e55a84e' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'HealthStatus')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '7532fdf8-d979-441e-9dad-8d3f9e55a84e',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'HealthStatus',
        'Health Status',
        'Qualitative health status for priority/OKR tracking: OnTrack, AtRisk, OffTrack, Completed, or Paused.',
        'TEXT',
        40,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'a5ca80f8-1ab4-43df-98ec-926d88c95da0' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'ConfidenceScore')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        'a5ca80f8-1ab4-43df-98ec-926d88c95da0',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'ConfidenceScore',
        'Confidence Score',
        'Owner confidence score (0-100) that this task, key result, or objective will hit its target on time.',
        'INTEGER',
        4,
        10,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '07437566-1823-4882-b196-b4473a824190' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'BaselineValue')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '07437566-1823-4882-b196-b4473a824190',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'BaselineValue',
        'Baseline Value',
        'Starting baseline value for measurable key results or quantitative deliverables.',
        'decimal',
        9,
        18,
        4,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '346dcca6-8dd6-40f4-ad44-0adae04afa36' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'TargetValue')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '346dcca6-8dd6-40f4-ad44-0adae04afa36',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'TargetValue',
        'Target Value',
        'Target goal value for measurable key results or quantitative deliverables.',
        'decimal',
        9,
        18,
        4,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'eeeb991a-70c8-4ae1-a1bc-859047d74135' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'CurrentValue')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        'eeeb991a-70c8-4ae1-a1bc-859047d74135',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'CurrentValue',
        'Current Value',
        'Latest actual measured value for this key result or deliverable, updated automatically by TaskCheckIn records.',
        'decimal',
        9,
        18,
        4,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'af223c6d-6f70-4c13-8bf6-c61aa27173f8' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'UnitOfMeasure')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        'af223c6d-6f70-4c13-8bf6-c61aa27173f8',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'UnitOfMeasure',
        'Unit Of Measure',
        'Unit of measure for BaselineValue, TargetValue, and CurrentValue (e.g., %, USD, Days, Customers, NPS).',
        'TEXT',
        100,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'defbd4e1-c3c0-48d4-b297-b4c1ebe75a56' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'MetricDirection')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        'defbd4e1-c3c0-48d4-b297-b4c1ebe75a56',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'MetricDirection',
        'Metric Direction',
        'Direction of improvement for quantitative metrics: Increase, Decrease, or Maintain.',
        'TEXT',
        40,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '65e2f993-2fe6-4889-9d58-e57ecfbfc82a' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'RollupWeight')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '65e2f993-2fe6-4889-9d58-e57ecfbfc82a',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'RollupWeight',
        'Rollup Weight',
        'Relative weight (default 1.00) when rolling up child task or key result progress into a parent objective.',
        'decimal',
        5,
        8,
        2,
        FALSE,
        '(1.00)',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'ab060b49-73e6-4925-a734-772a6e615a1e' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'PlanningPeriod')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        'ab060b49-73e6-4925-a734-772a6e615a1e',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'PlanningPeriod',
        'Planning Period',
        'Planning horizon or OKR cycle identifier (e.g., 2026-Q4, FY2027, H1-2026).',
        'TEXT',
        100,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'cbbe3a1d-b115-4906-af54-42adce9a5973' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'CheckInCadence')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        'cbbe3a1d-b115-4906-af54-42adce9a5973',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'CheckInCadence',
        'Check In Cadence',
        'Expected progress check-in frequency: Daily, Weekly, BiWeekly, Monthly, Quarterly, or None.',
        'TEXT',
        40,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'df95636f-e402-40e1-a53c-7abb34996f9e' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'LastCheckInAt')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        'df95636f-e402-40e1-a53c-7abb34996f9e',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'LastCheckInAt',
        'Last Check In At',
        'Timestamp when the most recent TaskCheckIn was recorded for this task.',
        'TIMESTAMPTZ',
        10,
        34,
        7,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '3828d96c-44e3-40c8-a907-b7a916a829d6' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'NextCheckInDueAt')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '3828d96c-44e3-40c8-a907-b7a916a829d6',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'NextCheckInDueAt',
        'Next Check In Due At',
        'Timestamp when the next progress check-in is due based on CheckInCadence; used by Chief of Staff to nudge owners.',
        'TIMESTAMPTZ',
        10,
        34,
        7,
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

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('2d1da61d-caae-490a-b3c5-9b9eeea3e98b', '7532FDF8-D979-441E-9DAD-8D3F9E55A84E', 1, 'AtRisk', 'AtRisk', NOW(), NOW());

/* SQL text to insert entity field value with ID 0e381e48-b41d-49dc-8c77-2a3e2412f240 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('0e381e48-b41d-49dc-8c77-2a3e2412f240', '7532FDF8-D979-441E-9DAD-8D3F9E55A84E', 2, 'Completed', 'Completed', NOW(), NOW());

/* SQL text to insert entity field value with ID a35bd3a6-b328-4b8b-87a4-1d7b2f68588d */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('a35bd3a6-b328-4b8b-87a4-1d7b2f68588d', '7532FDF8-D979-441E-9DAD-8D3F9E55A84E', 3, 'OffTrack', 'OffTrack', NOW(), NOW());

/* SQL text to insert entity field value with ID 78bd5be3-62e9-4254-8119-d5bdf1025cf3 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('78bd5be3-62e9-4254-8119-d5bdf1025cf3', '7532FDF8-D979-441E-9DAD-8D3F9E55A84E', 4, 'OnTrack', 'OnTrack', NOW(), NOW());

/* SQL text to insert entity field value with ID f3b28978-4d13-43b7-92cf-9c50cdb97c82 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('f3b28978-4d13-43b7-92cf-9c50cdb97c82', '7532FDF8-D979-441E-9DAD-8D3F9E55A84E', 5, 'Paused', 'Paused', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 7532FDF8-D979-441E-9DAD-8D3F9E55A84E */

UPDATE ${mjSchema}."EntityField" SET "ValueListType"='List' WHERE "ID"='7532FDF8-D979-441E-9DAD-8D3F9E55A84E';

/* SQL text to insert entity field value with ID 71809b6d-bfff-494a-a139-bf7569cffbe6 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('71809b6d-bfff-494a-a139-bf7569cffbe6', 'DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56', 1, 'Decrease', 'Decrease', NOW(), NOW());

/* SQL text to insert entity field value with ID f3e5ad4a-7f3a-40bc-86e8-eb996023d911 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('f3e5ad4a-7f3a-40bc-86e8-eb996023d911', 'DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56', 2, 'Increase', 'Increase', NOW(), NOW());

/* SQL text to insert entity field value with ID ef71a1bc-8503-4807-85c6-4236a4dd4935 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('ef71a1bc-8503-4807-85c6-4236a4dd4935', 'DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56', 3, 'Maintain', 'Maintain', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56 */

UPDATE ${mjSchema}."EntityField" SET "ValueListType"='List' WHERE "ID"='DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56';

/* SQL text to insert entity field value with ID e73100ea-6879-482c-9c65-8e395393e188 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('e73100ea-6879-482c-9c65-8e395393e188', 'CBBE3A1D-B115-4906-AF54-42ADCE9A5973', 1, 'BiWeekly', 'BiWeekly', NOW(), NOW());

/* SQL text to insert entity field value with ID 98aa8d90-4fa6-4c4d-9b8e-89d51989ab37 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('98aa8d90-4fa6-4c4d-9b8e-89d51989ab37', 'CBBE3A1D-B115-4906-AF54-42ADCE9A5973', 2, 'Daily', 'Daily', NOW(), NOW());

/* SQL text to insert entity field value with ID a48f70e4-69ba-4206-b424-9dee180a251e */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('a48f70e4-69ba-4206-b424-9dee180a251e', 'CBBE3A1D-B115-4906-AF54-42ADCE9A5973', 3, 'Monthly', 'Monthly', NOW(), NOW());

/* SQL text to insert entity field value with ID e092392b-f130-4856-abe2-3d060e590282 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('e092392b-f130-4856-abe2-3d060e590282', 'CBBE3A1D-B115-4906-AF54-42ADCE9A5973', 4, 'None', 'None', NOW(), NOW());

/* SQL text to insert entity field value with ID 0e6a25c1-3213-4dae-9686-f8d688af2102 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('0e6a25c1-3213-4dae-9686-f8d688af2102', 'CBBE3A1D-B115-4906-AF54-42ADCE9A5973', 5, 'Quarterly', 'Quarterly', NOW(), NOW());

/* SQL text to insert entity field value with ID 50d54b01-1df3-4d74-bd73-438708ef0548 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('50d54b01-1df3-4d74-bd73-438708ef0548', 'CBBE3A1D-B115-4906-AF54-42ADCE9A5973', 6, 'Weekly', 'Weekly', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID CBBE3A1D-B115-4906-AF54-42ADCE9A5973 */

UPDATE ${mjSchema}."EntityField" SET "ValueListType"='List' WHERE "ID"='CBBE3A1D-B115-4906-AF54-42ADCE9A5973';

/* SQL text to insert entity field value with ID 0509c923-75c4-422c-a0b0-a45c5977d773 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('0509c923-75c4-422c-a0b0-a45c5977d773', '7DA8B600-D924-4822-B80B-B273CB41FEAB', 1, 'AtRisk', 'AtRisk', NOW(), NOW());

/* SQL text to insert entity field value with ID 3634dd1f-e2b1-4d25-aa82-5eddf33fb266 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('3634dd1f-e2b1-4d25-aa82-5eddf33fb266', '7DA8B600-D924-4822-B80B-B273CB41FEAB', 2, 'Completed', 'Completed', NOW(), NOW());

/* SQL text to insert entity field value with ID f0595906-74aa-4efd-83e9-c7297878277b */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('f0595906-74aa-4efd-83e9-c7297878277b', '7DA8B600-D924-4822-B80B-B273CB41FEAB', 3, 'OffTrack', 'OffTrack', NOW(), NOW());

/* SQL text to insert entity field value with ID 71da79a8-c0ed-4fc5-b9b1-1166a4a038c9 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('71da79a8-c0ed-4fc5-b9b1-1166a4a038c9', '7DA8B600-D924-4822-B80B-B273CB41FEAB', 4, 'OnTrack', 'OnTrack', NOW(), NOW());

/* SQL text to insert entity field value with ID 7ec8681c-c3c2-468d-925e-27293a06a4bd */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('7ec8681c-c3c2-468d-925e-27293a06a4bd', '7DA8B600-D924-4822-B80B-B273CB41FEAB', 5, 'Paused', 'Paused', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 7DA8B600-D924-4822-B80B-B273CB41FEAB */

UPDATE ${mjSchema}."EntityField" SET "ValueListType"='List' WHERE "ID"='7DA8B600-D924-4822-B80B-B273CB41FEAB';

/* Deterministic search-flag hygiene — clear AllowUserSearchAPI */

UPDATE ${mjSchema}."Entity"
         SET "AllowUserSearchAPI" = FALSE
         WHERE "ID" IN (
            SELECT e."ID"
            FROM ${mjSchema}."Entity" e
            WHERE e."AllowUserSearchAPI" = TRUE
              AND e."AutoUpdateAllowUserSearchAPI" = TRUE
              AND e."VirtualEntity" = FALSE
              AND COALESCE(e."FullTextSearchEnabled", 0) = 0
              AND e."SchemaName" NOT IN ('${mjSchema}','${mjSchema}_BizAppsCommon','${mjSchema}_BizAppsContactCenter','${mjSchema}_BizAppsIssues','sys')
              AND NOT EXISTS (
               SELECT 1 FROM ${mjSchema}."EntityField" f2
               WHERE f2."EntityID" = e."ID"
                 AND f2."IncludeInUserSearchAPI" = TRUE
            )
         );


/* Create Entity Relationship: MJ: AI Agents -> MJ_BizApps_Tasks: Task Check Ins (One To Many via ReportedByAIAgentID) */

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '973f7e5e-ab65-4858-b1f3-fc2c612dc1c7'
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('973f7e5e-ab65-4858-b1f3-fc2c612dc1c7', 'CDB135CC-6D3C-480B-90AE-25B7805F82C1', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'ReportedByAIAgentID', 'One To Many', TRUE, TRUE, 47, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '4d8b4b49-872a-4806-a86d-ba9c6eb69b86'
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('4d8b4b49-872a-4806-a86d-ba9c6eb69b86', 'E1238F34-2837-EF11-86D4-6045BDEE16E6', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'AuthorUserID', 'One To Many', TRUE, TRUE, 128, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = 'e58a89a6-4df2-4216-bfe3-f52b32f7c381'
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('e58a89a6-4df2-4216-bfe3-f52b32f7c381', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'AuthorPersonID', 'One To Many', TRUE, TRUE, 16, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '703bbb06-9361-4b9b-bda7-5bb908f8415f'
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('703bbb06-9361-4b9b-bda7-5bb908f8415f', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'TaskID', 'One To Many', TRUE, TRUE, 11, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'f063969d-25e5-4e0d-95a6-94a16b756582' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'Task')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        'f063969d-25e5-4e0d-95a6-94a16b756582',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'f5f32716-4215-46f5-a128-cb8b9353656a' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'AuthorPerson')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        'f5f32716-4215-46f5-a128-cb8b9353656a',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
        'AuthorPerson',
        'Author Person',
        NULL,
        'TEXT',
        500,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'a0c840e8-ff54-430c-b3ed-8224e9517af5' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'AuthorUser')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        'a0c840e8-ff54-430c-b3ed-8224e9517af5',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
        'AuthorUser',
        'Author User',
        NULL,
        'TEXT',
        200,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '25f2a091-b01c-49a0-a5e2-b2f4036b27e6' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'ReportedByAIAgent')
    ) THEN
        INSERT INTO ${mjSchema}."EntityField"
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
        '25f2a091-b01c-49a0-a5e2-b2f4036b27e6',
        '360CE0DB-7207-4D3C-A35F-2F45C22A5399', -- "Entity": "MJ_BizApps_Tasks": "Task" Check "Ins"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'),
        'ReportedByAIAgent',
        'Reported By AI Agent',
        NULL,
        'TEXT',
        510,
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

UPDATE ${mjSchema}."EntityField"
               SET "DefaultInView" = TRUE
               WHERE "ID" = '9637E429-90E1-4016-9BE7-635B0C446DFC'
               AND "AutoUpdateDefaultInView" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "DefaultInView" = TRUE
               WHERE "ID" = '7DA8B600-D924-4822-B80B-B273CB41FEAB'
               AND "AutoUpdateDefaultInView" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "DefaultInView" = TRUE
               WHERE "ID" = 'D4261555-E5E9-4B47-9C76-C212559758DE'
               AND "AutoUpdateDefaultInView" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "DefaultInView" = TRUE
               WHERE "ID" = 'F063969D-25E5-4E0D-95A6-94A16B756582'
               AND "AutoUpdateDefaultInView" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "DefaultInView" = TRUE
               WHERE "ID" = 'A0C840E8-FF54-430C-B3ED-8224E9517AF5'
               AND "AutoUpdateDefaultInView" = TRUE;

/* Set field properties for entity */

UPDATE ${mjSchema}."EntityField"
               SET "DefaultInView" = TRUE
               WHERE "ID" = '7532FDF8-D979-441E-9DAD-8D3F9E55A84E'
               AND "AutoUpdateDefaultInView" = TRUE;

/* Set categories for 20 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.ID

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'System Metadata',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'B4B892AF-BAA4-4ECD-A99B-1A34BBB21723';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.TaskID

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Check-In Details',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Task'
WHERE 
   "ID" = '228C3AD3-A70A-44AB-8D35-49ACD8450741';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.Task

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Check-In Details',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Task Name'
WHERE 
   "ID" = 'F063969D-25E5-4E0D-95A6-94A16B756582';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.CheckInAt

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Check-In Details',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Check-In At'
WHERE 
   "ID" = '9637E429-90E1-4016-9BE7-635B0C446DFC';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.HealthStatus

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Status and Metrics',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '7DA8B600-D924-4822-B80B-B273CB41FEAB';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.ConfidenceScore

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Status and Metrics',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '9FC7A284-C3DF-4B94-910D-C2460DBDE8AB';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.PreviousValue

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Status and Metrics',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '6DF3EC7B-6920-4A83-A2F0-AFC43A64A91B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.NewValue

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Status and Metrics',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '3DB75504-F5F0-4F85-8BBF-5E8FF7E6932B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.PercentComplete

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Status and Metrics',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'D4261555-E5E9-4B47-9C76-C212559758DE';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.Summary

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Progress Narrative',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '5BD1ECAC-1336-4545-82B7-54F7D773C10C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.Blockers

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Progress Narrative',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '05563452-FAB1-4BBC-81C1-4C0949F62E87';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.NextSteps

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Progress Narrative',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '393F9B09-36A3-4BC2-9B79-8DD6218D265D';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.AuthorPersonID

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Authorship and Agents',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Author Person'
WHERE 
   "ID" = 'C7DB972B-3CB3-48AB-81EF-AC4F4D9801A1';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.AuthorPerson

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Authorship and Agents',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Author Person Name'
WHERE 
   "ID" = 'F5F32716-4215-46F5-A128-CB8B9353656A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.AuthorUserID

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Authorship and Agents',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Author User'
WHERE 
   "ID" = '8B69C4D1-C536-4063-B775-FBEE891CCA7A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.AuthorUser

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Authorship and Agents',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Author User Name'
WHERE 
   "ID" = 'A0C840E8-FF54-430C-B3ED-8224E9517AF5';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.ReportedByAIAgentID

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Authorship and Agents',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Reported By AI Agent'
WHERE 
   "ID" = '8D0D30AE-8449-4921-B155-3EB275E824D1';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.ReportedByAIAgent

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Authorship and Agents',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Reported By AI Agent Name'
WHERE 
   "ID" = '25F2A091-B01C-49A0-A5E2-B2F4036B27E6';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.__mj_CreatedAt

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'System Metadata',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '515ACC10-2C6A-4CC7-A720-0FC2D8427EF0';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Check Ins.__mj_UpdatedAt

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'System Metadata',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'D6EC2E84-5BF9-495A-A614-6221AF56E9BA';

/* Set entity icon to fa fa-tasks */

UPDATE ${mjSchema}."Entity"
               SET "Icon" = 'fa fa-tasks', "__mj_UpdatedAt" = NOW()
               WHERE "ID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399';

/* Insert FieldCategoryInfo setting for entity */

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntitySetting" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'FieldCategoryInfo'
    ) THEN
        INSERT INTO ${mjSchema}."EntitySetting" ("ID", "EntityID", "Name", "Value", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('202ee568-9da4-5430-8ab5-d84859643fd9', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'FieldCategoryInfo', '{
        "Authorship and Agents": {
        "description": "Persons, users, or AI agents responsible for the check-in",
        "icon": "fa fa-user-shield"
        },
        "Check-In Details": {
        "description": "Core check-in scheduling and task association details",
        "icon": "fa fa-calendar-check"
        },
        "Progress Narrative": {
        "description": "Narrative summaries, blockers, and planned next steps",
        "icon": "fa fa-align-left"
        },
        "Status and Metrics": {
        "description": "Health status, metrics, scores, and completion percentage",
        "icon": "fa fa-chart-line"
        },
        "System Metadata": {
        "description": "System-managed audit and tracking fields",
        "icon": "fa fa-cog"
        }
        }', NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntitySetting" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'FieldCategoryIcons'
    ) THEN
        INSERT INTO ${mjSchema}."EntitySetting" ("ID", "EntityID", "Name", "Value", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('8028c881-e7c6-5b67-bb21-7ae6ed9e5390', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'FieldCategoryIcons', '{
        "Authorship and Agents": "fa fa-user-shield",
        "Check-In Details": "fa fa-calendar-check",
        "Progress Narrative": "fa fa-align-left",
        "Status and Metrics": "fa fa-chart-line",
        "System Metadata": "fa fa-cog"
        }', NOW(), NOW());
    END IF;
END $$;

UPDATE ${mjSchema}."ApplicationEntity"
         SET "DefaultForNewUser" = TRUE, "__mj_UpdatedAt" = NOW()
         WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399';

/* Set categories for 17 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.HealthStatus

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Performance and Metrics',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '7532FDF8-D979-441E-9DAD-8D3F9E55A84E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.ConfidenceScore

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Performance and Metrics',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'A5CA80F8-1AB4-43DF-98EC-926D88C95DA0';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.BaselineValue

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Performance and Metrics',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '07437566-1823-4882-B196-B4473A824190';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.TargetValue

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Performance and Metrics',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '346DCCA6-8DD6-40F4-AD44-0ADAE04AFA36';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CurrentValue

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Performance and Metrics',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'EEEB991A-70C8-4AE1-A1BC-859047D74135';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.UnitOfMeasure

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Performance and Metrics',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Unit of Measure'
WHERE 
   "ID" = 'AF223C6D-6F70-4C13-8BF6-C61AA27173F8';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.MetricDirection

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Performance and Metrics',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.RollupWeight

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Performance and Metrics',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '65E2F993-2FE6-4889-9D58-E57ECFBFC82A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.PlanningPeriod

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Performance and Metrics',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'AB060B49-73E6-4925-A734-772A6E615A1E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CheckInCadence

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Performance and Metrics',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Check-In Cadence'
WHERE 
   "ID" = 'CBBE3A1D-B115-4906-AF54-42ADCE9A5973';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.LastCheckInAt

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Performance and Metrics',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Last Check-In At'
WHERE 
   "ID" = 'DF95636F-E402-40E1-A53C-7ABB34996F9E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.NextCheckInDueAt

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Performance and Metrics',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Next Check-In Due At'
WHERE 
   "ID" = '3828D96C-44E3-40C8-A907-B7A916A829D6';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.RootParentID

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Task Details'
WHERE 
   "ID" = '3205C212-1737-4748-B232-3A64ABD3C93C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.IsSLABreached

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Predictive SLA Metrics',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'E7737A78-1C54-4766-929C-BFE8DDF0555C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.LeadDays

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Timeline and Progress',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '35141732-5D6A-459A-A2FA-76808F95160B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.AssignmentsCount

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Task Details',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'AAD50345-DB1B-4BC8-8515-979137C33382';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CommentsCount

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Task Details',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '45355317-A1AB-468F-8901-4564B03CCC4B';

/* Update FieldCategoryInfo setting for entity */

UPDATE ${mjSchema}."EntitySetting"
                  SET "Value" = '{
  "Performance and Metrics": {
    "description": "Metrics, OKR tracking values, check-in schedules, and performance indicators",
    "icon": "fa fa-chart-line"
  }
}', "__mj_UpdatedAt" = NOW()
                  WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'FieldCategoryInfo';

/* Update FieldCategoryIcons setting (legacy) */

UPDATE ${mjSchema}."EntitySetting"
                  SET "Value" = '{
  "Performance and Metrics": "fa fa-chart-line"
}', "__mj_UpdatedAt" = NOW()
                  WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'FieldCategoryIcons';

/* Refresh custom base views for modified entities so schema changes are picked up */

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = '9FC7A284-C3DF-4B94-910D-C2460DBDE8AB'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('6e37cf69-0268-4f97-9f4a-823f07a2fc16', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([ConfidenceScore] IS NULL OR [ConfidenceScore]>=(0) AND [ConfidenceScore]<=(100))', 'public ValidateConfidenceScoreRange(result: ValidationResult) {
        if (this.ConfidenceScore != null && (this.ConfidenceScore < 0 || this.ConfidenceScore > 100)) {
        result.Errors.push(new ValidationErrorInfo(
        "ConfidenceScore",
        "Confidence score must be between 0 and 100.",
        this.ConfidenceScore,
        ValidationErrorType.Failure
        ));
        }
        }', 'Confidence score must be between 0 and 100 if specified.', 'ValidateConfidenceScoreRange', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', '9FC7A284-C3DF-4B94-910D-C2460DBDE8AB');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = 'D4261555-E5E9-4B47-9C76-C212559758DE'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('864fe187-2b76-44ef-b2e4-15260da0057c', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([PercentComplete] IS NULL OR [PercentComplete]>=(0) AND [PercentComplete]<=(100))', 'public ValidatePercentCompleteRange(result: ValidationResult) {
        if (this.PercentComplete != null && (this.PercentComplete < 0 || this.PercentComplete > 100)) {
        result.Errors.push(new ValidationErrorInfo(
        "PercentComplete",
        "Percent complete must be between 0 and 100.",
        this.PercentComplete,
        ValidationErrorType.Failure
        ));
        }
        }', 'Percent complete must be between 0 and 100 when provided.', 'ValidatePercentCompleteRange', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', 'D4261555-E5E9-4B47-9C76-C212559758DE');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND "Name" = 'ValidateTaskIDNotEqualToDependsOnTaskID'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('39c20a7a-d4bd-4ce7-ba0b-741e9f9d06d0', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([TaskID]<>[DependsOnTaskID])', 'public ValidateTaskIDNotEqualToDependsOnTaskID(result: ValidationResult) {
        if (this.TaskID != null && this.DependsOnTaskID != null && this.TaskID === this.DependsOnTaskID) {
        result.Errors.push(new ValidationErrorInfo(
        "DependsOnTaskID",
        "A task cannot depend on itself. TaskID and DependsOnTaskID must be different.",
        this.DependsOnTaskID,
        ValidationErrorType.Failure
        ));
        }
        }', 'A task cannot depend on itself.', 'ValidateTaskIDNotEqualToDependsOnTaskID', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '0662FC0F-3F2B-49C9-9BE8-5B59E036044A');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND "Name" = 'ValidateItemIDNotEqualToDependsOnItemID'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('f4fb8e09-705e-4390-837f-bfe1b2e7706a', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([ItemID]<>[DependsOnItemID])', 'public ValidateItemIDNotEqualToDependsOnItemID(result: ValidationResult) {
        if (this.ItemID != null && this.DependsOnItemID != null && this.ItemID === this.DependsOnItemID) {
        result.Errors.push(new ValidationErrorInfo(
        "DependsOnItemID",
        "An item cannot depend on itself. ItemID and DependsOnItemID must be different.",
        this.DependsOnItemID,
        ValidationErrorType.Failure
        ));
        }
        }', 'An item cannot depend on itself, preventing circular self-dependencies.', 'ValidateItemIDNotEqualToDependsOnItemID', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '8A30F14C-26FF-476E-8CA1-B10EAD29A428');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = 'A5CA80F8-1AB4-43DF-98EC-926D88C95DA0'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('daff3ce5-14fe-40d1-89b0-5caed136e3eb', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([ConfidenceScore] IS NULL OR [ConfidenceScore]>=(0) AND [ConfidenceScore]<=(100))', 'public ValidateConfidenceScoreRange(result: ValidationResult) {
        if (this.ConfidenceScore != null && (this.ConfidenceScore < 0 || this.ConfidenceScore > 100)) {
        result.Errors.push(new ValidationErrorInfo(
        "ConfidenceScore",
        "Confidence score must be between 0 and 100.",
        this.ConfidenceScore,
        ValidationErrorType.Failure
        ));
        }
        }', 'Confidence score must be between 0 and 100 if specified.', 'ValidateConfidenceScoreRange', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', 'A5CA80F8-1AB4-43DF-98EC-926D88C95DA0');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = '5812F201-256C-47AC-AEEB-3402FD1E9846'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('d0b312be-954c-4fe0-8fb9-490cf1f02ebd', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([PercentComplete]>=(0) AND [PercentComplete]<=(100))', 'public ValidatePercentCompleteRange(result: ValidationResult) {
        if (this.PercentComplete < 0 || this.PercentComplete > 100) {
        result.Errors.push(new ValidationErrorInfo(
        "PercentComplete",
        "Percent complete must be between 0 and 100.",
        this.PercentComplete,
        ValidationErrorType.Failure
        ));
        }
        }', 'Percent complete must be a valid percentage between 0 and 100', 'ValidatePercentCompleteRange', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', '5812F201-256C-47AC-AEEB-3402FD1E9846');
    END IF;
END $$;


-- ===================== FK & CHECK Constraints =====================


-- Flush any pending deferred trigger events from prior DML so DDL below can proceed.
SET CONSTRAINTS ALL IMMEDIATE;

ALTER TABLE __mj_BizAppsTasks."Task"
 ADD CONSTRAINT "CK_Task_HealthStatus"
        CHECK ("HealthStatus" IS NULL OR "HealthStatus" IN ('OnTrack', 'AtRisk', 'OffTrack', 'Completed', 'Paused')) NOT VALID,
 ADD CONSTRAINT "CK_Task_ConfidenceScore"
        CHECK ("ConfidenceScore" IS NULL OR ("ConfidenceScore" >= 0 AND "ConfidenceScore" <= 100)) NOT VALID,
 ADD CONSTRAINT "CK_Task_MetricDirection"
        CHECK ("MetricDirection" IS NULL OR "MetricDirection" IN ('Increase', 'Decrease', 'Maintain')) NOT VALID,
 ADD CONSTRAINT "CK_Task_CheckInCadence"
        CHECK ("CheckInCadence" IS NULL OR "CheckInCadence" IN ('Daily', 'Weekly', 'BiWeekly', 'Monthly', 'Quarterly', 'None')) NOT VALID;

ALTER TABLE __mj_BizAppsTasks."TaskCheckIn"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

ALTER TABLE __mj_BizAppsTasks."TaskCheckIn"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();


-- ===================== Grants =====================

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskCheckIns" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Check Ins */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Check Ins
-- Item: Permissions for vwTaskCheckIns
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskCheckIns" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Check Ins */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Check Ins
-- Item: spCreateTaskCheckIn
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskCheckIn
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskCheckIn" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Check Ins */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskCheckIn" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Check Ins */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Check Ins
-- Item: spUpdateTaskCheckIn
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskCheckIn
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskCheckIn" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskCheckIn" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Check Ins */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Check Ins
-- Item: spDeleteTaskCheckIn
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskCheckIn
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskCheckIn" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Check Ins */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskCheckIn" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Index for Foreign Keys for Task */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TypeID in table Task;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTask" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTask" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTask" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Tasks */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTask" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTask" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTask" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: spUpdateTask
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR Task
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTask" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTask" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTask" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTask" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTask" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTask" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: spDeleteTask
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR Task
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTask" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTask" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTask" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Tasks */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTask" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTask" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTask" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* SQL text to delete unneeded entity fields (2 scoped entities) */


-- ===================== Comments =====================

COMMENT ON COLUMN __mj_BizAppsTasks."Task"."HealthStatus" IS 'Qualitative health status for priority/OKR tracking: OnTrack, AtRisk, OffTrack, Completed, or Paused.';

COMMENT ON COLUMN __mj_BizAppsTasks."Task"."ConfidenceScore" IS 'Owner confidence score (0-100) that this task, key result, or objective will hit its target on time.';

COMMENT ON COLUMN __mj_BizAppsTasks."Task"."BaselineValue" IS 'Starting baseline value for measurable key results or quantitative deliverables.';

COMMENT ON COLUMN __mj_BizAppsTasks."Task"."TargetValue" IS 'Target goal value for measurable key results or quantitative deliverables.';

COMMENT ON COLUMN __mj_BizAppsTasks."Task"."CurrentValue" IS 'Latest actual measured value for this key result or deliverable, updated automatically by TaskCheckIn records.';

COMMENT ON COLUMN __mj_BizAppsTasks."Task"."UnitOfMeasure" IS 'Unit of measure for BaselineValue, TargetValue, and CurrentValue (e.g., %, USD, Days, Customers, NPS).';

COMMENT ON COLUMN __mj_BizAppsTasks."Task"."MetricDirection" IS 'Direction of improvement for quantitative metrics: Increase, Decrease, or Maintain.';

COMMENT ON COLUMN __mj_BizAppsTasks."Task"."RollupWeight" IS 'Relative weight (default 1.00) when rolling up child task or key result progress into a parent objective.';

COMMENT ON COLUMN __mj_BizAppsTasks."Task"."PlanningPeriod" IS 'Planning horizon or OKR cycle identifier (e.g., 2026-Q4, FY2027, H1-2026).';

COMMENT ON COLUMN __mj_BizAppsTasks."Task"."CheckInCadence" IS 'Expected progress check-in frequency: Daily, Weekly, BiWeekly, Monthly, Quarterly, or None.';

COMMENT ON COLUMN __mj_BizAppsTasks."Task"."LastCheckInAt" IS 'Timestamp when the most recent TaskCheckIn was recorded for this task.';

COMMENT ON COLUMN __mj_BizAppsTasks."Task"."NextCheckInDueAt" IS 'Timestamp when the next progress check-in is due based on CheckInCadence; used by Chief of Staff to nudge owners.';

COMMENT ON TABLE __mj_BizAppsTasks."TaskCheckIn" IS 'Structured periodic progress check-ins for tasks, priorities, and OKRs, authored by users or AI agents such as Chief of Staff.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskCheckIn"."TaskID" IS 'The task, priority objective, or key result this check-in updates.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskCheckIn"."AuthorPersonID" IS 'Optional Person record who authored or approved the check-in.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskCheckIn"."AuthorUserID" IS 'Optional MemberJunction User who authored or submitted the check-in.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskCheckIn"."ReportedByAIAgentID" IS 'Optional AI Agent (e.g., Chief of Staff) that synthesized and recorded this check-in.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskCheckIn"."CheckInAt" IS 'Timestamp when the check-in occurred.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskCheckIn"."HealthStatus" IS 'Health status reported at check-in: OnTrack, AtRisk, OffTrack, Completed, or Paused.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskCheckIn"."ConfidenceScore" IS 'Confidence score (0-100) reported at the time of check-in.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskCheckIn"."PreviousValue" IS 'Metric value prior to this check-in.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskCheckIn"."NewValue" IS 'Updated metric value reported in this check-in.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskCheckIn"."PercentComplete" IS 'Percent complete (0-100) reported or computed in this check-in.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskCheckIn"."Summary" IS 'Narrative summary of accomplishments and status since the last check-in.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskCheckIn"."Blockers" IS 'Risks, impediments, or cross-team blockers surfaced during the check-in.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskCheckIn"."NextSteps" IS 'Planned next steps and commitments before the next check-in.';


-- ===================== Other =====================

-- =============================================================================
-- GENERATED BY MemberJunction CodeGen — DO NOT EDIT BY HAND
-- =============================================================================

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Check Ins */

/* SQL text to insert 28 new entity field(s) */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Check Ins */

/* spUpdate Permissions for MJ_BizApps_Tasks: Tasks */
