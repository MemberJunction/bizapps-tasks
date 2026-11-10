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
-- BizAppsTasks: TaskType.ExtensionEntity + WorkReport & WorkReportItem Tables
-- 1. Adds ExtensionEntity to TaskType so extension Open Apps (e.g. GitHub,
--    Align, Jira) register disjoint IS-A Task child entities resolved
--    declaratively by Task's SubtypeSelector (TypeID.ExtensionEntity).
-- 2. Adds WorkReport and WorkReportItem tables for daily 15Five work reports
--    drafted by each person's Chief of Staff and reviewed by their supervisor's
--    Chief of Staff.
-- =============================================================================

---------------------------------------------------------------------------
-- 1. TaskType: Add ExtensionEntity Column
---------------------------------------------------------------------------
ALTER TABLE __mj_BizAppsTasks."TaskType"
 ADD COLUMN IF NOT EXISTS "ExtensionEntity" VARCHAR(255) NULL;

---------------------------------------------------------------------------
-- 2. WorkReport: Daily / periodic 15Five reports drafted & reviewed via CoS
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks."WorkReport" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "PersonID" UUID NOT NULL,
 "PeriodStart" DATE NOT NULL,
 "PeriodEnd" DATE NOT NULL,
 "Title" VARCHAR(255) NULL,
 "Body" TEXT NOT NULL,
 "Status" VARCHAR(20) NOT NULL DEFAULT 'Draft',
 "AuthoredByAgentRunID" UUID NULL,
 "SupervisorFeedback" TEXT NULL,
 "ReviewedByPersonID" UUID NULL,
 "ReviewedAt" TIMESTAMPTZ NULL,
 CONSTRAINT "PK_WorkReport" PRIMARY KEY ("ID"),
 CONSTRAINT "FK_WorkReport_Person" FOREIGN KEY ("PersonID") REFERENCES __mj_BizAppsCommon."Person"("ID"),
 CONSTRAINT "FK_WorkReport_AuthoredByAgentRun" FOREIGN KEY ("AuthoredByAgentRunID") REFERENCES ${mjSchema}."AIAgentRun"("ID"),
 CONSTRAINT "FK_WorkReport_ReviewedByPerson" FOREIGN KEY ("ReviewedByPersonID") REFERENCES __mj_BizAppsCommon."Person"("ID"),
 CONSTRAINT "UQ_WorkReport_Person_Period" UNIQUE ("PersonID", "PeriodStart", "PeriodEnd"),
 CONSTRAINT "CK_WorkReport_Status" CHECK ("Status" IN ('Draft', 'Submitted', 'Reviewed')),
 CONSTRAINT "CK_WorkReport_PeriodOrder" CHECK ("PeriodEnd" >= "PeriodStart")
);

CREATE INDEX IF NOT EXISTS "IX_WorkReport_Person_PeriodEnd"
    ON __mj_BizAppsTasks."WorkReport" ("PersonID", "PeriodEnd" DESC);

CREATE INDEX IF NOT EXISTS "IX_WorkReport_ReviewedByPerson_Status"
    ON __mj_BizAppsTasks."WorkReport" ("ReviewedByPersonID", "Status");

---------------------------------------------------------------------------
-- 3. WorkReportItem: Line items linking each report entry to its Task
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks."WorkReportItem" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "WorkReportID" UUID NOT NULL,
 "TaskID" UUID NULL,
 "Section" VARCHAR(50) NOT NULL DEFAULT 'Completed',
 "Summary" TEXT NOT NULL,
 "Sequence" INTEGER NOT NULL DEFAULT 0,
 CONSTRAINT "PK_WorkReportItem" PRIMARY KEY ("ID"),
 CONSTRAINT "FK_WorkReportItem_WorkReport" FOREIGN KEY ("WorkReportID") REFERENCES __mj_BizAppsTasks."WorkReport"("ID"),
 CONSTRAINT "FK_WorkReportItem_Task" FOREIGN KEY ("TaskID") REFERENCES __mj_BizAppsTasks."Task"("ID"),
 CONSTRAINT "CK_WorkReportItem_Section" CHECK ("Section" IN ('Completed', 'InProgress', 'Next', 'Blockers', 'AtRisk'))
);

CREATE INDEX IF NOT EXISTS "IX_WorkReportItem_WorkReport_Sequence"
    ON __mj_BizAppsTasks."WorkReportItem" ("WorkReportID", "Sequence");

---------------------------------------------------------------------------
-- 4. Row-Level Security Filters for 15Five Work Reports & Work Report Items
---------------------------------------------------------------------------
INSERT INTO ${mjSchema}."RowLevelSecurityFilter" ("ID", "Name", "FilterText", "Description", "__mj_CreatedAt", "__mj_UpdatedAt")
SELECT CAST('DC505938-81AC-4EFF-A6FF-99BFB5B11018' AS UUID),
       'UI: Work Reports - Author or Supervisor Chain',
       '("PersonID" IN (SELECT p."ID" FROM __mj_BizAppsCommon."Person" p WHERE p."LinkedUserID" = ''{{UserID}}'' OR LOWER(p."Email") = LOWER(''{{UserEmail}}'') OR LOWER(p."Email") IN (SELECT LOWER(ae."Email") FROM ${mjSchema}."Employee" ae INNER JOIN ${mjSchema}."Employee" se ON ae."SupervisorID" = se."ID" LEFT OUTER JOIN ${mjSchema}."Employee" sse ON se."SupervisorID" = sse."ID" WHERE ae."Active" = TRUE AND (LOWER(se."Email") = LOWER(''{{UserEmail}}'') OR LOWER(sse."Email") = LOWER(''{{UserEmail}}'') OR LOWER(se."Email") IN (SELECT LOWER(sp."Email") FROM __mj_BizAppsCommon."Person" sp WHERE sp."LinkedUserID" = ''{{UserID}}'') OR LOWER(sse."Email") IN (SELECT LOWER(sp."Email") FROM __mj_BizAppsCommon."Person" sp WHERE sp."LinkedUserID" = ''{{UserID}}'')))))',
       'Narrows MJ_BizApps_Tasks: Work Reports for the UI role to reports authored by the current user or by someone in the current user''s supervisor chain.',
       NOW(),
       NOW()
WHERE NOT EXISTS (SELECT 1 FROM ${mjSchema}."RowLevelSecurityFilter" WHERE "ID" = CAST('DC505938-81AC-4EFF-A6FF-99BFB5B11018' AS UUID));

INSERT INTO ${mjSchema}."RowLevelSecurityFilter" ("ID", "Name", "FilterText", "Description", "__mj_CreatedAt", "__mj_UpdatedAt")
SELECT CAST('E2D9FE26-3490-48C5-A60B-42F1B2973B19' AS UUID),
       'UI: Work Report Items - Author or Supervisor Chain',
       '("WorkReportID" IN (SELECT r."ID" FROM __mj_BizAppsTasks."WorkReport" r WHERE r."PersonID" IN (SELECT p."ID" FROM __mj_BizAppsCommon."Person" p WHERE p."LinkedUserID" = ''{{UserID}}'' OR LOWER(p."Email") = LOWER(''{{UserEmail}}'') OR LOWER(p."Email") IN (SELECT LOWER(ae."Email") FROM ${mjSchema}."Employee" ae INNER JOIN ${mjSchema}."Employee" se ON ae."SupervisorID" = se."ID" LEFT OUTER JOIN ${mjSchema}."Employee" sse ON se."SupervisorID" = sse."ID" WHERE ae."Active" = TRUE AND (LOWER(se."Email") = LOWER(''{{UserEmail}}'') OR LOWER(sse."Email") = LOWER(''{{UserEmail}}'') OR LOWER(se."Email") IN (SELECT LOWER(sp."Email") FROM __mj_BizAppsCommon."Person" sp WHERE sp."LinkedUserID" = ''{{UserID}}'') OR LOWER(sse."Email") IN (SELECT LOWER(sp."Email") FROM __mj_BizAppsCommon."Person" sp WHERE sp."LinkedUserID" = ''{{UserID}}''))))))',
       'Narrows MJ_BizApps_Tasks: Work Report Items for the UI role to line items belonging to work reports authored by the current user or by someone in the current user''s supervisor chain.',
       NOW(),
       NOW()
WHERE NOT EXISTS (SELECT 1 FROM ${mjSchema}."RowLevelSecurityFilter" WHERE "ID" = CAST('E2D9FE26-3490-48C5-A60B-42F1B2973B19' AS UUID));

ALTER TABLE __mj_BizAppsTasks."WorkReport"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.WorkReport */
ALTER TABLE __mj_BizAppsTasks."WorkReport"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.WorkReportItem */
ALTER TABLE __mj_BizAppsTasks."WorkReportItem"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.WorkReportItem */
ALTER TABLE __mj_BizAppsTasks."WorkReportItem"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnAssignActionID" ON __mj_BizAppsTasks."TaskType" ("OnAssignActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnCompleteActionID" ON __mj_BizAppsTasks."TaskType" ("OnCompleteActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnOverdueActionID" ON __mj_BizAppsTasks."TaskType" ("OnOverdueActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnPercentChangeActionID" ON __mj_BizAppsTasks."TaskType" ("OnPercentChangeActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnRejectActionID" ON __mj_BizAppsTasks."TaskType" ("OnRejectActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnCancelActionID" ON __mj_BizAppsTasks."TaskType" ("OnCancelActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnCreateActionID" ON __mj_BizAppsTasks."TaskType" ("OnCreateActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnStatusChangeActionID" ON __mj_BizAppsTasks."TaskType" ("OnStatusChangeActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_WorkReportItem_WorkReportID" ON __mj_BizAppsTasks."WorkReportItem" ("WorkReportID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_WorkReportItem_TaskID" ON __mj_BizAppsTasks."WorkReportItem" ("TaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_WorkReport_PersonID" ON __mj_BizAppsTasks."WorkReport" ("PersonID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_WorkReport_AuthoredByAgentRunID" ON __mj_BizAppsTasks."WorkReport" ("AuthoredByAgentRunID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_WorkReport_ReviewedByPersonID" ON __mj_BizAppsTasks."WorkReport" ("ReviewedByPersonID");


-- ===================== Helper Functions (fn*) =====================

CREATE FUNCTION __mj_BizAppsTasks."fnTaskCommentParentID_GetHierarchyMeta"
(
    p_RecordID UUID,
    p_ParentID UUID
)
RETURNS TABLE
AS
RETURN
(
    WITH CTE_Ancestors AS (
        SELECT
            "ID",
            "ParentID",
            0 AS "Depth",
            CAST('/' || CAST("ID" AS VARCHAR(36)) || '/' AS TEXT) AS "Path"
        FROM
            __mj_BizAppsTasks."TaskComment"
        WHERE
            "ID" = p_RecordID

        UNION ALL

        SELECT
            p."ID",
            p."ParentID",
            c."Depth" + 1 AS "Depth",
            CAST('/' || CAST(p."ID" AS VARCHAR(36)) || c."Path" AS TEXT) AS "Path"
        FROM
            __mj_BizAppsTasks."TaskComment" p
        INNER JOIN
            CTE_Ancestors c ON p."ID" = c."ParentID"
        WHERE
            c."Depth" < 100
    )
    SELECT         a."ID" AS "RootID",
        (SELECT MAX("Depth") FROM CTE_Ancestors) AS "Depth",
        (SELECT "Path" FROM CTE_Ancestors ORDER BY "Depth" DESC
LIMIT 1) AS "Path",
        CAST(CASE WHEN EXISTS (SELECT 1 FROM __mj_BizAppsTasks."TaskComment" WHERE "ParentID" = p_RecordID) THEN 0 ELSE 1 END AS BOOLEAN) AS "IsLeaf",
        (SELECT COUNT(1) FROM __mj_BizAppsTasks."TaskComment" WHERE "ParentID" = p_RecordID) AS "ChildCount"
    FROM
        CTE_Ancestors a
    WHERE
        a."ParentID" IS NULL OR p_ParentID IS NULL
    ORDER BY
        a."Depth" DESC

LIMIT 1);

