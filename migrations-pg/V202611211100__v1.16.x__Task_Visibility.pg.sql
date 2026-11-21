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
-- Migration: V202611211100__v1.16.x__Task_Visibility.sql
-- Description: Add Visibility column ('Standard' default, 'Private' opt-in) to
--              [__mj_BizAppsTasks].[Task] so Tasks and their child entities
--              enforce Row-Level Security (RLS) matching Meetings.
-- =============================================================================

ALTER TABLE __mj_BizAppsTasks."Task"
 ADD COLUMN IF NOT EXISTS "Visibility" VARCHAR(20) NOT NULL DEFAULT 'Standard';

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint c
        JOIN pg_class t ON t.oid = c.conrelid
        JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE n.nspname = '__mj_bizappstasks'
          AND t.relname = 'Task'
          AND c.conname = 'CK_Task_Visibility'
    ) THEN
        ALTER TABLE __mj_BizAppsTasks."Task"
            ADD CONSTRAINT "CK_Task_Visibility" CHECK ("Visibility" IN ('Standard', 'Private'));
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_TypeID" ON __mj_BizAppsTasks."Task" ("TypeID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_CategoryID" ON __mj_BizAppsTasks."Task" ("CategoryID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_ParentID" ON __mj_BizAppsTasks."Task" ("ParentID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_CreatedByPersonID" ON __mj_BizAppsTasks."Task" ("CreatedByPersonID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_TaskTypeStatusID" ON __mj_BizAppsTasks."Task" ("TaskTypeStatusID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_OrganizationID" ON __mj_BizAppsTasks."Task" ("OrganizationID");


-- ===================== Views =====================

-- Drop dependent custom view vwTasks (and spCreateTask/spUpdateTask returning SETOF vwTasks)
-- so both vwTasksGenerated and vwTasks carry the new Visibility column.
DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTasks" CASCADE;
DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTasksGenerated";

CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTasksGenerated"
AS SELECT
    t.*,
    "mjBizAppsTasksTaskType_TypeID"."Name" AS "Type",
    "mjBizAppsTasksTaskCategory_CategoryID"."Name" AS "Category",
    "mjBizAppsTasksTask_ParentID"."Name" AS "Parent",
    "mjBizAppsCommonPerson_CreatedByPersonID"."DisplayName" AS "CreatedByPerson",
    "mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID"."Name" AS "TaskTypeStatus",
    "mjBizAppsCommonOrganization_OrganizationID"."Name" AS "Organization"
FROM
    __mj_BizAppsTasks."Task" AS t
LEFT OUTER JOIN
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
    t."TaskTypeStatusID" = "mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsCommon."Organization" AS "mjBizAppsCommonOrganization_OrganizationID"
  ON
    t."OrganizationID" = "mjBizAppsCommonOrganization_OrganizationID"."ID";

CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTasks"
AS
SELECT
    g.*,
    root_ParentID.root_id AS "RootParentID",
    CASE
        WHEN g."CompletedAt" IS NOT NULL AND g."DueAt" IS NOT NULL THEN
            CASE WHEN g."CompletedAt" > g."DueAt" THEN 'Breached' ELSE 'Met' END
        ELSE NULL
    END AS "IsSLABreached",
    CASE
        WHEN g."StartedAt" IS NOT NULL AND g."DueAt" IS NOT NULL THEN
            (g."DueAt" AT TIME ZONE 'UTC')::date - (g."StartedAt" AT TIME ZONE 'UTC')::date
        WHEN g."__mj_CreatedAt" IS NOT NULL AND g."DueAt" IS NOT NULL THEN
            (g."DueAt" AT TIME ZONE 'UTC')::date - (g."__mj_CreatedAt" AT TIME ZONE 'UTC')::date
        ELSE NULL
    END AS "LeadDays",
    COALESCE(a."AssignmentsCount", 0) AS "AssignmentsCount",
    COALESCE(c."CommentsCount", 0) AS "CommentsCount"
FROM
    __mj_BizAppsTasks."vwTasksGenerated" AS g
LEFT JOIN LATERAL (
    SELECT __mj_BizAppsTasks.fn_task_parent_id_get_root_id(g."ID", g."ParentID") AS root_id
) AS root_ParentID ON true
LEFT OUTER JOIN (
    SELECT "TaskID", COUNT(*)::INTEGER AS "AssignmentsCount"
    FROM __mj_BizAppsTasks."TaskAssignment"
    GROUP BY "TaskID"
) AS a ON a."TaskID" = g."ID"
LEFT OUTER JOIN (
    SELECT "TaskID", COUNT(*)::INTEGER AS "CommentsCount"
    FROM __mj_BizAppsTasks."TaskComment"
    GROUP BY "TaskID"
) AS c ON c."TaskID" = g."ID";


-- ===================== Stored Procedures (sp*) =====================