CREATE FUNCTION __mj_BizAppsTasks."fnTaskCommentParentID_GetDescendants"
(
    p_RootID UUID,
    p_MaxDepth INTEGER = NULL
)
RETURNS TABLE
AS
RETURN
(
    WITH CTE_Descendants AS (
        SELECT
            "ID",
            "ParentID",
            0 AS "RelativeDepth",
            CAST('/' || CAST("ID" AS VARCHAR(36)) || '/' AS TEXT) AS "Path"
        FROM
            __mj_BizAppsTasks."TaskComment"
        WHERE
            "ID" = p_RootID

        UNION ALL

        SELECT
            c."ID",
            c."ParentID",
            p."RelativeDepth" || 1 AS "RelativeDepth",
            CAST(p."Path" || CAST(c."ID" AS VARCHAR(36)) || '/' AS TEXT) AS "Path"
        FROM
            __mj_BizAppsTasks."TaskComment" c
        INNER JOIN
            CTE_Descendants p ON c."ParentID" = p."ID"
        WHERE
            (p_MaxDepth IS NULL OR p."RelativeDepth" < p_MaxDepth)
            AND p."RelativeDepth" < 100
    )
    SELECT
        d."ID" AS "ID",
        d."RelativeDepth" AS "Depth",
        d."Path",
        CAST(CASE WHEN EXISTS (SELECT 1 FROM __mj_BizAppsTasks."TaskComment" WHERE "ParentID" = d."ID") THEN 0 ELSE 1 END AS BOOLEAN) AS "IsLeaf",
        (SELECT COUNT(1) FROM __mj_BizAppsTasks."TaskComment" WHERE "ParentID" = d."ID") AS "ChildCount"
    FROM
        CTE_Descendants d
);

CREATE FUNCTION __mj_BizAppsTasks."fnTaskCommentParentID_GetAncestors"
(
    p_RecordID UUID
)
RETURNS TABLE
AS
RETURN
(
    WITH CTE_Ancestors AS (
        SELECT
            "ID",
            "ParentID",
            0 AS "LevelUp",
            CAST('/' || CAST("ID" AS VARCHAR(36)) || '/' AS TEXT) AS "Path"
        FROM
            __mj_BizAppsTasks."TaskComment"
        WHERE
            "ID" = p_RecordID

        UNION ALL

        SELECT
            p."ID",
            p."ParentID",
            c."LevelUp" + 1 AS "LevelUp",
            CAST('/' || CAST(p."ID" AS VARCHAR(36)) || c."Path" AS TEXT) AS "Path"
        FROM
            __mj_BizAppsTasks."TaskComment" p
        INNER JOIN
            CTE_Ancestors c ON p."ID" = c."ParentID"
        WHERE
            c."LevelUp" < 100
    )
    SELECT
        a."ID" AS "ID",
        a."LevelUp",
        a."Path"
    FROM
        CTE_Ancestors a
);

CREATE OR REPLACE FUNCTION __mj_BizAppsTasks."fnTaskCommentParentID_GetRootID"(
    p_RecordID UUID,
    p_ParentID UUID
) RETURNS TABLE("RootID" UUID) AS $fn$
    WITH RECURSIVE cte_root_parent AS (
        SELECT
            "ID",
            "ParentID",
            "ID" AS root_parent_id,
            0 AS depth
        FROM __mj_BizAppsTasks."TaskComment"
        WHERE "ID" = COALESCE(p_ParentID, p_RecordID)

        UNION ALL

        SELECT
            c."ID",
            c."ParentID",
            c."ID" AS root_parent_id,
            p.depth + 1 AS depth
        FROM __mj_BizAppsTasks."TaskComment" c
        INNER JOIN cte_root_parent p ON c."ID" = p."ParentID"
        WHERE p.depth < 100
    )
    SELECT root_parent_id AS "RootID"
    FROM cte_root_parent
    WHERE "ParentID" IS NULL
    ORDER BY root_parent_id
    LIMIT 1;
$fn$ LANGUAGE sql STABLE;

CREATE FUNCTION __mj_BizAppsTasks."fnTaskTemplateItemParentItemID_GetHierarchyMeta"
(
    p_RecordID UUID,
    p_ParentID UUID
)
RETURNS TABLE
AS
RETURN
(
    WITH CTE_Ancestors AS (
        SELECT
            "ID",
            "ParentItemID",
            0 AS "Depth",
            CAST('/' || CAST("ID" AS VARCHAR(36)) || '/' AS TEXT) AS "Path"
        FROM
            __mj_BizAppsTasks."TaskTemplateItem"
        WHERE
            "ID" = p_RecordID

        UNION ALL

        SELECT
            p."ID",
            p."ParentItemID",
            c."Depth" + 1 AS "Depth",
            CAST('/' || CAST(p."ID" AS VARCHAR(36)) || c."Path" AS TEXT) AS "Path"
        FROM
            __mj_BizAppsTasks."TaskTemplateItem" p
        INNER JOIN
            CTE_Ancestors c ON p."ID" = c."ParentItemID"
        WHERE
            c."Depth" < 100
    )
    SELECT         a."ID" AS "RootID",
        (SELECT MAX("Depth") FROM CTE_Ancestors) AS "Depth",
        (SELECT "Path" FROM CTE_Ancestors ORDER BY "Depth" DESC
LIMIT 1) AS "Path",
        CAST(CASE WHEN EXISTS (SELECT 1 FROM __mj_BizAppsTasks."TaskTemplateItem" WHERE "ParentItemID" = p_RecordID) THEN 0 ELSE 1 END AS BOOLEAN) AS "IsLeaf",
        (SELECT COUNT(1) FROM __mj_BizAppsTasks."TaskTemplateItem" WHERE "ParentItemID" = p_RecordID) AS "ChildCount"
    FROM
        CTE_Ancestors a
    WHERE
        a."ParentItemID" IS NULL OR p_ParentID IS NULL
    ORDER BY
        a."Depth" DESC

LIMIT 1);

CREATE FUNCTION __mj_BizAppsTasks."fnTaskTemplateItemParentItemID_GetDescendants"
(
    p_RootID UUID,
    p_MaxDepth INTEGER = NULL
)
RETURNS TABLE
AS
RETURN
(
    WITH CTE_Descendants AS (
        SELECT
            "ID",
            "ParentItemID",
            0 AS "RelativeDepth",
            CAST('/' || CAST("ID" AS VARCHAR(36)) || '/' AS TEXT) AS "Path"
        FROM
            __mj_BizAppsTasks."TaskTemplateItem"
        WHERE
            "ID" = p_RootID

        UNION ALL

        SELECT
            c."ID",
            c."ParentItemID",
            p."RelativeDepth" || 1 AS "RelativeDepth",
            CAST(p."Path" || CAST(c."ID" AS VARCHAR(36)) || '/' AS TEXT) AS "Path"
        FROM
            __mj_BizAppsTasks."TaskTemplateItem" c
        INNER JOIN
            CTE_Descendants p ON c."ParentItemID" = p."ID"
        WHERE
            (p_MaxDepth IS NULL OR p."RelativeDepth" < p_MaxDepth)
            AND p."RelativeDepth" < 100
    )
    SELECT
        d."ID" AS "ID",
        d."RelativeDepth" AS "Depth",
        d."Path",
        CAST(CASE WHEN EXISTS (SELECT 1 FROM __mj_BizAppsTasks."TaskTemplateItem" WHERE "ParentItemID" = d."ID") THEN 0 ELSE 1 END AS BOOLEAN) AS "IsLeaf",
        (SELECT COUNT(1) FROM __mj_BizAppsTasks."TaskTemplateItem" WHERE "ParentItemID" = d."ID") AS "ChildCount"
    FROM
        CTE_Descendants d
);

CREATE FUNCTION __mj_BizAppsTasks."fnTaskTemplateItemParentItemID_GetAncestors"
(
    p_RecordID UUID
)
RETURNS TABLE
AS
RETURN
(
    WITH CTE_Ancestors AS (
        SELECT
            "ID",
            "ParentItemID",
            0 AS "LevelUp",
            CAST('/' || CAST("ID" AS VARCHAR(36)) || '/' AS TEXT) AS "Path"
        FROM
            __mj_BizAppsTasks."TaskTemplateItem"
        WHERE
            "ID" = p_RecordID

        UNION ALL

        SELECT
            p."ID",
            p."ParentItemID",
            c."LevelUp" + 1 AS "LevelUp",
            CAST('/' || CAST(p."ID" AS VARCHAR(36)) || c."Path" AS TEXT) AS "Path"
        FROM
            __mj_BizAppsTasks."TaskTemplateItem" p
        INNER JOIN
            CTE_Ancestors c ON p."ID" = c."ParentItemID"
        WHERE
            c."LevelUp" < 100
    )
    SELECT
        a."ID" AS "ID",
        a."LevelUp",
        a."Path"
    FROM
        CTE_Ancestors a
);

CREATE OR REPLACE FUNCTION __mj_BizAppsTasks."fnTaskTemplateItemParentItemID_GetRootID"(
    p_RecordID UUID,
    p_ParentID UUID
) RETURNS TABLE("RootID" UUID) AS $fn$
    WITH RECURSIVE cte_root_parent AS (
        SELECT
            "ID",
            "ParentItemID",
            "ID" AS root_parent_id,
            0 AS depth
        FROM __mj_BizAppsTasks."TaskTemplateItem"
        WHERE "ID" = COALESCE(p_ParentID, p_RecordID)

        UNION ALL

        SELECT
            c."ID",
            c."ParentItemID",
            c."ID" AS root_parent_id,
            p.depth + 1 AS depth
        FROM __mj_BizAppsTasks."TaskTemplateItem" c
        INNER JOIN cte_root_parent p ON c."ID" = p."ParentItemID"
        WHERE p.depth < 100
    )
    SELECT root_parent_id AS "RootID"
    FROM cte_root_parent
    WHERE "ParentItemID" IS NULL
    ORDER BY root_parent_id
    LIMIT 1;
$fn$ LANGUAGE sql STABLE;


-- ===================== Views =====================

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskAssignments" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskAssignments';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskAssignments"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "MJEntity_AssigneeEntityID"."Name" AS "AssigneeEntity",
    "mjBizAppsTasksTaskRole_RoleID"."Name" AS "Role",
    "mjBizAppsCommonPerson_AssignedByPersonID"."DisplayName" AS "AssignedByPerson"
FROM
    __mj_BizAppsTasks."TaskAssignment" AS t
LEFT OUTER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."Entity" AS "MJEntity_AssigneeEntityID"
  ON
    t."AssigneeEntityID" = "MJEntity_AssigneeEntityID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsTasks."TaskRole" AS "mjBizAppsTasksTaskRole_RoleID"
  ON
    t."RoleID" = "mjBizAppsTasksTaskRole_RoleID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsCommon."Person" AS "mjBizAppsCommonPerson_AssignedByPersonID"
  ON
    t."AssignedByPersonID" = "mjBizAppsCommonPerson_AssignedByPersonID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskActivities" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskActivities';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskActivities"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "mjBizAppsCommonPerson_PersonID"."DisplayName" AS "Person"
FROM
    __mj_BizAppsTasks."TaskActivity" AS t
LEFT OUTER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsCommon."Person" AS "mjBizAppsCommonPerson_PersonID"
  ON
    t."PersonID" = "mjBizAppsCommonPerson_PersonID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskComments" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskComments';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskComments"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "mjBizAppsCommonPerson_PersonID"."DisplayName" AS "Person",
    "hier_ParentID"."RootID" AS "RootParentID",
    "hier_ParentID"."Depth" AS "ParentIDDepth",
    "hier_ParentID"."Path" AS "ParentIDPath",
    "hier_ParentID"."IsLeaf" AS "ParentIDIsLeaf",
    "hier_ParentID"."ChildCount" AS "ParentIDChildCount"
FROM
    __mj_BizAppsTasks."TaskComment" AS t
LEFT OUTER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsCommon."Person" AS "mjBizAppsCommonPerson_PersonID"
  ON
    t."PersonID" = "mjBizAppsCommonPerson_PersonID"."ID"
LEFT JOIN LATERAL (SELECT * FROM __mj_BizAppsTasks."fnTaskCommentParentID_GetHierarchyMeta"(t."ID", t."ParentID")) AS "hier_ParentID"
    ON TRUE$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskDependencies" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskDependencies';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskDependencies"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "mjBizAppsTasksTask_DependsOnTaskID"."Name" AS "DependsOnTask"
FROM
    __mj_BizAppsTasks."TaskDependency" AS t