DO $$ DECLARE r record;
BEGIN
  FOR r IN SELECT oid::regprocedure AS sig FROM pg_proc
           WHERE proname = 'spCreateTask'
             AND pronamespace = '__mj_bizappstasks'::regnamespace
  LOOP EXECUTE 'DROP FUNCTION IF EXISTS ' || r.sig || ' CASCADE';
  END LOOP;
END $$;
CREATE OR REPLACE FUNCTION __mj_BizAppsTasks."spCreateTask"(
    IN p_ID UUID DEFAULT NULL,
    IN p_Name VARCHAR(255) DEFAULT NULL,
    IN p_Description_Clear BOOLEAN DEFAULT FALSE,
    IN p_Description TEXT DEFAULT NULL,
    IN p_TypeID UUID DEFAULT NULL,
    IN p_CategoryID_Clear BOOLEAN DEFAULT FALSE,
    IN p_CategoryID UUID DEFAULT NULL,
    IN p_ParentID_Clear BOOLEAN DEFAULT FALSE,
    IN p_ParentID UUID DEFAULT NULL,
    IN p_Status VARCHAR(50) DEFAULT NULL,
    IN p_Priority VARCHAR(20) DEFAULT NULL,
    IN p_StartedAt_Clear BOOLEAN DEFAULT FALSE,
    IN p_StartedAt TIMESTAMPTZ DEFAULT NULL,
    IN p_DueAt_Clear BOOLEAN DEFAULT FALSE,
    IN p_DueAt TIMESTAMPTZ DEFAULT NULL,
    IN p_CompletedAt_Clear BOOLEAN DEFAULT FALSE,
    IN p_CompletedAt TIMESTAMPTZ DEFAULT NULL,
    IN p_HoursEstimated_Clear BOOLEAN DEFAULT FALSE,
    IN p_HoursEstimated NUMERIC(8,2) DEFAULT NULL,
    IN p_HoursActual_Clear BOOLEAN DEFAULT FALSE,
    IN p_HoursActual NUMERIC(8,2) DEFAULT NULL,
    IN p_PercentComplete INTEGER DEFAULT NULL,
    IN p_Sequence INTEGER DEFAULT NULL,
    IN p_BlockedReason_Clear BOOLEAN DEFAULT FALSE,
    IN p_BlockedReason TEXT DEFAULT NULL,
    IN p_CompletionNotes_Clear BOOLEAN DEFAULT FALSE,
    IN p_CompletionNotes TEXT DEFAULT NULL,
    IN p_CreatedByPersonID_Clear BOOLEAN DEFAULT FALSE,
    IN p_CreatedByPersonID UUID DEFAULT NULL,
    IN p_OverdueNotifiedAt_Clear BOOLEAN DEFAULT FALSE,
    IN p_OverdueNotifiedAt TIMESTAMPTZ DEFAULT NULL,
    IN p_TaskTypeStatusID_Clear BOOLEAN DEFAULT FALSE,
    IN p_TaskTypeStatusID UUID DEFAULT NULL,
    IN p_PredictedSLABreachProbability_Clear BOOLEAN DEFAULT FALSE,
    IN p_PredictedSLABreachProbability NUMERIC(5,4) DEFAULT NULL,
    IN p_PredictedSLARiskBand_Clear BOOLEAN DEFAULT FALSE,
    IN p_PredictedSLARiskBand VARCHAR(20) DEFAULT NULL,
    IN p_PredictedSLAScoredAt_Clear BOOLEAN DEFAULT FALSE,
    IN p_PredictedSLAScoredAt TIMESTAMPTZ DEFAULT NULL,
    IN p_HealthStatus_Clear BOOLEAN DEFAULT FALSE,
    IN p_HealthStatus VARCHAR(20) DEFAULT NULL,
    IN p_ConfidenceScore_Clear BOOLEAN DEFAULT FALSE,
    IN p_ConfidenceScore INTEGER DEFAULT NULL,
    IN p_BaselineValue_Clear BOOLEAN DEFAULT FALSE,
    IN p_BaselineValue NUMERIC(18,4) DEFAULT NULL,
    IN p_TargetValue_Clear BOOLEAN DEFAULT FALSE,
    IN p_TargetValue NUMERIC(18,4) DEFAULT NULL,
    IN p_CurrentValue_Clear BOOLEAN DEFAULT FALSE,
    IN p_CurrentValue NUMERIC(18,4) DEFAULT NULL,
    IN p_UnitOfMeasure_Clear BOOLEAN DEFAULT FALSE,
    IN p_UnitOfMeasure VARCHAR(50) DEFAULT NULL,
    IN p_MetricDirection_Clear BOOLEAN DEFAULT FALSE,
    IN p_MetricDirection VARCHAR(20) DEFAULT NULL,
    IN p_RollupWeight NUMERIC(8,2) DEFAULT NULL,
    IN p_PlanningPeriod_Clear BOOLEAN DEFAULT FALSE,
    IN p_PlanningPeriod VARCHAR(50) DEFAULT NULL,
    IN p_CheckInCadence_Clear BOOLEAN DEFAULT FALSE,
    IN p_CheckInCadence VARCHAR(20) DEFAULT NULL,
    IN p_LastCheckInAt_Clear BOOLEAN DEFAULT FALSE,
    IN p_LastCheckInAt TIMESTAMPTZ DEFAULT NULL,
    IN p_NextCheckInDueAt_Clear BOOLEAN DEFAULT FALSE,
    IN p_NextCheckInDueAt TIMESTAMPTZ DEFAULT NULL,
    IN p_OrganizationID_Clear BOOLEAN DEFAULT FALSE,
    IN p_OrganizationID UUID DEFAULT NULL,
    IN p_Visibility VARCHAR(20) DEFAULT NULL
)
RETURNS SETOF __mj_BizAppsTasks."vwTasks" AS
$$
BEGIN
IF p_ID IS NOT NULL THEN
        -- User provided a value, use it
        INSERT INTO __mj_BizAppsTasks."Task"
            (
                "ID",
                "Name",
                "Description",
                "TypeID",
                "CategoryID",
                "ParentID",
                "Status",
                "Priority",
                "StartedAt",
                "DueAt",
                "CompletedAt",
                "HoursEstimated",
                "HoursActual",
                "PercentComplete",
                "Sequence",
                "BlockedReason",
                "CompletionNotes",
                "CreatedByPersonID",
                "OverdueNotifiedAt",
                "TaskTypeStatusID",
                "PredictedSLABreachProbability",
                "PredictedSLARiskBand",
                "PredictedSLAScoredAt",
                "HealthStatus",
                "ConfidenceScore",
                "BaselineValue",
                "TargetValue",
                "CurrentValue",
                "UnitOfMeasure",
                "MetricDirection",
                "RollupWeight",
                "PlanningPeriod",
                "CheckInCadence",
                "LastCheckInAt",
                "NextCheckInDueAt",
                "OrganizationID",
                "Visibility"
            )
        VALUES
            (
                p_ID,
                p_Name,
                CASE WHEN p_Description_Clear = TRUE THEN NULL ELSE COALESCE(p_Description, NULL) END,
                p_TypeID,
                CASE WHEN p_CategoryID_Clear = TRUE THEN NULL ELSE COALESCE(p_CategoryID, NULL) END,
                CASE WHEN p_ParentID_Clear = TRUE THEN NULL ELSE COALESCE(p_ParentID, NULL) END,
                COALESCE(p_Status, 'Open'),
                COALESCE(p_Priority, 'Medium'),
                CASE WHEN p_StartedAt_Clear = TRUE THEN NULL ELSE COALESCE(p_StartedAt, NULL) END,
                CASE WHEN p_DueAt_Clear = TRUE THEN NULL ELSE COALESCE(p_DueAt, NULL) END,
                CASE WHEN p_CompletedAt_Clear = TRUE THEN NULL ELSE COALESCE(p_CompletedAt, NULL) END,
                CASE WHEN p_HoursEstimated_Clear = TRUE THEN NULL ELSE COALESCE(p_HoursEstimated, NULL) END,
                CASE WHEN p_HoursActual_Clear = TRUE THEN NULL ELSE COALESCE(p_HoursActual, NULL) END,
                COALESCE(p_PercentComplete, 0),
                COALESCE(p_Sequence, 100),
                CASE WHEN p_BlockedReason_Clear = TRUE THEN NULL ELSE COALESCE(p_BlockedReason, NULL) END,
                CASE WHEN p_CompletionNotes_Clear = TRUE THEN NULL ELSE COALESCE(p_CompletionNotes, NULL) END,
                CASE WHEN p_CreatedByPersonID_Clear = TRUE THEN NULL ELSE COALESCE(p_CreatedByPersonID, NULL) END,
                CASE WHEN p_OverdueNotifiedAt_Clear = TRUE THEN NULL ELSE COALESCE(p_OverdueNotifiedAt, NULL) END,
                CASE WHEN p_TaskTypeStatusID_Clear = TRUE THEN NULL ELSE COALESCE(p_TaskTypeStatusID, NULL) END,
                CASE WHEN p_PredictedSLABreachProbability_Clear = TRUE THEN NULL ELSE COALESCE(p_PredictedSLABreachProbability, NULL) END,
                CASE WHEN p_PredictedSLARiskBand_Clear = TRUE THEN NULL ELSE COALESCE(p_PredictedSLARiskBand, NULL) END,
                CASE WHEN p_PredictedSLAScoredAt_Clear = TRUE THEN NULL ELSE COALESCE(p_PredictedSLAScoredAt, NULL) END,
                CASE WHEN p_HealthStatus_Clear = TRUE THEN NULL ELSE COALESCE(p_HealthStatus, NULL) END,
                CASE WHEN p_ConfidenceScore_Clear = TRUE THEN NULL ELSE COALESCE(p_ConfidenceScore, NULL) END,
                CASE WHEN p_BaselineValue_Clear = TRUE THEN NULL ELSE COALESCE(p_BaselineValue, NULL) END,
                CASE WHEN p_TargetValue_Clear = TRUE THEN NULL ELSE COALESCE(p_TargetValue, NULL) END,
                CASE WHEN p_CurrentValue_Clear = TRUE THEN NULL ELSE COALESCE(p_CurrentValue, NULL) END,
                CASE WHEN p_UnitOfMeasure_Clear = TRUE THEN NULL ELSE COALESCE(p_UnitOfMeasure, NULL) END,
                CASE WHEN p_MetricDirection_Clear = TRUE THEN NULL ELSE COALESCE(p_MetricDirection, NULL) END,
                COALESCE(p_RollupWeight, 1.00),
                CASE WHEN p_PlanningPeriod_Clear = TRUE THEN NULL ELSE COALESCE(p_PlanningPeriod, NULL) END,
                CASE WHEN p_CheckInCadence_Clear = TRUE THEN NULL ELSE COALESCE(p_CheckInCadence, NULL) END,
                CASE WHEN p_LastCheckInAt_Clear = TRUE THEN NULL ELSE COALESCE(p_LastCheckInAt, NULL) END,
                CASE WHEN p_NextCheckInDueAt_Clear = TRUE THEN NULL ELSE COALESCE(p_NextCheckInDueAt, NULL) END,
                CASE WHEN p_OrganizationID_Clear = TRUE THEN NULL ELSE COALESCE(p_OrganizationID, NULL) END,
                COALESCE(p_Visibility, 'Standard')
            );
    ELSE
        -- No value provided, let database use its default (e.g., gen_random_uuid())
        INSERT INTO __mj_BizAppsTasks."Task"
            (
                "Name",
                "Description",
                "TypeID",
                "CategoryID",
                "ParentID",
                "Status",
                "Priority",
                "StartedAt",
                "DueAt",
                "CompletedAt",
                "HoursEstimated",
                "HoursActual",
                "PercentComplete",
                "Sequence",
                "BlockedReason",
                "CompletionNotes",
                "CreatedByPersonID",
                "OverdueNotifiedAt",
                "TaskTypeStatusID",
                "PredictedSLABreachProbability",
                "PredictedSLARiskBand",
                "PredictedSLAScoredAt",
                "HealthStatus",
                "ConfidenceScore",
                "BaselineValue",
                "TargetValue",
                "CurrentValue",
                "UnitOfMeasure",
                "MetricDirection",
                "RollupWeight",
                "PlanningPeriod",
                "CheckInCadence",
                "LastCheckInAt",
                "NextCheckInDueAt",
                "OrganizationID",
                "Visibility"
            )
        VALUES
            (
                p_Name,
                CASE WHEN p_Description_Clear = TRUE THEN NULL ELSE COALESCE(p_Description, NULL) END,
                p_TypeID,
                CASE WHEN p_CategoryID_Clear = TRUE THEN NULL ELSE COALESCE(p_CategoryID, NULL) END,
                CASE WHEN p_ParentID_Clear = TRUE THEN NULL ELSE COALESCE(p_ParentID, NULL) END,
                COALESCE(p_Status, 'Open'),
                COALESCE(p_Priority, 'Medium'),
                CASE WHEN p_StartedAt_Clear = TRUE THEN NULL ELSE COALESCE(p_StartedAt, NULL) END,
                CASE WHEN p_DueAt_Clear = TRUE THEN NULL ELSE COALESCE(p_DueAt, NULL) END,
                CASE WHEN p_CompletedAt_Clear = TRUE THEN NULL ELSE COALESCE(p_CompletedAt, NULL) END,
                CASE WHEN p_HoursEstimated_Clear = TRUE THEN NULL ELSE COALESCE(p_HoursEstimated, NULL) END,
                CASE WHEN p_HoursActual_Clear = TRUE THEN NULL ELSE COALESCE(p_HoursActual, NULL) END,
                COALESCE(p_PercentComplete, 0),
                COALESCE(p_Sequence, 100),
                CASE WHEN p_BlockedReason_Clear = TRUE THEN NULL ELSE COALESCE(p_BlockedReason, NULL) END,
                CASE WHEN p_CompletionNotes_Clear = TRUE THEN NULL ELSE COALESCE(p_CompletionNotes, NULL) END,
                CASE WHEN p_CreatedByPersonID_Clear = TRUE THEN NULL ELSE COALESCE(p_CreatedByPersonID, NULL) END,
                CASE WHEN p_OverdueNotifiedAt_Clear = TRUE THEN NULL ELSE COALESCE(p_OverdueNotifiedAt, NULL) END,
                CASE WHEN p_TaskTypeStatusID_Clear = TRUE THEN NULL ELSE COALESCE(p_TaskTypeStatusID, NULL) END,
                CASE WHEN p_PredictedSLABreachProbability_Clear = TRUE THEN NULL ELSE COALESCE(p_PredictedSLABreachProbability, NULL) END,
                CASE WHEN p_PredictedSLARiskBand_Clear = TRUE THEN NULL ELSE COALESCE(p_PredictedSLARiskBand, NULL) END,
                CASE WHEN p_PredictedSLAScoredAt_Clear = TRUE THEN NULL ELSE COALESCE(p_PredictedSLAScoredAt, NULL) END,
                CASE WHEN p_HealthStatus_Clear = TRUE THEN NULL ELSE COALESCE(p_HealthStatus, NULL) END,
                CASE WHEN p_ConfidenceScore_Clear = TRUE THEN NULL ELSE COALESCE(p_ConfidenceScore, NULL) END,
                CASE WHEN p_BaselineValue_Clear = TRUE THEN NULL ELSE COALESCE(p_BaselineValue, NULL) END,
                CASE WHEN p_TargetValue_Clear = TRUE THEN NULL ELSE COALESCE(p_TargetValue, NULL) END,
                CASE WHEN p_CurrentValue_Clear = TRUE THEN NULL ELSE COALESCE(p_CurrentValue, NULL) END,
                CASE WHEN p_UnitOfMeasure_Clear = TRUE THEN NULL ELSE COALESCE(p_UnitOfMeasure, NULL) END,
                CASE WHEN p_MetricDirection_Clear = TRUE THEN NULL ELSE COALESCE(p_MetricDirection, NULL) END,
                COALESCE(p_RollupWeight, 1.00),
                CASE WHEN p_PlanningPeriod_Clear = TRUE THEN NULL ELSE COALESCE(p_PlanningPeriod, NULL) END,
                CASE WHEN p_CheckInCadence_Clear = TRUE THEN NULL ELSE COALESCE(p_CheckInCadence, NULL) END,
                CASE WHEN p_LastCheckInAt_Clear = TRUE THEN NULL ELSE COALESCE(p_LastCheckInAt, NULL) END,
                CASE WHEN p_NextCheckInDueAt_Clear = TRUE THEN NULL ELSE COALESCE(p_NextCheckInDueAt, NULL) END,
                CASE WHEN p_OrganizationID_Clear = TRUE THEN NULL ELSE COALESCE(p_OrganizationID, NULL) END,
                COALESCE(p_Visibility, 'Standard')
            );
    END IF;
    -- return the new record from the base view, which might have some calculated fields
    RETURN QUERY SELECT * FROM __mj_BizAppsTasks."vwTasks" WHERE "ID" = p_ID;
END;
$$ LANGUAGE plpgsql;

DO $$ DECLARE r record;
BEGIN
  FOR r IN SELECT oid::regprocedure AS sig FROM pg_proc
           WHERE proname = 'spUpdateTask'
             AND pronamespace = '__mj_bizappstasks'::regnamespace
  LOOP EXECUTE 'DROP FUNCTION IF EXISTS ' || r.sig || ' CASCADE';
  END LOOP;
END $$;
CREATE OR REPLACE FUNCTION __mj_BizAppsTasks."spUpdateTask"(
    IN p_ID UUID,
    IN p_Name VARCHAR(255) DEFAULT NULL,
    IN p_Description_Clear BOOLEAN DEFAULT FALSE,
    IN p_Description TEXT DEFAULT NULL,
    IN p_TypeID UUID DEFAULT NULL,
    IN p_CategoryID_Clear BOOLEAN DEFAULT FALSE,
    IN p_CategoryID UUID DEFAULT NULL,
    IN p_ParentID_Clear BOOLEAN DEFAULT FALSE,
    IN p_ParentID UUID DEFAULT NULL,
    IN p_Status VARCHAR(50) DEFAULT NULL,
    IN p_Priority VARCHAR(20) DEFAULT NULL,
    IN p_StartedAt_Clear BOOLEAN DEFAULT FALSE,
    IN p_StartedAt TIMESTAMPTZ DEFAULT NULL,
    IN p_DueAt_Clear BOOLEAN DEFAULT FALSE,
    IN p_DueAt TIMESTAMPTZ DEFAULT NULL,
    IN p_CompletedAt_Clear BOOLEAN DEFAULT FALSE,
    IN p_CompletedAt TIMESTAMPTZ DEFAULT NULL,
    IN p_HoursEstimated_Clear BOOLEAN DEFAULT FALSE,
    IN p_HoursEstimated NUMERIC(8,2) DEFAULT NULL,
    IN p_HoursActual_Clear BOOLEAN DEFAULT FALSE,
    IN p_HoursActual NUMERIC(8,2) DEFAULT NULL,
    IN p_PercentComplete INTEGER DEFAULT NULL,
    IN p_Sequence INTEGER DEFAULT NULL,
    IN p_BlockedReason_Clear BOOLEAN DEFAULT FALSE,
    IN p_BlockedReason TEXT DEFAULT NULL,
    IN p_CompletionNotes_Clear BOOLEAN DEFAULT FALSE,
    IN p_CompletionNotes TEXT DEFAULT NULL,
    IN p_CreatedByPersonID_Clear BOOLEAN DEFAULT FALSE,
    IN p_CreatedByPersonID UUID DEFAULT NULL,
    IN p_OverdueNotifiedAt_Clear BOOLEAN DEFAULT FALSE,
    IN p_OverdueNotifiedAt TIMESTAMPTZ DEFAULT NULL,
    IN p_TaskTypeStatusID_Clear BOOLEAN DEFAULT FALSE,
    IN p_TaskTypeStatusID UUID DEFAULT NULL,
    IN p_PredictedSLABreachProbability_Clear BOOLEAN DEFAULT FALSE,
    IN p_PredictedSLABreachProbability NUMERIC(5,4) DEFAULT NULL,
    IN p_PredictedSLARiskBand_Clear BOOLEAN DEFAULT FALSE,
    IN p_PredictedSLARiskBand VARCHAR(20) DEFAULT NULL,
    IN p_PredictedSLAScoredAt_Clear BOOLEAN DEFAULT FALSE,
    IN p_PredictedSLAScoredAt TIMESTAMPTZ DEFAULT NULL,
    IN p_HealthStatus_Clear BOOLEAN DEFAULT FALSE,
    IN p_HealthStatus VARCHAR(20) DEFAULT NULL,
    IN p_ConfidenceScore_Clear BOOLEAN DEFAULT FALSE,
    IN p_ConfidenceScore INTEGER DEFAULT NULL,
    IN p_BaselineValue_Clear BOOLEAN DEFAULT FALSE,
    IN p_BaselineValue NUMERIC(18,4) DEFAULT NULL,
    IN p_TargetValue_Clear BOOLEAN DEFAULT FALSE,
    IN p_TargetValue NUMERIC(18,4) DEFAULT NULL,
    IN p_CurrentValue_Clear BOOLEAN DEFAULT FALSE,
    IN p_CurrentValue NUMERIC(18,4) DEFAULT NULL,
    IN p_UnitOfMeasure_Clear BOOLEAN DEFAULT FALSE,
    IN p_UnitOfMeasure VARCHAR(50) DEFAULT NULL,
    IN p_MetricDirection_Clear BOOLEAN DEFAULT FALSE,
    IN p_MetricDirection VARCHAR(20) DEFAULT NULL,
    IN p_RollupWeight NUMERIC(8,2) DEFAULT NULL,
    IN p_PlanningPeriod_Clear BOOLEAN DEFAULT FALSE,
    IN p_PlanningPeriod VARCHAR(50) DEFAULT NULL,
    IN p_CheckInCadence_Clear BOOLEAN DEFAULT FALSE,
    IN p_CheckInCadence VARCHAR(20) DEFAULT NULL,
    IN p_LastCheckInAt_Clear BOOLEAN DEFAULT FALSE,
    IN p_LastCheckInAt TIMESTAMPTZ DEFAULT NULL,
    IN p_NextCheckInDueAt_Clear BOOLEAN DEFAULT FALSE,
    IN p_NextCheckInDueAt TIMESTAMPTZ DEFAULT NULL,
    IN p_OrganizationID_Clear BOOLEAN DEFAULT FALSE,
    IN p_OrganizationID UUID DEFAULT NULL,
    IN p_Visibility VARCHAR(20) DEFAULT NULL
)
RETURNS SETOF __mj_BizAppsTasks."vwTasks" AS
$$
DECLARE
    _v_row_count INTEGER;