LEFT OUTER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_DependsOnTaskID"
  ON
    t."DependsOnTaskID" = "mjBizAppsTasksTask_DependsOnTaskID"."ID"$vsql$;
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
LEFT OUTER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsCommon."Person" AS "mjBizAppsCommonPerson_AuthorPersonID"
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskDecisions" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskDecisions';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskDecisions"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "mjBizAppsTasksTaskDecisionOutcome_OutcomeID"."Name" AS "Outcome",
    "mjBizAppsCommonPerson_DecidedByPersonID"."DisplayName" AS "DecidedByPerson"
FROM
    __mj_BizAppsTasks."TaskDecision" AS t
LEFT OUTER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsTasks."TaskDecisionOutcome" AS "mjBizAppsTasksTaskDecisionOutcome_OutcomeID"
  ON
    t."OutcomeID" = "mjBizAppsTasksTaskDecisionOutcome_OutcomeID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsCommon."Person" AS "mjBizAppsCommonPerson_DecidedByPersonID"
  ON
    t."DecidedByPersonID" = "mjBizAppsCommonPerson_DecidedByPersonID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskTemplateItemDependencies" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskTemplateItemDependencies';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskTemplateItemDependencies"
AS SELECT
    t.*,
    "mjBizAppsTasksTaskTemplateItem_ItemID"."Name" AS "Item",
    "mjBizAppsTasksTaskTemplateItem_DependsOnItemID"."Name" AS "DependsOnItem"
FROM
    __mj_BizAppsTasks."TaskTemplateItemDependency" AS t
LEFT OUTER JOIN
    __mj_BizAppsTasks."TaskTemplateItem" AS "mjBizAppsTasksTaskTemplateItem_ItemID"
  ON
    t."ItemID" = "mjBizAppsTasksTaskTemplateItem_ItemID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsTasks."TaskTemplateItem" AS "mjBizAppsTasksTaskTemplateItem_DependsOnItemID"
  ON
    t."DependsOnItemID" = "mjBizAppsTasksTaskTemplateItem_DependsOnItemID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskNotificationLogs" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskNotificationLogs';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskNotificationLogs"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "MJUser_NotifiedUserID"."Name" AS "NotifiedUser"
FROM
    __mj_BizAppsTasks."TaskNotificationLog" AS t
LEFT OUTER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."User" AS "MJUser_NotifiedUserID"
  ON
    t."NotifiedUserID" = "MJUser_NotifiedUserID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskLinks" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskLinks';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskLinks"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "MJEntity_EntityID"."Name" AS "Entity"
FROM
    __mj_BizAppsTasks."TaskLink" AS t
LEFT OUTER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."Entity" AS "MJEntity_EntityID"
  ON
    t."EntityID" = "MJEntity_EntityID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskTagLinks" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskTagLinks';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskTagLinks"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "mjBizAppsTasksTaskTag_TagID"."Name" AS "Tag"
FROM
    __mj_BizAppsTasks."TaskTagLink" AS t
LEFT OUTER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsTasks."TaskTag" AS "mjBizAppsTasksTaskTag_TagID"
  ON
    t."TagID" = "mjBizAppsTasksTaskTag_TagID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskTemplateItemRoles" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskTemplateItemRoles';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskTemplateItemRoles"
AS SELECT
    t.*,
    "mjBizAppsTasksTaskTemplateItem_ItemID"."Name" AS "Item",
    "mjBizAppsTasksTaskRole_RoleID"."Name" AS "Role"
FROM
    __mj_BizAppsTasks."TaskTemplateItemRole" AS t
LEFT OUTER JOIN
    __mj_BizAppsTasks."TaskTemplateItem" AS "mjBizAppsTasksTaskTemplateItem_ItemID"
  ON
    t."ItemID" = "mjBizAppsTasksTaskTemplateItem_ItemID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsTasks."TaskRole" AS "mjBizAppsTasksTaskRole_RoleID"
  ON
    t."RoleID" = "mjBizAppsTasksTaskRole_RoleID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskTypes" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskTypes';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskTypes"
AS SELECT
    t.*,
    "MJAction_OnAssignActionID"."Name" AS "OnAssignAction",
    "MJAction_OnCompleteActionID"."Name" AS "OnCompleteAction",
    "MJAction_OnOverdueActionID"."Name" AS "OnOverdueAction",
    "MJAction_OnPercentChangeActionID"."Name" AS "OnPercentChangeAction",
    "MJAction_OnRejectActionID"."Name" AS "OnRejectAction",
    "MJAction_OnCancelActionID"."Name" AS "OnCancelAction",
    "MJAction_OnCreateActionID"."Name" AS "OnCreateAction",
    "MJAction_OnStatusChangeActionID"."Name" AS "OnStatusChangeAction"
FROM
    __mj_BizAppsTasks."TaskType" AS t
LEFT OUTER JOIN
    ${mjSchema}."Action" AS "MJAction_OnAssignActionID"
  ON
    t."OnAssignActionID" = "MJAction_OnAssignActionID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS "MJAction_OnCompleteActionID"
  ON
    t."OnCompleteActionID" = "MJAction_OnCompleteActionID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS "MJAction_OnOverdueActionID"
  ON
    t."OnOverdueActionID" = "MJAction_OnOverdueActionID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS "MJAction_OnPercentChangeActionID"
  ON
    t."OnPercentChangeActionID" = "MJAction_OnPercentChangeActionID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS "MJAction_OnRejectActionID"
  ON
    t."OnRejectActionID" = "MJAction_OnRejectActionID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS "MJAction_OnCancelActionID"
  ON
    t."OnCancelActionID" = "MJAction_OnCancelActionID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS "MJAction_OnCreateActionID"
  ON
    t."OnCreateActionID" = "MJAction_OnCreateActionID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS "MJAction_OnStatusChangeActionID"
  ON
    t."OnStatusChangeActionID" = "MJAction_OnStatusChangeActionID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskTemplateItems" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskTemplateItems';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskTemplateItems"
AS SELECT
    t.*,
    "mjBizAppsTasksTaskTemplate_TemplateID"."Name" AS "Template",
    "mjBizAppsTasksTaskTemplateItem_ParentItemID"."Name" AS "ParentItem",
    "hier_ParentItemID"."RootID" AS "RootParentItemID",
    "hier_ParentItemID"."Depth" AS "ParentItemIDDepth",
    "hier_ParentItemID"."Path" AS "ParentItemIDPath",
    "hier_ParentItemID"."IsLeaf" AS "ParentItemIDIsLeaf",
    "hier_ParentItemID"."ChildCount" AS "ParentItemIDChildCount"
FROM
    __mj_BizAppsTasks."TaskTemplateItem" AS t
LEFT OUTER JOIN
    __mj_BizAppsTasks."TaskTemplate" AS "mjBizAppsTasksTaskTemplate_TemplateID"
  ON
    t."TemplateID" = "mjBizAppsTasksTaskTemplate_TemplateID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsTasks."TaskTemplateItem" AS "mjBizAppsTasksTaskTemplateItem_ParentItemID"
  ON
    t."ParentItemID" = "mjBizAppsTasksTaskTemplateItem_ParentItemID"."ID"
LEFT JOIN LATERAL (SELECT * FROM __mj_BizAppsTasks."fnTaskTemplateItemParentItemID_GetHierarchyMeta"(t."ID", t."ParentItemID")) AS "hier_ParentItemID"
    ON TRUE$vsql$;
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
    __mj_BizAppsCommon."Person" AS "mjBizAppsCommonPerson_CreatedByPersonID"
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskTypeStatus" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskTypeStatus';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskTypeStatus"
AS SELECT
    t.*,
    "mjBizAppsTasksTaskType_TaskTypeID"."Name" AS "TaskType",
    "MJAction_OnEnterActionID"."Name" AS "OnEnterAction",
    "MJAction_OnExitActionID"."Name" AS "OnExitAction"
FROM
    __mj_BizAppsTasks."TaskTypeStatus" AS t
LEFT OUTER JOIN
    __mj_BizAppsTasks."TaskType" AS "mjBizAppsTasksTaskType_TaskTypeID"
  ON
    t."TaskTypeID" = "mjBizAppsTasksTaskType_TaskTypeID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS "MJAction_OnEnterActionID"
  ON
    t."OnEnterActionID" = "MJAction_OnEnterActionID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS "MJAction_OnExitActionID"
  ON
    t."OnExitActionID" = "MJAction_OnExitActionID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwWorkReportItems" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwWorkReportItems';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwWorkReportItems"
AS SELECT
    w.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task"
FROM
    __mj_BizAppsTasks."WorkReportItem" AS w
LEFT OUTER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    w."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwWorkReports" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwWorkReports';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwWorkReports"
AS SELECT
    w.*,
    "mjBizAppsCommonPerson_PersonID"."DisplayName" AS "Person",
    "MJAIAgentRun_AuthoredByAgentRunID"."RunName" AS "AuthoredByAgentRun",
    "mjBizAppsCommonPerson_ReviewedByPersonID"."DisplayName" AS "ReviewedByPerson"
FROM
    __mj_BizAppsTasks."WorkReport" AS w
LEFT OUTER JOIN
    __mj_BizAppsCommon."Person" AS "mjBizAppsCommonPerson_PersonID"
  ON
    w."PersonID" = "mjBizAppsCommonPerson_PersonID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."AIAgentRun" AS "MJAIAgentRun_AuthoredByAgentRunID"
  ON
    w."AuthoredByAgentRunID" = "MJAIAgentRun_AuthoredByAgentRunID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsCommon."Person" AS "mjBizAppsCommonPerson_ReviewedByPersonID"
  ON
    w."ReviewedByPersonID" = "mjBizAppsCommonPerson_ReviewedByPersonID"."ID"$vsql$;
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
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskAssignment]
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @AssigneeEntityID UUID,
--     @AssigneeRecordID VARCHAR(450)...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskAssignment]
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @AssigneeEntityID UUID = NULL,
--     @AssigneeRecordID nvarch...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskAssignment]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskAssignment]
--     WHERE
--         [ID]...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskActivity]
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @PersonID_Clear bit = 0,
--     @PersonID UUID = NULL,
--     @Acti...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskActivity]
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @PersonID_Clear bit = 0,
--     @PersonID UUID = NULL,
--     @Acti...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskActivity]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskActivity]
--     WHERE
--         [ID] = @...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskComment]
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @ParentID_Clear bit = 0,
--     @ParentID UUID = NULL,
--     @Perso...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskComment]
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @ParentID_Clear bit = 0,
--     @ParentID UUID = NULL,
--     @Perso...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskComment]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskComment]
--     WHERE
--         [ID] = @ID...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskDependency]
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @DependsOnTaskID UUID,
--     @DependencyType VARCHAR(50) = N...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskDependency]
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @DependsOnTaskID UUID = NULL,
--     @DependencyType TEXT(...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskDependency]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskDependency]
--     WHERE
--         [ID]...

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
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskDecision]
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @OutcomeID UUID,
--     @DecidedByPersonID_Clear bit = 0,
--     @D...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskDecision]
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @OutcomeID UUID = NULL,
--     @DecidedByPersonID_Clear bit = 0,...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskDecision]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskDecision]
--     WHERE
--         [ID] = @...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskTemplateItemDependency]
--     @ID UUID = NULL,
--     @ItemID UUID,
--     @DependsOnItemID UUID,
--     @DependencyType nvar...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskTemplateItemDependency]
--     @ID UUID,
--     @ItemID UUID = NULL,
--     @DependsOnItemID UUID = NULL,
--     @DependencyTy...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskTemplateItemDependency]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskTemplateItemDependency...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskNotificationLog]
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @NotificationType VARCHAR(50),
--     @NotifiedUserID uniqueidentifi...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskNotificationLog]
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @NotificationType VARCHAR(50) = NULL,
--     @NotifiedUserID uniquei...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskNotificationLog]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskNotificationLog]
--     WHERE
--   ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskLink]
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @EntityID UUID,
--     @RecordID VARCHAR(450),
--     @Description_Cle...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskLink]
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @EntityID UUID = NULL,
--     @RecordID VARCHAR(450) = NULL,
--     @D...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskLink]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskLink]
--     WHERE
--         [ID] = @ID
-- 
-- 
--    ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskTagLink]
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @TagID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     DECLARE @Inserted...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskTagLink]
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @TagID UUID = NULL
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--    ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskTagLink]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskTagLink]
--     WHERE
--         [ID] = @ID...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskTemplateItemRole]
--     @ID UUID = NULL,
--     @ItemID UUID,
--     @RoleID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     DECLARE...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskTemplateItemRole]
--     @ID UUID,
--     @ItemID UUID = NULL,
--     @RoleID UUID = NULL
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskTemplateItemRole]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskTemplateItemRole]
--     WHERE
-- ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskType]
--     @ID UUID = NULL,
--     @Name VARCHAR(100),
--     @Description_Clear bit = 0,
--     @Description TEXT = NULL,
--     @IconClass_...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskType]
--     @ID UUID,
--     @Name VARCHAR(100) = NULL,
--     @Description_Clear bit = 0,
--     @Description TEXT = NULL,
--     @IconClass_...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskType]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskType]
--     WHERE
--         [ID] = @ID
-- 
-- 
--    ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskTemplateItem]
--     @ID UUID = NULL,
--     @TemplateID UUID,
--     @Name VARCHAR(255),
--     @Description_Clear bit = 0,
--     @Descrip...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskTemplateItem]
--     @ID UUID,
--     @TemplateID UUID = NULL,
--     @Name VARCHAR(255) = NULL,
--     @Description_Clear bit = 0,
--     @...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskTemplateItem]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskTemplateItem]
--     WHERE
--         ...

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

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskTypeStatus]
--     @ID UUID = NULL,
--     @TaskTypeID UUID,
--     @Name VARCHAR(100),
--     @Code VARCHAR(50),
--     @Description_Clear...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskTypeStatus]
--     @ID UUID,
--     @TaskTypeID UUID = NULL,
--     @Name VARCHAR(100) = NULL,
--     @Code VARCHAR(50) = NULL,
--     @Des...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskTypeStatus]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskTypeStatus]
--     WHERE
--         [ID]...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateWorkReportItem]
--     @ID UUID = NULL,
--     @WorkReportID UUID,
--     @TaskID_Clear bit = 0,
--     @TaskID UUID = NULL,
--     @...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateWorkReportItem]
--     @ID UUID,
--     @WorkReportID UUID = NULL,
--     @TaskID_Clear bit = 0,
--     @TaskID UUID = NULL,
--     @...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteWorkReportItem]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[WorkReportItem]
--     WHERE
--         [ID]...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateWorkReport]
--     @ID UUID = NULL,
--     @PersonID UUID,
--     @PeriodStart date,
--     @PeriodEnd date,
--     @Title_Clear bit = 0,
--     @Ti...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateWorkReport]
--     @ID UUID,
--     @PersonID UUID = NULL,
--     @PeriodStart date = NULL,
--     @PeriodEnd date = NULL,
--     @Title_Clear bi...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteWorkReport]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[WorkReport]
--     WHERE
--         [ID] = @ID
-- 
-- ...