BEGIN
UPDATE
        __mj_BizAppsTasks."Task"
    SET
        "Name" = COALESCE(p_Name, "Name"),
        "Description" = CASE WHEN p_Description_Clear = TRUE THEN NULL ELSE COALESCE(p_Description, "Description") END,
        "TypeID" = COALESCE(p_TypeID, "TypeID"),
        "CategoryID" = CASE WHEN p_CategoryID_Clear = TRUE THEN NULL ELSE COALESCE(p_CategoryID, "CategoryID") END,
        "ParentID" = CASE WHEN p_ParentID_Clear = TRUE THEN NULL ELSE COALESCE(p_ParentID, "ParentID") END,
        "Status" = COALESCE(p_Status, "Status"),
        "Priority" = COALESCE(p_Priority, "Priority"),
        "StartedAt" = CASE WHEN p_StartedAt_Clear = TRUE THEN NULL ELSE COALESCE(p_StartedAt, "StartedAt") END,
        "DueAt" = CASE WHEN p_DueAt_Clear = TRUE THEN NULL ELSE COALESCE(p_DueAt, "DueAt") END,
        "CompletedAt" = CASE WHEN p_CompletedAt_Clear = TRUE THEN NULL ELSE COALESCE(p_CompletedAt, "CompletedAt") END,
        "HoursEstimated" = CASE WHEN p_HoursEstimated_Clear = TRUE THEN NULL ELSE COALESCE(p_HoursEstimated, "HoursEstimated") END,
        "HoursActual" = CASE WHEN p_HoursActual_Clear = TRUE THEN NULL ELSE COALESCE(p_HoursActual, "HoursActual") END,
        "PercentComplete" = COALESCE(p_PercentComplete, "PercentComplete"),
        "Sequence" = COALESCE(p_Sequence, "Sequence"),
        "BlockedReason" = CASE WHEN p_BlockedReason_Clear = TRUE THEN NULL ELSE COALESCE(p_BlockedReason, "BlockedReason") END,
        "CompletionNotes" = CASE WHEN p_CompletionNotes_Clear = TRUE THEN NULL ELSE COALESCE(p_CompletionNotes, "CompletionNotes") END,
        "CreatedByPersonID" = CASE WHEN p_CreatedByPersonID_Clear = TRUE THEN NULL ELSE COALESCE(p_CreatedByPersonID, "CreatedByPersonID") END,
        "OverdueNotifiedAt" = CASE WHEN p_OverdueNotifiedAt_Clear = TRUE THEN NULL ELSE COALESCE(p_OverdueNotifiedAt, "OverdueNotifiedAt") END,
        "TaskTypeStatusID" = CASE WHEN p_TaskTypeStatusID_Clear = TRUE THEN NULL ELSE COALESCE(p_TaskTypeStatusID, "TaskTypeStatusID") END,
        "PredictedSLABreachProbability" = CASE WHEN p_PredictedSLABreachProbability_Clear = TRUE THEN NULL ELSE COALESCE(p_PredictedSLABreachProbability, "PredictedSLABreachProbability") END,
        "PredictedSLARiskBand" = CASE WHEN p_PredictedSLARiskBand_Clear = TRUE THEN NULL ELSE COALESCE(p_PredictedSLARiskBand, "PredictedSLARiskBand") END,
        "PredictedSLAScoredAt" = CASE WHEN p_PredictedSLAScoredAt_Clear = TRUE THEN NULL ELSE COALESCE(p_PredictedSLAScoredAt, "PredictedSLAScoredAt") END,
        "HealthStatus" = CASE WHEN p_HealthStatus_Clear = TRUE THEN NULL ELSE COALESCE(p_HealthStatus, "HealthStatus") END,
        "ConfidenceScore" = CASE WHEN p_ConfidenceScore_Clear = TRUE THEN NULL ELSE COALESCE(p_ConfidenceScore, "ConfidenceScore") END,
        "BaselineValue" = CASE WHEN p_BaselineValue_Clear = TRUE THEN NULL ELSE COALESCE(p_BaselineValue, "BaselineValue") END,
        "TargetValue" = CASE WHEN p_TargetValue_Clear = TRUE THEN NULL ELSE COALESCE(p_TargetValue, "TargetValue") END,
        "CurrentValue" = CASE WHEN p_CurrentValue_Clear = TRUE THEN NULL ELSE COALESCE(p_CurrentValue, "CurrentValue") END,
        "UnitOfMeasure" = CASE WHEN p_UnitOfMeasure_Clear = TRUE THEN NULL ELSE COALESCE(p_UnitOfMeasure, "UnitOfMeasure") END,
        "MetricDirection" = CASE WHEN p_MetricDirection_Clear = TRUE THEN NULL ELSE COALESCE(p_MetricDirection, "MetricDirection") END,
        "RollupWeight" = COALESCE(p_RollupWeight, "RollupWeight"),
        "PlanningPeriod" = CASE WHEN p_PlanningPeriod_Clear = TRUE THEN NULL ELSE COALESCE(p_PlanningPeriod, "PlanningPeriod") END,
        "CheckInCadence" = CASE WHEN p_CheckInCadence_Clear = TRUE THEN NULL ELSE COALESCE(p_CheckInCadence, "CheckInCadence") END,
        "LastCheckInAt" = CASE WHEN p_LastCheckInAt_Clear = TRUE THEN NULL ELSE COALESCE(p_LastCheckInAt, "LastCheckInAt") END,
        "NextCheckInDueAt" = CASE WHEN p_NextCheckInDueAt_Clear = TRUE THEN NULL ELSE COALESCE(p_NextCheckInDueAt, "NextCheckInDueAt") END,
        "OrganizationID" = CASE WHEN p_OrganizationID_Clear = TRUE THEN NULL ELSE COALESCE(p_OrganizationID, "OrganizationID") END,
        "Visibility" = COALESCE(p_Visibility, "Visibility"),
        "__mj_UpdatedAt" = NOW()
    WHERE
        "ID" = p_ID;

    GET DIAGNOSTICS _v_row_count = ROW_COUNT;

    IF _v_row_count = 0 THEN
        RETURN QUERY SELECT * FROM __mj_BizAppsTasks."vwTasks" WHERE 1=0;
    ELSE
        RETURN QUERY SELECT * FROM __mj_BizAppsTasks."vwTasks" WHERE "ID" = p_ID;
    END IF;
END;
$$ LANGUAGE plpgsql;

DO $$ DECLARE r record;
BEGIN
  FOR r IN SELECT oid::regprocedure AS sig FROM pg_proc
           WHERE proname = 'spDeleteTask'
             AND pronamespace = '__mj_bizappstasks'::regnamespace
  LOOP EXECUTE 'DROP FUNCTION IF EXISTS ' || r.sig || ' CASCADE';
  END LOOP;
END $$;
CREATE OR REPLACE FUNCTION __mj_BizAppsTasks."spDeleteTask"(
    IN p_ID UUID
)
RETURNS TABLE("_result_id" UUID) AS
$$
DECLARE
    _v_row_count INTEGER;
BEGIN
DELETE FROM
        __mj_BizAppsTasks."Task"
    WHERE
        "ID" = p_ID;

    GET DIAGNOSTICS _v_row_count = ROW_COUNT;

    IF _v_row_count = 0 THEN
        RETURN QUERY SELECT NULL::UUID AS "_result_id";
    ELSE
        RETURN QUERY SELECT p_ID::UUID AS "_result_id";
    END IF;
END;
$$ LANGUAGE plpgsql;


-- ===================== Triggers =====================

CREATE OR REPLACE FUNCTION __mj_BizAppsTasks."trgUpdateTask_func"()
RETURNS TRIGGER AS $$
BEGIN
    NEW."__mj_UpdatedAt" = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS "trgUpdateTask" ON __mj_BizAppsTasks."Task";