-- ===================== Triggers =====================

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTaskAssignment
-- ON __mj_BizAppsTasks."TaskAssignment"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskAssignment"
   

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTaskActivity
-- ON __mj_BizAppsTasks."TaskActivity"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskActivity"
--     SET
 

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTaskComment
-- ON __mj_BizAppsTasks."TaskComment"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskComment"
--     SET
    

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTaskDependency
-- ON __mj_BizAppsTasks."TaskDependency"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskDependency"
   

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
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTaskDecision
-- ON __mj_BizAppsTasks."TaskDecision"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskDecision"
--     SET
 

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTaskTemplateItemDependency
-- ON __mj_BizAppsTasks."TaskTemplateItemDependency"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTas

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks".trgUpdateTaskNotificationLog
-- ON __mj_BizAppsTasks."TaskNotificationLog"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskNotif

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks".trgUpdateTaskLink
-- ON __mj_BizAppsTasks."TaskLink"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskLink"
--     SET
--         __mj_

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTaskTagLink
-- ON __mj_BizAppsTasks."TaskTagLink"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskTagLink"
--     SET
    

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTaskTemplateItemRole
-- ON __mj_BizAppsTasks."TaskTemplateItemRole"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskTem

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks".trgUpdateTaskType
-- ON __mj_BizAppsTasks."TaskType"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskType"
--     SET
--         __mj_

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTaskTemplateItem
-- ON __mj_BizAppsTasks."TaskTemplateItem"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskTemplateIte

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks".trgUpdateTask
-- ON __mj_BizAppsTasks."Task"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."Task"
--     SET
--         __mj_UpdatedAt = 

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTaskTypeStatus
-- ON __mj_BizAppsTasks."TaskTypeStatus"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskTypeStatus"
   

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateWorkReportItem
-- ON __mj_BizAppsTasks."WorkReportItem"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."WorkReportItem"
   

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateWorkReport
-- ON __mj_BizAppsTasks."WorkReport"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."WorkReport"
--     SET
       


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
         'a9038030-2dbd-48e1-9075-03ed5373b85a',
         'MJ_BizApps_Tasks: Work Reports',
         'Work Reports',
         'Daily or periodic 15Five work reports summarizing what got done, what is next, blockers, and at-risk objectives for a person, drafted by their Chief of Staff and reviewed with supervisor feedback.',
         NULL,
         'WorkReport',
         'vwWorkReports',
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

/* SQL generated to add entity MJ_BizApps_Tasks: Work Reports to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO ${mjSchema}."ApplicationEntity"
                                    ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'a9038030-2dbd-48e1-9075-03ed5373b85a', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM ${mjSchema}."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Work Reports for role UI */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "ReadRLSFilterID", "UpdateRLSFilterID", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('a9038030-2dbd-48e1-9075-03ed5373b85a' AS UUID), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', TRUE, TRUE, TRUE, FALSE, CAST('DC505938-81AC-4EFF-A6FF-99BFB5B11018' AS UUID), CAST('DC505938-81AC-4EFF-A6FF-99BFB5B11018' AS UUID), NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('a9038030-2dbd-48e1-9075-03ed5373b85a' AS UUID) AND "RoleID" = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Work Reports for role Developer */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('a9038030-2dbd-48e1-9075-03ed5373b85a' AS UUID), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('a9038030-2dbd-48e1-9075-03ed5373b85a' AS UUID) AND "RoleID" = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Work Reports for role Integration */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('a9038030-2dbd-48e1-9075-03ed5373b85a' AS UUID), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('a9038030-2dbd-48e1-9075-03ed5373b85a' AS UUID) AND "RoleID" = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Work Report Items */

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
         'd9e9ee62-78ce-4e89-8ed0-35378358e321',
         'MJ_BizApps_Tasks: Work Report Items',
         'Work Report Items',
         'Individual line items in a WorkReport linking each accomplishment, next step, blocker, or at-risk item to its originating Task.',
         NULL,
         'WorkReportItem',
         'vwWorkReportItems',
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

/* SQL generated to add entity MJ_BizApps_Tasks: Work Report Items to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO ${mjSchema}."ApplicationEntity"
                                    ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'd9e9ee62-78ce-4e89-8ed0-35378358e321', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM ${mjSchema}."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Work Report Items for role UI */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "ReadRLSFilterID", "UpdateRLSFilterID", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('d9e9ee62-78ce-4e89-8ed0-35378358e321' AS UUID), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', TRUE, TRUE, TRUE, FALSE, CAST('E2D9FE26-3490-48C5-A60B-42F1B2973B19' AS UUID), CAST('E2D9FE26-3490-48C5-A60B-42F1B2973B19' AS UUID), NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('d9e9ee62-78ce-4e89-8ed0-35378358e321' AS UUID) AND "RoleID" = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Work Report Items for role Developer */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('d9e9ee62-78ce-4e89-8ed0-35378358e321' AS UUID), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('d9e9ee62-78ce-4e89-8ed0-35378358e321' AS UUID) AND "RoleID" = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Work Report Items for role Integration */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('d9e9ee62-78ce-4e89-8ed0-35378358e321' AS UUID), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('d9e9ee62-78ce-4e89-8ed0-35378358e321' AS UUID) AND "RoleID" = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL text to update existing entities from schema */

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks."WorkReport" */
UPDATE __mj_BizAppsTasks."WorkReport" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.WorkReport */
ALTER TABLE __mj_BizAppsTasks."WorkReport" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."WorkReport"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks."WorkReport" */
UPDATE __mj_BizAppsTasks."WorkReport" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.WorkReport */
ALTER TABLE __mj_BizAppsTasks."WorkReport" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."WorkReport"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks."WorkReportItem" */
UPDATE __mj_BizAppsTasks."WorkReportItem" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.WorkReportItem */
ALTER TABLE __mj_BizAppsTasks."WorkReportItem" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."WorkReportItem"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks."WorkReportItem" */
UPDATE __mj_BizAppsTasks."WorkReportItem" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.WorkReportItem */
ALTER TABLE __mj_BizAppsTasks."WorkReportItem" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."WorkReportItem"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'd6b740e7-dfa0-4fd7-9c9c-96bdf9182b0a' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'ID')
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
        'd6b740e7-dfa0-4fd7-9c9c-96bdf9182b0a',
        'A9038030-2DBD-48E1-9075-03ED5373B85A', -- "Entity": "MJ_BizApps_Tasks": "Work" "Reports"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'eb682468-bfe5-402f-9560-f97a34282275' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'PersonID')
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
        'eb682468-bfe5-402f-9560-f97a34282275',
        'A9038030-2DBD-48E1-9075-03ED5373B85A', -- "Entity": "MJ_BizApps_Tasks": "Work" "Reports"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
        'PersonID',
        'Person ID',
        'The Person record whose work is summarized in this report.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'bbb95bb8-04ad-4f28-9408-3c8e9773305d' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'PeriodStart')
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
        'bbb95bb8-04ad-4f28-9408-3c8e9773305d',
        'A9038030-2DBD-48E1-9075-03ED5373B85A', -- "Entity": "MJ_BizApps_Tasks": "Work" "Reports"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
        'PeriodStart',
        'Period Start',
        'Inclusive start date of the reporting window.',
        'date',
        3,
        10,
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
        TRUE,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'f8887bd2-78f6-429a-b7bd-f814d4f7a37c' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'PeriodEnd')
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
        'f8887bd2-78f6-429a-b7bd-f814d4f7a37c',
        'A9038030-2DBD-48E1-9075-03ED5373B85A', -- "Entity": "MJ_BizApps_Tasks": "Work" "Reports"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
        'PeriodEnd',
        'Period End',
        'Inclusive end date of the reporting window.',
        'date',
        3,
        10,
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
        TRUE,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '9d56d5c4-7a96-4465-ba13-01b78557dbd2' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'Title')
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
        '9d56d5c4-7a96-4465-ba13-01b78557dbd2',
        'A9038030-2DBD-48E1-9075-03ED5373B85A', -- "Entity": "MJ_BizApps_Tasks": "Work" "Reports"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
        'Title',
        'Title',
        'Optional concise headline for the report (e.g., Daily 15Five — 2026-11-09).',
        'TEXT',
        510,
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
        TRUE,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'f9618412-4e0b-4940-9207-a8134099948e' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'Body')
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
        'f9618412-4e0b-4940-9207-a8134099948e',
        'A9038030-2DBD-48E1-9075-03ED5373B85A', -- "Entity": "MJ_BizApps_Tasks": "Work" "Reports"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
        'Body',
        'Body',
        'Markdown body of the work report covering accomplishments, next priorities, blockers, and at-risk objectives.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '5c7fc965-777e-4b95-8c42-d7372122849b' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'Status')
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
        '5c7fc965-777e-4b95-8c42-d7372122849b',
        'A9038030-2DBD-48E1-9075-03ED5373B85A', -- "Entity": "MJ_BizApps_Tasks": "Work" "Reports"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
        'Status',
        'Status',
        'Lifecycle status of the report: Draft (awaiting author approval), Submitted (approved by author, awaiting supervisor review), or Reviewed (supervisor feedback recorded).',
        'TEXT',
        40,
        0,
        0,
        FALSE,
        'Draft',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '0e7a4d77-5ad4-408a-8331-ee2d6cf84149' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'AuthoredByAgentRunID')
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
        '0e7a4d77-5ad4-408a-8331-ee2d6cf84149',
        'A9038030-2DBD-48E1-9075-03ED5373B85A', -- "Entity": "MJ_BizApps_Tasks": "Work" "Reports"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
        'AuthoredByAgentRunID',
        'Authored By Agent Run ID',
        'Optional AI Agent Run that drafted this work report.',
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
        '5190AF93-4C39-4429-BDAA-0AEB492A0256',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '9705c6bf-1b9b-4849-8c18-02c29e208015' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'SupervisorFeedback')
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
        '9705c6bf-1b9b-4849-8c18-02c29e208015',
        'A9038030-2DBD-48E1-9075-03ED5373B85A', -- "Entity": "MJ_BizApps_Tasks": "Work" "Reports"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
        'SupervisorFeedback',
        'Supervisor Feedback',
        'Feedback drafted by the supervisor Chief of Staff and approved/edited by the supervisor.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '884afceb-89e4-4deb-91cf-7334ab075cb2' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'ReviewedByPersonID')
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
        '884afceb-89e4-4deb-91cf-7334ab075cb2',
        'A9038030-2DBD-48E1-9075-03ED5373B85A', -- "Entity": "MJ_BizApps_Tasks": "Work" "Reports"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
        'ReviewedByPersonID',
        'Reviewed By Person ID',
        'The supervisor Person record who reviewed and approved feedback on this report.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '0a8e806d-3a65-4b1a-9b67-340298e7015c' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'ReviewedAt')
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
        '0a8e806d-3a65-4b1a-9b67-340298e7015c',
        'A9038030-2DBD-48E1-9075-03ED5373B85A', -- "Entity": "MJ_BizApps_Tasks": "Work" "Reports"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
        'ReviewedAt',
        'Reviewed At',
        'Timestamp when supervisor feedback was approved and recorded on this report.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'b09e0770-76d8-4f44-8da7-884217ed2b6e' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = '__mj_CreatedAt')
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
        'b09e0770-76d8-4f44-8da7-884217ed2b6e',
        'A9038030-2DBD-48E1-9075-03ED5373B85A', -- "Entity": "MJ_BizApps_Tasks": "Work" "Reports"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '3d99c7ca-bc59-4c0c-acf8-b3d9051fb2b1' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = '__mj_UpdatedAt')
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
        '3d99c7ca-bc59-4c0c-acf8-b3d9051fb2b1',
        'A9038030-2DBD-48E1-9075-03ED5373B85A', -- "Entity": "MJ_BizApps_Tasks": "Work" "Reports"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '273826b0-2b87-4a25-a69c-4fb46312b01f' OR ("EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND "Name" = 'ID')
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
        '273826b0-2b87-4a25-a69c-4fb46312b01f',
        'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- "Entity": "MJ_BizApps_Tasks": "Work" "Report" "Items"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '74c73051-9dc1-42d9-add4-95469fe48087' OR ("EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND "Name" = 'WorkReportID')
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
        '74c73051-9dc1-42d9-add4-95469fe48087',
        'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- "Entity": "MJ_BizApps_Tasks": "Work" "Report" "Items"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
        'WorkReportID',
        'Work Report ID',
        'Parent WorkReport that owns this line item.',
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
        'A9038030-2DBD-48E1-9075-03ED5373B85A',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'd7c0eea5-0ab9-429c-a21e-b3b9d8e7161e' OR ("EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND "Name" = 'TaskID')
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
        'd7c0eea5-0ab9-429c-a21e-b3b9d8e7161e',
        'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- "Entity": "MJ_BizApps_Tasks": "Work" "Report" "Items"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
        'TaskID',
        'Task ID',
        'Optional Task referenced by this report item.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'eaf8cc4f-cd1e-4d53-95db-325d1584929f' OR ("EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND "Name" = 'Section')
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
        'eaf8cc4f-cd1e-4d53-95db-325d1584929f',
        'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- "Entity": "MJ_BizApps_Tasks": "Work" "Report" "Items"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
        'Section',
        'Section',
        'Report section this line belongs to: Completed, InProgress, Next, Blockers, or AtRisk.',
        'TEXT',
        100,
        0,
        0,
        FALSE,
        'Completed',
        FALSE,
        TRUE,
        FALSE,
        FALSE,
        NULL,
        NULL,
        FALSE,
        FALSE,
        FALSE,
        TRUE,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '11458626-d4d5-4304-b8fe-ccf68542869a' OR ("EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND "Name" = 'Summary')
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
        '11458626-d4d5-4304-b8fe-ccf68542869a',
        'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- "Entity": "MJ_BizApps_Tasks": "Work" "Report" "Items"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
        'Summary',
        'Summary',
        'Concise description of the progress, next step, blocker, or risk for this line item.',
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
        TRUE,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '60ce469e-cc17-49b0-9c68-4c53887f0b86' OR ("EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND "Name" = 'Sequence')
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
        '60ce469e-cc17-49b0-9c68-4c53887f0b86',
        'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- "Entity": "MJ_BizApps_Tasks": "Work" "Report" "Items"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
        'Sequence',
        'Sequence',
        'Display order within the parent WorkReport (ascending).',
        'INTEGER',
        4,
        10,
        0,
        FALSE,
        '(0)',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'fcb6c423-fbec-48a8-bc9b-8dc6a1ea28f9' OR ("EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND "Name" = '__mj_CreatedAt')
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
        'fcb6c423-fbec-48a8-bc9b-8dc6a1ea28f9',
        'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- "Entity": "MJ_BizApps_Tasks": "Work" "Report" "Items"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'b02253a9-a98b-4223-9e00-b0da95ec4eeb' OR ("EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND "Name" = '__mj_UpdatedAt')
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
        'b02253a9-a98b-4223-9e00-b0da95ec4eeb',
        'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- "Entity": "MJ_BizApps_Tasks": "Work" "Report" "Items"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '5684d61d-47a2-410e-bcc3-4373142de0f3' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'ExtensionEntity')
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
        '5684d61d-47a2-410e-bcc3-4373142de0f3',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606'),
        'ExtensionEntity',
        'Extension Entity',
        'Optional MemberJunction Entity name (e.g. MJ_BizApps_Tasks_GitHub: GitHub Issue Tasks) of the disjoint IS-A child of MJ_BizApps_Tasks: Tasks provisioned for tasks of this type. Read declaratively by Task SubtypeSelector (TypeID.ExtensionEntity).',
        'TEXT',
        510,
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

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='635846E8-E8F9-4BE2-9E6B-AD783BAE05CF';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='C95BF1FD-38AA-476A-86C4-CCE1DAA7AB65';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='B6C11250-D2DB-4B0F-9594-BCD9271DBB8B';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='3A40307F-EF27-4079-8FB3-D9C0403A1199';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='9E75F106-9F72-4F58-9181-4A08E8BB577C';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='26D52813-85CA-44A2-A09C-BA320EE6AA40';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='BC167D9F-E496-4FC3-BFDE-13A7CFB9DA2A';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='653E807F-F0DD-40EE-8E35-DD04B64231DC';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='DD2E1A2D-4EEB-4ECC-AA52-A6A79D339C88';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='A325C453-D9B9-4B5F-9DBE-549E27243C40';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='0E2761D2-AD6B-4E31-B4E8-885BF5B34B68';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='DFC7A14D-DA67-403E-A80D-C84390EA33BC';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='CEDC7F50-5CB2-4311-B0D4-737303E70A60';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='8AEEE5EF-4A5E-418A-BE44-325D7A5A68D9';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='A8D56409-368D-46E1-A251-91DFCC3DF4C8';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='D067FAB6-3C26-4846-966A-44C2F03EAF6E';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='641DC25E-83F6-410D-84D4-2BD3190094FF';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='5544F182-AA03-4855-8232-A8D3C4CCECA4';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='047AA982-23F2-4BD6-B2AB-6C4E6B314E00';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='FB2E3A35-BCA9-40E9-8001-860BE1445992';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='5D642C95-B90D-497E-BC37-A1924FFD9F28';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='B063068F-8B10-4A2D-B9E6-0D24C52EE804';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='0122031C-E04A-4782-9F96-11E014325A3A';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='7369BFD9-A4A7-4B57-A06B-14F2F58ECE68';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='2D1DA61D-CAAE-490A-B3C5-9B9EEEA3E98B';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='0E381E48-B41D-49DC-8C77-2A3E2412F240';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='A35BD3A6-B328-4B8B-87A4-1D7B2F68588D';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='78BD5BE3-62E9-4254-8119-D5BDF1025CF3';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='F3B28978-4D13-43B7-92CF-9C50CDB97C82';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='71809B6D-BFFF-494A-A139-BF7569CFFBE6';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='F3E5AD4A-7F3A-40BC-86E8-EB996023D911';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='EF71A1BC-8503-4807-85C6-4236A4DD4935';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='E73100EA-6879-482C-9C65-8E395393E188';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='98AA8D90-4FA6-4C4D-9B8E-89D51989AB37';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='A48F70E4-69BA-4206-B424-9DEE180A251E';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='E092392B-F130-4856-ABE2-3D060E590282';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='0E6A25C1-3213-4DAE-9686-F8D688AF2102';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='50D54B01-1DF3-4D74-BD73-438708EF0548';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='7826FB29-771D-46B1-96B3-05499A302D17';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='CA573315-A0A0-471E-92DF-D504D37DC9EB';

/* SQL text to insert entity field value with ID d4fe7213-fdfd-47b3-867f-9b5e8a564d49 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "Source", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('d4fe7213-fdfd-47b3-867f-9b5e8a564d49', '5C7FC965-777E-4B95-8C42-D7372122849B', 1, 'Draft', 'Draft', 'Check', NOW(), NOW());

/* SQL text to insert entity field value with ID 2cf8b583-d07b-454a-ba2c-ba60b8758851 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "Source", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('2cf8b583-d07b-454a-ba2c-ba60b8758851', '5C7FC965-777E-4B95-8C42-D7372122849B', 2, 'Reviewed', 'Reviewed', 'Check', NOW(), NOW());

/* SQL text to insert entity field value with ID 1f579f9f-99d0-4cda-b4a1-cba567399c6b */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "Source", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('1f579f9f-99d0-4cda-b4a1-cba567399c6b', '5C7FC965-777E-4B95-8C42-D7372122849B', 3, 'Submitted', 'Submitted', 'Check', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 5C7FC965-777E-4B95-8C42-D7372122849B */

UPDATE ${mjSchema}."EntityField" SET "ValueListType"='List' WHERE "ID"='5C7FC965-777E-4B95-8C42-D7372122849B';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='0509C923-75C4-422C-A0B0-A45C5977D773';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='3634DD1F-E2B1-4D25-AA82-5EDDF33FB266';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='F0595906-74AA-4EFD-83E9-C7297878277B';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='71DA79A8-C0ED-4FC5-B9B1-1166A4A038C9';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='7EC8681C-C3C2-468D-925E-27293A06A4BD';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='B4FBA07D-5070-427E-A751-236B0A8FFE51';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='2AFC33BF-FB39-445D-8610-0867D4997923';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='7A9742F5-DE77-4A89-9A95-413B357FC6E4';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='8491ECCC-82E1-4449-A675-BC8036D461D1';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='8AE2A9C0-E952-4271-A1C2-3853347BF37B';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='3B04B519-5C74-45B1-BA4B-94372125B7E5';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='F0EC7C9E-9646-491F-929E-165449D8929E';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='F86D7D4F-2042-4A2B-A984-6C6C073D1CB1';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='40B53F38-2CE5-41B1-8116-D2340BF0B78B';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='DD9E09D4-FF5D-44DC-8AC4-7554FEEE32FB';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='20257078-873D-4C95-9DD9-078E4E856FCB';

/* SQL text to insert entity field value with ID 7d6b0ea8-61bc-449d-9d66-933ec097f08f */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "Source", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('7d6b0ea8-61bc-449d-9d66-933ec097f08f', 'EAF8CC4F-CD1E-4D53-95DB-325D1584929F', 1, 'AtRisk', 'AtRisk', 'Check', NOW(), NOW());

/* SQL text to insert entity field value with ID c33b4665-bfde-42f2-b45d-863ec4a03057 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "Source", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('c33b4665-bfde-42f2-b45d-863ec4a03057', 'EAF8CC4F-CD1E-4D53-95DB-325D1584929F', 2, 'Blockers', 'Blockers', 'Check', NOW(), NOW());

/* SQL text to insert entity field value with ID 8abe5288-4591-4bb3-94c2-aefe5ef9f2de */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "Source", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('8abe5288-4591-4bb3-94c2-aefe5ef9f2de', 'EAF8CC4F-CD1E-4D53-95DB-325D1584929F', 3, 'Completed', 'Completed', 'Check', NOW(), NOW());

/* SQL text to insert entity field value with ID 76211948-6f13-414f-a2fa-7b7563bd292e */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "Source", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('76211948-6f13-414f-a2fa-7b7563bd292e', 'EAF8CC4F-CD1E-4D53-95DB-325D1584929F', 4, 'InProgress', 'InProgress', 'Check', NOW(), NOW());

/* SQL text to insert entity field value with ID 979b9c63-5900-472a-a015-7a7da1db7d74 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "Source", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('979b9c63-5900-472a-a015-7a7da1db7d74', 'EAF8CC4F-CD1E-4D53-95DB-325D1584929F', 5, 'Next', 'Next', 'Check', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID EAF8CC4F-CD1E-4D53-95DB-325D1584929F */

UPDATE ${mjSchema}."EntityField" SET "ValueListType"='List' WHERE "ID"='EAF8CC4F-CD1E-4D53-95DB-325D1584929F';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='A94D176F-BD81-4959-8D4D-2EEDBF74DD0F';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='5E16D4B6-4F90-46BD-BDA7-0650BCADBFAC';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='33EB2FB9-CF45-4958-8C5A-7703E4C3D33B';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='C101D7BC-C32D-4521-9B6A-567E5ADD230B';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='14F84226-72F3-48D0-B3CA-F9DE97F016AF';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='D250809F-E070-4321-BBA9-4ADAD00F6766';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='19A8398A-E441-459E-9A81-F02E6EFF6778';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='83614E4E-617C-4AAC-8A72-48C8BCA3E243';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='5409B332-98F9-404E-98FE-A3351B7C168C';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='4D30381D-494D-4522-9888-C6AD0C7F6B55';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='05D117F8-7CB2-401E-80F3-28023880E81B';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='BA7566D8-67DB-49AA-BF82-D68E54551D29';

/* SQL text to update entity field value sequence and source */

UPDATE ${mjSchema}."EntityFieldValue" SET "Source"='Check' WHERE "ID"='5DF92809-95D3-45A6-934E-730F6A38E5FF';

/* Deterministic search-flag hygiene — seed name fields */

UPDATE ${mjSchema}."EntityField"
         SET "IncludeInUserSearchAPI" = TRUE,
             "UserSearchPredicateAPI" = 'BeginsWith'
         WHERE "ID" IN (
            SELECT ranked."ID" FROM (
               SELECT f."ID",
                      ROW_NUMBER() OVER (
                         PARTITION BY f."EntityID"
                         ORDER BY f."Sequence", f."Name"
                      ) AS rn
               FROM ${mjSchema}."EntityField" f
               INNER JOIN ${mjSchema}."Entity" e ON e."ID" = f."EntityID"
               WHERE LOWER(f."Name") IN ('name','title','firstname','lastname','middlename','displayname','fullname','label')
                 AND f."AutoUpdateIncludeInUserSearchAPI" = TRUE
                 AND f."IncludeInUserSearchAPI" = FALSE
                 AND COALESCE(f."IsPrimaryKey", 0) = 0
                 AND COALESCE(f."IsVirtual", 0) = 0
                 AND LOWER(f."Type") IN ('TEXT','varchar','char','nchar')
                 AND COALESCE(f."Length", 0) <> -1
                 AND e."VirtualEntity" = FALSE
                 AND e."AllowUserSearchAPI" = TRUE
                 AND COALESCE(e."FullTextSearchEnabled", 0) = 0
                 AND NOT ((e."Name" = 'Logs' OR e."Name" LIKE '% Logs') OR (e."Name" = 'Log' OR e."Name" LIKE '% Log') OR (e."Name" = 'Runs' OR e."Name" LIKE '% Runs') OR (e."Name" = 'Run' OR e."Name" LIKE '% Run') OR (e."Name" = 'Run History' OR e."Name" LIKE '% Run History') OR (e."Name" = 'Run Steps' OR e."Name" LIKE '% Run Steps') OR (e."Name" = 'Run Messages' OR e."Name" LIKE '% Run Messages') OR (e."Name" = 'Execution Logs' OR e."Name" LIKE '% Execution Logs') OR (e."Name" = 'Details' OR e."Name" LIKE '% Details') OR (e."Name" = 'Detail' OR e."Name" LIKE '% Detail') OR (e."Name" = 'Lines' OR e."Name" LIKE '% Lines') OR (e."Name" = 'Line' OR e."Name" LIKE '% Line') OR (e."Name" = 'Items' OR e."Name" LIKE '% Items') OR (e."Name" = 'Item' OR e."Name" LIKE '% Item') OR (e."Name" = 'Steps' OR e."Name" LIKE '% Steps') OR (e."Name" = 'Step' OR e."Name" LIKE '% Step') OR (e."Name" = 'Params' OR e."Name" LIKE '% Params') OR (e."Name" = 'Param' OR e."Name" LIKE '% Param') OR (e."Name" = 'Mappings' OR e."Name" LIKE '% Mappings') OR (e."Name" = 'Mapping' OR e."Name" LIKE '% Mapping') OR (e."Name" = 'Audit' OR e."Name" LIKE 'Audit %' OR e."Name" LIKE '% Audit' OR e."Name" LIKE '% Audit %') OR (e."Name" = 'Record Change' OR e."Name" LIKE 'Record Change %' OR e."Name" LIKE '% Record Change' OR e."Name" LIKE '% Record Change %'))
                 AND e."SchemaName" NOT IN ('${mjSchema}','__mj_BizAppsAccounting','__mj_BizAppsCommon','__mj_BizAppsOrders','sys')
                 AND NOT EXISTS (
               SELECT 1 FROM ${mjSchema}."EntityField" f2
               WHERE f2."EntityID" = e."ID"
                 AND f2."IncludeInUserSearchAPI" = TRUE
            )
            ) ranked
            WHERE ranked.rn <= 3
         );

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
              AND e."SchemaName" NOT IN ('${mjSchema}','__mj_BizAppsAccounting','__mj_BizAppsCommon','__mj_BizAppsOrders','sys')
              AND NOT EXISTS (
               SELECT 1 FROM ${mjSchema}."EntityField" f2
               WHERE f2."EntityID" = e."ID"
                 AND f2."IncludeInUserSearchAPI" = TRUE
            )
         );


/* Create Entity Relationship: MJ_BizApps_Tasks: Work Reports -> MJ_BizApps_Tasks: Work Report Items (One To Many via WorkReportID) */

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '122ad9d9-cc06-44d8-aa10-308f670325fa' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "RelatedEntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND "RelatedEntityJoinField" = 'WorkReportID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('122ad9d9-cc06-44d8-aa10-308f670325fa', 'A9038030-2DBD-48E1-9075-03ED5373B85A', 'D9E9EE62-78CE-4E89-8ED0-35378358E321', 'WorkReportID', 'One To Many', TRUE, TRUE, 1, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = 'a9a7b014-4185-44b3-87de-3e47e006332a' OR ("EntityID" = '5190AF93-4C39-4429-BDAA-0AEB492A0256' AND "RelatedEntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "RelatedEntityJoinField" = 'AuthoredByAgentRunID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('a9a7b014-4185-44b3-87de-3e47e006332a', '5190AF93-4C39-4429-BDAA-0AEB492A0256', 'A9038030-2DBD-48E1-9075-03ED5373B85A', 'AuthoredByAgentRunID', 'One To Many', TRUE, TRUE, 17, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '405bc61c-ff42-4457-a9ae-28c033179a23' OR ("EntityID" = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND "RelatedEntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "RelatedEntityJoinField" = 'PersonID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('405bc61c-ff42-4457-a9ae-28c033179a23', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'A9038030-2DBD-48E1-9075-03ED5373B85A', 'PersonID', 'One To Many', TRUE, TRUE, 27, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = 'd42d05fc-9c68-4158-9168-2e42676de7ed' OR ("EntityID" = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND "RelatedEntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "RelatedEntityJoinField" = 'ReviewedByPersonID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('d42d05fc-9c68-4158-9168-2e42676de7ed', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'A9038030-2DBD-48E1-9075-03ED5373B85A', 'ReviewedByPersonID', 'One To Many', TRUE, TRUE, 28, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '1a8268ea-646a-432b-9caa-922594236752' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "RelatedEntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND "RelatedEntityJoinField" = 'TaskID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('1a8268ea-646a-432b-9caa-922594236752', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'D9E9EE62-78CE-4E89-8ED0-35378358E321', 'TaskID', 'One To Many', TRUE, TRUE, 16, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'a56e1676-e40d-4b9e-b998-dc9fc98229a1' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'Person')
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
        'a56e1676-e40d-4b9e-b998-dc9fc98229a1',
        'A9038030-2DBD-48E1-9075-03ED5373B85A', -- "Entity": "MJ_BizApps_Tasks": "Work" "Reports"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
        'Person',
        'Person',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '3b336478-7069-495d-9f88-942494410d3f' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'AuthoredByAgentRun')
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
        '3b336478-7069-495d-9f88-942494410d3f',
        'A9038030-2DBD-48E1-9075-03ED5373B85A', -- "Entity": "MJ_BizApps_Tasks": "Work" "Reports"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
        'AuthoredByAgentRun',
        'Authored By Agent Run',
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

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '44fc4c0b-3516-4635-ba44-def7dc8dbe86' OR ("EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'ReviewedByPerson')
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
        '44fc4c0b-3516-4635-ba44-def7dc8dbe86',
        'A9038030-2DBD-48E1-9075-03ED5373B85A', -- "Entity": "MJ_BizApps_Tasks": "Work" "Reports"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A'),
        'ReviewedByPerson',
        'Reviewed By Person',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'aa32c6b9-6428-4bc4-b6e0-339f6de9650d' OR ("EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND "Name" = 'Task')
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
        'aa32c6b9-6428-4bc4-b6e0-339f6de9650d',
        'D9E9EE62-78CE-4E89-8ED0-35378358E321', -- "Entity": "MJ_BizApps_Tasks": "Work" "Report" "Items"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321'),
        'Task',
        'Task',
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
               WHERE "ID" = '60CE469E-CC17-49B0-9C68-4C53887F0B86'
               AND "AutoUpdateDefaultInView" = TRUE;

/* Set field properties for entity */

UPDATE ${mjSchema}."EntityField"
               SET "IsNameField" = TRUE
               WHERE "ID" = '9D56D5C4-7A96-4465-BA13-01B78557DBD2'
               AND "AutoUpdateIsNameField" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "DefaultInView" = TRUE
               WHERE "ID" = '5C7FC965-777E-4B95-8C42-D7372122849B'
               AND "AutoUpdateDefaultInView" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "DefaultInView" = TRUE
               WHERE "ID" = 'A56E1676-E40D-4B9E-B998-DC9FC98229A1'
               AND "AutoUpdateDefaultInView" = TRUE;

/* Set categories for 2 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.IsApproval

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Task Type Definition',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '0AA2AA72-7CED-4302-86CE-41A1C06B810B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.ExtensionEntity

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Task Type Definition',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '5684D61D-47A2-410E-BCC3-4373142DE0F3';

/* Set categories for 16 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.ID

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'System Metadata',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'D6B740E7-DFA0-4FD7-9C9C-96BDF9182B0A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.PersonID

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Report Information',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Person'
WHERE 
   "ID" = 'EB682468-BFE5-402F-9560-F97A34282275';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.PeriodStart

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Report Information',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'BBB95BB8-04AD-4F28-9408-3C8E9773305D';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.PeriodEnd

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Report Information',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'F8887BD2-78F6-429A-B7BD-F814D4F7A37C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.Title

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Report Information',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '9D56D5C4-7A96-4465-BA13-01B78557DBD2';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.Status

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Report Information',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '5C7FC965-777E-4B95-8C42-D7372122849B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.Body

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Report Content',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = 'Markdown'
WHERE 
   "ID" = 'F9618412-4E0B-4940-9207-A8134099948E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.AuthoredByAgentRunID

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Automation & Review',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Authored By Agent Run'
WHERE 
   "ID" = '0E7A4D77-5AD4-408A-8331-EE2D6CF84149';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.SupervisorFeedback

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Automation & Review',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '9705C6BF-1B9B-4849-8C18-02C29E208015';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.ReviewedByPersonID

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Automation & Review',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Reviewed By Person'
WHERE 
   "ID" = '884AFCEB-89E4-4DEB-91CF-7334AB075CB2';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.ReviewedAt

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Automation & Review',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '0A8E806D-3A65-4B1A-9B67-340298E7015C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.Person

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Report Information',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Person Name'
WHERE 
   "ID" = 'A56E1676-E40D-4B9E-B998-DC9FC98229A1';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.AuthoredByAgentRun

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Automation & Review',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Authored By Agent Run Name'
WHERE 
   "ID" = '3B336478-7069-495D-9F88-942494410D3F';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.ReviewedByPerson

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Automation & Review',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Reviewed By Person Name'
WHERE 
   "ID" = '44FC4C0B-3516-4635-BA44-DEF7DC8DBE86';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.__mj_CreatedAt

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'System Metadata',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'B09E0770-76D8-4F44-8DA7-884217ED2B6E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Reports.__mj_UpdatedAt

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'System Metadata',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '3D99C7CA-BC59-4C0C-ACF8-B3D9051FB2B1';

/* Set entity icon to fa fa-clipboard-list */

UPDATE ${mjSchema}."Entity"
               SET "Icon" = 'fa fa-clipboard-list', "__mj_UpdatedAt" = NOW()
               WHERE "ID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A';

/* Insert FieldCategoryInfo setting for entity */

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntitySetting" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'FieldCategoryInfo'
    ) THEN
        INSERT INTO ${mjSchema}."EntitySetting" ("ID", "EntityID", "Name", "Value", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('1027c8f3-fede-585a-bbbf-fe0b248ae23b', 'A9038030-2DBD-48E1-9075-03ED5373B85A', 'FieldCategoryInfo', '{
        "Automation & Review": {
        "description": "AI generation details, supervisor feedback, and review workflow",
        "icon": "fa fa-user-check"
        },
        "Report Content": {
        "description": "Detailed markdown contents summarizing work and progress",
        "icon": "fa fa-align-left"
        },
        "Report Information": {
        "description": "Core metadata and timeline information for the work report",
        "icon": "fa fa-file-alt"
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
        SELECT 1 FROM ${mjSchema}."EntitySetting" WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'FieldCategoryIcons'
    ) THEN
        INSERT INTO ${mjSchema}."EntitySetting" ("ID", "EntityID", "Name", "Value", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('160a47f5-5f0e-5dfe-b253-2bfe692afa76', 'A9038030-2DBD-48E1-9075-03ED5373B85A', 'FieldCategoryIcons', '{
        "Automation & Review": "fa fa-user-check",
        "Report Content": "fa fa-align-left",
        "Report Information": "fa fa-file-alt",
        "System Metadata": "fa fa-cog"
        }', NOW(), NOW());
    END IF;
END $$;

UPDATE ${mjSchema}."ApplicationEntity"
         SET "DefaultForNewUser" = TRUE, "__mj_UpdatedAt" = NOW()
         WHERE "EntityID" = 'A9038030-2DBD-48E1-9075-03ED5373B85A';

/* Set categories for 9 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.ID

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'System Metadata',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '273826B0-2B87-4A25-A69C-4FB46312B01F';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.WorkReportID

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Relationships',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Work Report'
WHERE 
   "ID" = '74C73051-9DC1-42D9-ADD4-95469FE48087';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.TaskID

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Relationships',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'D7C0EEA5-0AB9-429C-A21E-B3B9D8E7161E';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.Section

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Report Item Details',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'EAF8CC4F-CD1E-4D53-95DB-325D1584929F';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.Summary

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Report Item Details',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '11458626-D4D5-4304-B8FE-CCF68542869A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.Sequence

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Report Item Details',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = '60CE469E-CC17-49B0-9C68-4C53887F0B86';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.Task

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'Report Item Details',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Task Description'
WHERE 
   "ID" = 'AA32C6B9-6428-4BC4-B6E0-339F6DE9650D';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.__mj_CreatedAt

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'System Metadata',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'FCB6C423-FBEC-48A8-BC9B-8DC6A1EA28F9';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Work Report Items.__mj_UpdatedAt

UPDATE ${mjSchema}."EntityField"
SET 
   "Category" = 'System Metadata',
   "GeneratedFormSection" = 'Category'
WHERE 
   "ID" = 'B02253A9-A98B-4223-9E00-B0DA95EC4EEB';

/* Set entity icon to fa fa-tasks */

UPDATE ${mjSchema}."Entity"
               SET "Icon" = 'fa fa-tasks', "__mj_UpdatedAt" = NOW()
               WHERE "ID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321';

/* Insert FieldCategoryInfo setting for entity */

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntitySetting" WHERE "EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND "Name" = 'FieldCategoryInfo'
    ) THEN
        INSERT INTO ${mjSchema}."EntitySetting" ("ID", "EntityID", "Name", "Value", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('18f75737-6df7-5837-b517-c2686daa9b03', 'D9E9EE62-78CE-4E89-8ED0-35378358E321', 'FieldCategoryInfo', '{
        "Relationships": {
        "description": "Foreign key relationships to parent work reports and tasks",
        "icon": "fa fa-link"
        },
        "Report Item Details": {
        "description": "Content, section classification, and ordering of the report item",
        "icon": "fa fa-align-left"
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
        SELECT 1 FROM ${mjSchema}."EntitySetting" WHERE "EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321' AND "Name" = 'FieldCategoryIcons'
    ) THEN
        INSERT INTO ${mjSchema}."EntitySetting" ("ID", "EntityID", "Name", "Value", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('8480e57d-4fe8-58da-95db-fd3e4b01d6a2', 'D9E9EE62-78CE-4E89-8ED0-35378358E321', 'FieldCategoryIcons', '{
        "Relationships": "fa fa-link",
        "Report Item Details": "fa fa-align-left",
        "System Metadata": "fa fa-cog"
        }', NOW(), NOW());
    END IF;
END $$;

UPDATE ${mjSchema}."ApplicationEntity"
         SET "DefaultForNewUser" = FALSE, "__mj_UpdatedAt" = NOW()
         WHERE "EntityID" = 'D9E9EE62-78CE-4E89-8ED0-35378358E321';

/* Refresh custom base views for modified entities so schema changes are picked up */

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = 'A9038030-2DBD-48E1-9075-03ED5373B85A' AND "Name" = 'ValidatePeriodEndOnOrAfterPeriodStart'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('fa16a21b-3dc7-4b64-9ba1-3a16c166643a', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([PeriodEnd]>=[PeriodStart])', '	public ValidatePeriodEndOnOrAfterPeriodStart(result: ValidationResult) {
        if (this.PeriodStart != null && this.PeriodEnd != null && new Date(this.PeriodEnd).getTime() < new Date(this.PeriodStart).getTime()) {
        result.Errors.push(new ValidationErrorInfo(
        "PeriodEnd",
        "Period end date must be on or after the period start date.",
        this.PeriodEnd,
        ValidationErrorType.Failure
        ));
        }
        }', 'The period end date must be on or after the period start date.', 'ValidatePeriodEndOnOrAfterPeriodStart', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'A9038030-2DBD-48E1-9075-03ED5373B85A');
    END IF;
END $$;


-- ===================== Grants =====================

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskAssignments" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskAssignments" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskAssignments" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskAssignments" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Assignments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Assignments
-- Item: Permissions for vwTaskAssignments
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskAssignments" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskAssignments" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskAssignments" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskAssignments" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Assignments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Assignments
-- Item: spCreateTaskAssignment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskAssignment
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskAssignment" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskAssignment" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskAssignment" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Assignments */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskAssignment" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskAssignment" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskAssignment" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Assignments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Assignments
-- Item: spUpdateTaskAssignment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskAssignment
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskAssignment" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskAssignment" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskAssignment" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskAssignment" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskAssignment" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskAssignment" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Assignments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Assignments
-- Item: spDeleteTaskAssignment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskAssignment
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskAssignment" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskAssignment" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskAssignment" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Assignments */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskAssignment" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskAssignment" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskAssignment" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View SQL for MJ_BizApps_Tasks: Task Activities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Activities
-- Item: vwTaskActivities
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Activities
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  TaskActivity
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskActivities" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskActivities" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskActivities" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskActivities" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Activities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Activities
-- Item: Permissions for vwTaskActivities
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskActivities" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskActivities" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskActivities" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskActivities" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Activities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Activities
-- Item: spCreateTaskActivity
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskActivity
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskActivity" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskActivity" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskActivity" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Activities */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskActivity" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskActivity" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskActivity" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Activities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Activities
-- Item: spUpdateTaskActivity
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskActivity
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskActivity" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskActivity" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskActivity" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskActivity" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskActivity" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskActivity" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Activities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Activities
-- Item: spDeleteTaskActivity
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskActivity
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskActivity" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskActivity" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskActivity" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Activities */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskActivity" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskActivity" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskActivity" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Hierarchy Metadata Function SQL for MJ_BizApps_Tasks: Task Comments.ParentID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Comments
-- Item: fnTaskCommentParentID_GetHierarchyMeta
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- HIERARCHY METADATA FUNCTION FOR: [TaskComment].[ParentID]
------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskComments" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskComments" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskComments" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskComments" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Comments
-- Item: Permissions for vwTaskComments
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskComments" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskComments" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskComments" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskComments" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Comments
-- Item: spCreateTaskComment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskComment
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskComment" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskComment" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskComment" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Comments */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskComment" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskComment" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskComment" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Comments
-- Item: spUpdateTaskComment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskComment
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskComment" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskComment" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskComment" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskComment" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskComment" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskComment" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Comments
-- Item: spDeleteTaskComment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskComment
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskComment" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskComment" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskComment" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Comments */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskComment" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskComment" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskComment" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View SQL for MJ_BizApps_Tasks: Task Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Dependencies
-- Item: vwTaskDependencies
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Dependencies
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  TaskDependency
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskDependencies" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskDependencies" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskDependencies" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskDependencies" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Dependencies
-- Item: Permissions for vwTaskDependencies
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskDependencies" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskDependencies" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskDependencies" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskDependencies" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Dependencies
-- Item: spCreateTaskDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskDependency
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskDependency" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskDependency" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Dependencies */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskDependency" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskDependency" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Dependencies
-- Item: spUpdateTaskDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskDependency
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskDependency" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskDependency" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskDependency" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskDependency" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Dependencies
-- Item: spDeleteTaskDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskDependency
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskDependency" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskDependency" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Dependencies */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskDependency" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskDependency" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View SQL for MJ_BizApps_Tasks: Task Check Ins */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Check Ins
-- Item: vwTaskCheckIns
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Check Ins
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  TaskCheckIn
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskCheckIns" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskCheckIns" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskCheckIns" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskCheckIns" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskCheckIns" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskCheckIns" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskCheckIn" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskCheckIn" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskCheckIn" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Check Ins */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskCheckIn" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskCheckIn" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskCheckIn" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskCheckIn" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskCheckIn" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskCheckIn" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskCheckIn" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskCheckIn" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskCheckIn" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskCheckIn" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Check Ins */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskCheckIn" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskCheckIn" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskCheckIn" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View SQL for MJ_BizApps_Tasks: Task Decisions */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decisions
-- Item: vwTaskDecisions
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Decisions
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  TaskDecision
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskDecisions" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskDecisions" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskDecisions" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskDecisions" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Decisions */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Decisions
-- Item: Permissions for vwTaskDecisions
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskDecisions" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskDecisions" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskDecisions" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskDecisions" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskDecision" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskDecision" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskDecision" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Decisions */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskDecision" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskDecision" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskDecision" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskDecision" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskDecision" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskDecision" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskDecision" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskDecision" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskDecision" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskDecision" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskDecision" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskDecision" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Decisions */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskDecision" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskDecision" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskDecision" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View SQL for MJ_BizApps_Tasks: Task Template Item Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
-- Item: vwTaskTemplateItemDependencies
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Template Item Dependencies
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  TaskTemplateItemDependency
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItemDependencies" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItemDependencies" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItemDependencies" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTemplateItemDependencies" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Template Item Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
-- Item: Permissions for vwTaskTemplateItemDependencies
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItemDependencies" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItemDependencies" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItemDependencies" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTemplateItemDependencies" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Template Item Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
-- Item: spCreateTaskTemplateItemDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTemplateItemDependency
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItemDependency" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItemDependency" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItemDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Template Item Dependencies */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItemDependency" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItemDependency" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItemDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Template Item Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
-- Item: spUpdateTaskTemplateItemDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTemplateItemDependency
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItemDependency" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItemDependency" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItemDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItemDependency" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItemDependency" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItemDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Template Item Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
-- Item: spDeleteTaskTemplateItemDependency
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTemplateItemDependency
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItemDependency" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItemDependency" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItemDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Template Item Dependencies */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItemDependency" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItemDependency" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItemDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View SQL for MJ_BizApps_Tasks: Task Notification Logs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Logs
-- Item: vwTaskNotificationLogs
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Notification Logs
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  TaskNotificationLog
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskNotificationLogs" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskNotificationLogs" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskNotificationLogs" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskNotificationLogs" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Notification Logs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Logs
-- Item: Permissions for vwTaskNotificationLogs
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskNotificationLogs" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskNotificationLogs" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskNotificationLogs" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskNotificationLogs" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Notification Logs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Logs
-- Item: spCreateTaskNotificationLog
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskNotificationLog
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskNotificationLog" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskNotificationLog" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskNotificationLog" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Notification Logs */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskNotificationLog" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskNotificationLog" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskNotificationLog" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Notification Logs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Logs
-- Item: spUpdateTaskNotificationLog
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskNotificationLog
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskNotificationLog" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskNotificationLog" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskNotificationLog" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskNotificationLog" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskNotificationLog" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskNotificationLog" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Notification Logs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Logs
-- Item: spDeleteTaskNotificationLog
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskNotificationLog
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskNotificationLog" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskNotificationLog" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskNotificationLog" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Notification Logs */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskNotificationLog" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskNotificationLog" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskNotificationLog" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View SQL for MJ_BizApps_Tasks: Task Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Links
-- Item: vwTaskLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Links
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  TaskLink
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskLinks" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskLinks" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskLinks" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskLinks" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Links
-- Item: Permissions for vwTaskLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskLinks" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskLinks" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskLinks" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskLinks" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Links
-- Item: spCreateTaskLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskLink
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskLink" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskLink" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Links */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskLink" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskLink" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Links
-- Item: spUpdateTaskLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskLink
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskLink" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskLink" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskLink" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskLink" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Links
-- Item: spDeleteTaskLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskLink
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskLink" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskLink" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Links */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskLink" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskLink" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View SQL for MJ_BizApps_Tasks: Task Tag Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tag Links
-- Item: vwTaskTagLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Tag Links
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  TaskTagLink
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTagLinks" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTagLinks" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTagLinks" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTagLinks" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Tag Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tag Links
-- Item: Permissions for vwTaskTagLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTagLinks" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTagLinks" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTagLinks" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTagLinks" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Tag Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tag Links
-- Item: spCreateTaskTagLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTagLink
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTagLink" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTagLink" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTagLink" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Tag Links */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTagLink" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTagLink" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTagLink" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Tag Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tag Links
-- Item: spUpdateTaskTagLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTagLink
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTagLink" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTagLink" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTagLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTagLink" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTagLink" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTagLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Tag Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tag Links
-- Item: spDeleteTaskTagLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTagLink
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTagLink" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTagLink" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTagLink" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Tag Links */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTagLink" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTagLink" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTagLink" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View SQL for MJ_BizApps_Tasks: Task Template Item Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Roles
-- Item: vwTaskTemplateItemRoles
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Template Item Roles
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  TaskTemplateItemRole
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItemRoles" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItemRoles" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItemRoles" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTemplateItemRoles" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Template Item Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Roles
-- Item: Permissions for vwTaskTemplateItemRoles
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItemRoles" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItemRoles" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItemRoles" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTemplateItemRoles" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Template Item Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Roles
-- Item: spCreateTaskTemplateItemRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTemplateItemRole
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItemRole" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItemRole" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItemRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Template Item Roles */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItemRole" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItemRole" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItemRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Template Item Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Roles
-- Item: spUpdateTaskTemplateItemRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTemplateItemRole
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItemRole" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItemRole" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItemRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItemRole" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItemRole" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItemRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Template Item Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Roles
-- Item: spDeleteTaskTemplateItemRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTemplateItemRole
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItemRole" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItemRole" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItemRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Template Item Roles */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItemRole" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItemRole" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItemRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTypes" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTypes" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTypes" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTypes" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Types
-- Item: Permissions for vwTaskTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTypes" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTypes" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTypes" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTypes" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskType" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskType" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Types */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskType" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskType" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskType" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskType" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskType" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskType" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskType" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskType" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Types */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskType" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskType" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Hierarchy Metadata Function SQL for MJ_BizApps_Tasks: Task Template Items.ParentItemID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: fnTaskTemplateItemParentItemID_GetHierarchyMeta
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- HIERARCHY METADATA FUNCTION FOR: [TaskTemplateItem].[ParentItemID]
------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItems" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItems" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItems" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTemplateItems" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Template Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: Permissions for vwTaskTemplateItems
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItems" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItems" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTemplateItems" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTemplateItems" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Template Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: spCreateTaskTemplateItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTemplateItem
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItem" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItem" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Template Items */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItem" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItem" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTemplateItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Template Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: spUpdateTaskTemplateItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTemplateItem
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItem" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItem" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItem" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItem" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTemplateItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Template Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: spDeleteTaskTemplateItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTemplateItem
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItem" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItem" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Template Items */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItem" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItem" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTemplateItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View SQL for MJ_BizApps_Tasks: Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: vwTasksGenerated
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Tasks
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  Task
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTask" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTask" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTask" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTask" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Tasks */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTask" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTask" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTask" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
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
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTask" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTask" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTask" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTask" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTask" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
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
/* Base View SQL for MJ_BizApps_Tasks: Task Type Status */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Type Status
-- Item: vwTaskTypeStatus
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Type Status
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  TaskTypeStatus
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTypeStatus" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTypeStatus" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTypeStatus" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTypeStatus" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Type Status */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Type Status
-- Item: Permissions for vwTaskTypeStatus
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTypeStatus" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTypeStatus" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTaskTypeStatus" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTypeStatus" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Type Status */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Type Status
-- Item: spCreateTaskTypeStatus
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTypeStatus
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTypeStatus" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTypeStatus" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTypeStatus" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Type Status */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTypeStatus" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTypeStatus" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTypeStatus" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Type Status */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Type Status
-- Item: spUpdateTaskTypeStatus
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTypeStatus
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTypeStatus" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTypeStatus" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTypeStatus" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTypeStatus" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTypeStatus" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTypeStatus" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Type Status */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Type Status
-- Item: spDeleteTaskTypeStatus
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTypeStatus
------------------------------------------------------------;

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTypeStatus" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTypeStatus" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTypeStatus" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Type Status */

DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTypeStatus" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN REVOKE EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTypeStatus" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTypeStatus" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View SQL for MJ_BizApps_Tasks: Work Report Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Report Items
-- Item: vwWorkReportItems
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Work Report Items
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  WorkReportItem
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwWorkReportItems" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Work Report Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Report Items
-- Item: Permissions for vwWorkReportItems
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwWorkReportItems" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Work Report Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Report Items
-- Item: spCreateWorkReportItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR WorkReportItem
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateWorkReportItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Work Report Items */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateWorkReportItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Work Report Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Report Items
-- Item: spUpdateWorkReportItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR WorkReportItem
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateWorkReportItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateWorkReportItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Work Report Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Report Items
-- Item: spDeleteWorkReportItem
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR WorkReportItem
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteWorkReportItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Work Report Items */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteWorkReportItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* SQL text to update entity field related entity name field map for entity field ID 0E7A4D77-5AD4-408A-8331-EE2D6CF84149 */

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwWorkReports" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Work Reports */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Reports
-- Item: Permissions for vwWorkReports
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwWorkReports" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Work Reports */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Reports
-- Item: spCreateWorkReport
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR WorkReport
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateWorkReport" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Work Reports */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateWorkReport" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Work Reports */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Reports
-- Item: spUpdateWorkReport
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR WorkReport
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateWorkReport" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateWorkReport" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Work Reports */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Work Reports
-- Item: spDeleteWorkReport
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR WorkReport
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteWorkReport" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Work Reports */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteWorkReport" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* SQL text to insert 4 new entity field(s) */


-- ===================== Comments =====================

COMMENT ON COLUMN __mj_BizAppsTasks."TaskType"."ExtensionEntity" IS 'Optional MemberJunction Entity name (e.g. MJ_BizApps_Tasks_GitHub: GitHub Issue Tasks) of the disjoint IS-A child of MJ_BizApps_Tasks: Tasks provisioned for tasks of this type. Read declaratively by Task SubtypeSelector (TypeID.ExtensionEntity).';

COMMENT ON TABLE __mj_BizAppsTasks."WorkReport" IS 'Daily or periodic 15Five work reports summarizing what got done, what is next, blockers, and at-risk objectives for a person, drafted by their Chief of Staff and reviewed with supervisor feedback.';

COMMENT ON COLUMN __mj_BizAppsTasks."WorkReport"."PersonID" IS 'The Person record whose work is summarized in this report.';

COMMENT ON COLUMN __mj_BizAppsTasks."WorkReport"."PeriodStart" IS 'Inclusive start date of the reporting window.';

COMMENT ON COLUMN __mj_BizAppsTasks."WorkReport"."PeriodEnd" IS 'Inclusive end date of the reporting window.';

COMMENT ON COLUMN __mj_BizAppsTasks."WorkReport"."Title" IS 'Optional concise headline for the report (e.g., Daily 15Five — 2026-11-09).';

COMMENT ON COLUMN __mj_BizAppsTasks."WorkReport"."Body" IS 'Markdown body of the work report covering accomplishments, next priorities, blockers, and at-risk objectives.';

COMMENT ON COLUMN __mj_BizAppsTasks."WorkReport"."Status" IS 'Lifecycle status of the report: Draft (awaiting author approval), Submitted (approved by author, awaiting supervisor review), or Reviewed (supervisor feedback recorded).';

COMMENT ON COLUMN __mj_BizAppsTasks."WorkReport"."AuthoredByAgentRunID" IS 'Optional AI Agent Run that drafted this work report.';

COMMENT ON COLUMN __mj_BizAppsTasks."WorkReport"."SupervisorFeedback" IS 'Feedback drafted by the supervisor Chief of Staff and approved/edited by the supervisor.';

COMMENT ON COLUMN __mj_BizAppsTasks."WorkReport"."ReviewedByPersonID" IS 'The supervisor Person record who reviewed and approved feedback on this report.';

COMMENT ON COLUMN __mj_BizAppsTasks."WorkReport"."ReviewedAt" IS 'Timestamp when supervisor feedback was approved and recorded on this report.';

COMMENT ON TABLE __mj_BizAppsTasks."WorkReportItem" IS 'Individual line items in a WorkReport linking each accomplishment, next step, blocker, or at-risk item to its originating Task.';

COMMENT ON COLUMN __mj_BizAppsTasks."WorkReportItem"."WorkReportID" IS 'Parent WorkReport that owns this line item.';

COMMENT ON COLUMN __mj_BizAppsTasks."WorkReportItem"."TaskID" IS 'Optional Task referenced by this report item.';

COMMENT ON COLUMN __mj_BizAppsTasks."WorkReportItem"."Section" IS 'Report section this line belongs to: Completed, InProgress, Next, Blockers, or AtRisk.';

COMMENT ON COLUMN __mj_BizAppsTasks."WorkReportItem"."Summary" IS 'Concise description of the progress, next step, blocker, or risk for this line item.';

COMMENT ON COLUMN __mj_BizAppsTasks."WorkReportItem"."Sequence" IS 'Display order within the parent WorkReport (ascending).';


-- ===================== Other =====================

-- =============================================================================
-- GENERATED BY MemberJunction CodeGen — DO NOT EDIT BY HAND
-- =============================================================================

/* SQL generated to create new entity MJ_BizApps_Tasks: Work Reports */

/* SQL text to insert 22 new entity field(s) */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Assignments */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Activities */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Comments */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Dependencies */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Check Ins */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Decisions */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Template Item Dependencies */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Notification Logs */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Links */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Tag Links */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Template Item Roles */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Types */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Template Items */

/* Base View Permissions SQL for MJ_BizApps_Tasks: Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: Permissions for vwTasks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

/* spUpdate Permissions for MJ_BizApps_Tasks: Tasks */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Type Status */

/* spUpdate Permissions for MJ_BizApps_Tasks: Work Report Items */

/* spUpdate Permissions for MJ_BizApps_Tasks: Work Reports */