CREATE TRIGGER "trgUpdateTask"
    BEFORE UPDATE ON __mj_BizAppsTasks."Task"
    FOR EACH ROW
    EXECUTE FUNCTION __mj_BizAppsTasks."trgUpdateTask_func"();


-- ===================== Data (INSERT/UPDATE/DELETE) =====================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '3823d7f6-c43c-496d-b351-f1e3731d7719' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'Visibility')
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
        '3823d7f6-c43c-496d-b351-f1e3731d7719',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'Visibility',
        'Visibility',
        'Controls who may read this task and its child records (assignments, check-ins, comments, activities). Standard (default) is visible across the organization; Private restricts visibility to the creator, assignees (direct Person or MJ Role members), and creator/assignees of the root parent task.',
        'nvarchar',
        40,
        0,
        0,
        FALSE,
        'Standard',
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
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "Source", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('3557b267-ca22-4476-b28e-aaa1cb423c6b', '3823D7F6-C43C-496D-B351-F1E3731D7719', 1, 'Private', 'Private', 'Check', NOW(), NOW());

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "Source", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('8e42028d-f756-47cd-b07b-4a94261453df', '3823D7F6-C43C-496D-B351-F1E3731D7719', 2, 'Standard', 'Standard', 'Check', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 3823D7F6-C43C-496D-B351-F1E3731D7719 */

UPDATE ${mjSchema}."EntityField" SET "ValueListType"='List' WHERE "ID"='3823D7F6-C43C-496D-B351-F1E3731D7719';

/* SQL text to sync schema info from database schemas */


-- ===================== Grants =====================

DO $$
BEGIN
    IF to_regclass('__mj_BizAppsTasks."vwTasks"') IS NOT NULL THEN
        BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTasks" FROM "cdp_Developer"; EXCEPTION WHEN others THEN NULL; END;
        BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTasks" FROM "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END;
        BEGIN REVOKE SELECT ON __mj_BizAppsTasks."vwTasks" FROM "cdp_UI"; EXCEPTION WHEN others THEN NULL; END;
        BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTasks" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END;
    END IF;
    IF to_regclass('__mj_BizAppsTasks."vwTasksGenerated"') IS NOT NULL THEN
        BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTasksGenerated" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END;
    END IF;
END $$;

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
/* SQL text to update existing entity fields from schema (1 scoped entities) */


-- ===================== Comments =====================

COMMENT ON COLUMN __mj_BizAppsTasks."Task"."Visibility" IS 'Controls who may read this task and its child records (assignments, check-ins, comments, activities). Standard (default) is visible across the organization; Private restricts visibility to the creator, assignees (direct Person or MJ Role members), and creator/assignees of the root parent task.';


-- ===================== Other =====================

-- =============================================================================
-- GENERATED BY MemberJunction CodeGen — DO NOT EDIT BY HAND
-- Contains EntityField/EntityFieldValue inserts, FK index checks, vwTasksGenerated
-- + vwTasks refresh, spCreateTask/spUpdateTask/spDeleteTask, trgUpdateTask, and
-- permissions for Task.Visibility. (spDeleteUnneededEntityFields omitted per CI guard.)
-- =============================================================================

/* SQL text to update existing entities from schema */

/* Views vwTasksGenerated and vwTasks rebuilt above with Visibility column */

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

/* Views vwTasksGenerated and vwTasks rebuilt above with Visibility column */
