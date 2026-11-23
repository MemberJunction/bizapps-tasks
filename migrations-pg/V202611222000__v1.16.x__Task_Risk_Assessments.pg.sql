-- ============================================================================
-- MemberJunction PostgreSQL Migration
-- Counterpart of migrations/V202611222000__v1.16.x__Task_Risk_Assessments.sql
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE SCHEMA IF NOT EXISTS __mj_BizAppsTasks;
SET search_path TO __mj_BizAppsTasks, public;
SET standard_conforming_strings = on;

-- ===================== DDL: Tables, PKs, Indexes =====================

ALTER TABLE __mj_BizAppsTasks."Task"
    ADD COLUMN IF NOT EXISTS "ForecastCompletionDate" TIMESTAMPTZ NULL;

CREATE TABLE IF NOT EXISTS __mj_BizAppsTasks."TaskRiskAssessment" (
    "ID"                     UUID NOT NULL DEFAULT gen_random_uuid(),
    "TaskID"                 UUID NOT NULL,
    "AssessedAt"             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "ForecastCompletionDate" TIMESTAMPTZ NULL,
    "ForecastConfidence"     INTEGER NULL,
    "HealthStatus"           VARCHAR(20) NOT NULL DEFAULT 'OnTrack',
    "MLBreachProbability"    NUMERIC(5, 4) NULL,
    "Risks"                  TEXT NOT NULL DEFAULT '[]',
    "AgentRunID"             UUID NULL,
    "PromptTokens"           INTEGER NULL,
    "CompletionTokens"       INTEGER NULL,
    "TotalCostUSD"           NUMERIC(19, 8) NULL,
    "__mj_CreatedAt"         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "__mj_UpdatedAt"         TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT "PK_TaskRiskAssessment" PRIMARY KEY ("ID"),
    CONSTRAINT "FK_TaskRiskAssessment_Task"
        FOREIGN KEY ("TaskID") REFERENCES __mj_BizAppsTasks."Task"("ID"),
    CONSTRAINT "FK_TaskRiskAssessment_AIAgentRun"
        FOREIGN KEY ("AgentRunID") REFERENCES ${mjSchema}."AIAgentRun"("ID"),
    CONSTRAINT "CK_TaskRiskAssessment_ForecastConfidence"
        CHECK ("ForecastConfidence" IS NULL OR ("ForecastConfidence" >= 0 AND "ForecastConfidence" <= 100)),
    CONSTRAINT "CK_TaskRiskAssessment_HealthStatus"
        CHECK ("HealthStatus" IN ('OnTrack', 'AtRisk', 'OffTrack', 'Completed', 'Paused')),
    CONSTRAINT "CK_TaskRiskAssessment_MLBreachProbability"
        CHECK ("MLBreachProbability" IS NULL OR ("MLBreachProbability" >= 0 AND "MLBreachProbability" <= 1)),
    CONSTRAINT "CK_TaskRiskAssessment_Risks_JSON"
        CHECK (jsonb_typeof("Risks"::jsonb) = 'array'),
    CONSTRAINT "CK_TaskRiskAssessment_PromptTokens"
        CHECK ("PromptTokens" IS NULL OR "PromptTokens" >= 0),
    CONSTRAINT "CK_TaskRiskAssessment_CompletionTokens"
        CHECK ("CompletionTokens" IS NULL OR "CompletionTokens" >= 0),
    CONSTRAINT "CK_TaskRiskAssessment_TotalCostUSD"
        CHECK ("TotalCostUSD" IS NULL OR "TotalCostUSD" >= 0)
);

CREATE INDEX IF NOT EXISTS "IX_TaskRiskAssessment_Task_AssessedAt"
    ON __mj_BizAppsTasks."TaskRiskAssessment" ("TaskID", "AssessedAt" DESC);

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskRiskAssessment_TaskID"
    ON __mj_BizAppsTasks."TaskRiskAssessment" ("TaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskRiskAssessment_AgentRunID"
    ON __mj_BizAppsTasks."TaskRiskAssessment" ("AgentRunID");

-- ===================== Views =====================

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskRiskAssessments" CASCADE;
CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskRiskAssessments"
AS
SELECT
    tra.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "MJAIAgentRun_AgentRunID"."RunName" AS "AgentRun"
FROM
    __mj_BizAppsTasks."TaskRiskAssessment" AS tra
LEFT OUTER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    tra."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."AIAgentRun" AS "MJAIAgentRun_AgentRunID"
  ON
    tra."AgentRunID" = "MJAIAgentRun_AgentRunID"."ID";

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
           WHERE proname = 'spCreateTaskRiskAssessment'
             AND pronamespace = '__mj_bizappstasks'::regnamespace
  LOOP EXECUTE 'DROP FUNCTION IF EXISTS ' || r.sig || ' CASCADE';
  END LOOP;
END $$;
CREATE OR REPLACE FUNCTION __mj_BizAppsTasks."spCreateTaskRiskAssessment"(
    IN p_ID UUID DEFAULT NULL,
    IN p_TaskID UUID DEFAULT NULL,
    IN p_AssessedAt TIMESTAMPTZ DEFAULT NULL,
    IN p_ForecastCompletionDate_Clear BOOLEAN DEFAULT FALSE,
    IN p_ForecastCompletionDate TIMESTAMPTZ DEFAULT NULL,
    IN p_ForecastConfidence_Clear BOOLEAN DEFAULT FALSE,
    IN p_ForecastConfidence INTEGER DEFAULT NULL,
    IN p_HealthStatus VARCHAR(20) DEFAULT NULL,
    IN p_MLBreachProbability_Clear BOOLEAN DEFAULT FALSE,
    IN p_MLBreachProbability NUMERIC(5,4) DEFAULT NULL,
    IN p_Risks TEXT DEFAULT NULL,
    IN p_AgentRunID_Clear BOOLEAN DEFAULT FALSE,
    IN p_AgentRunID UUID DEFAULT NULL,
    IN p_PromptTokens_Clear BOOLEAN DEFAULT FALSE,
    IN p_PromptTokens INTEGER DEFAULT NULL,
    IN p_CompletionTokens_Clear BOOLEAN DEFAULT FALSE,
    IN p_CompletionTokens INTEGER DEFAULT NULL,
    IN p_TotalCostUSD_Clear BOOLEAN DEFAULT FALSE,
    IN p_TotalCostUSD NUMERIC(19,8) DEFAULT NULL
)
RETURNS SETOF __mj_BizAppsTasks."vwTaskRiskAssessments" AS
$$
DECLARE
    _v_id UUID;
BEGIN
    IF p_ID IS NOT NULL THEN
        INSERT INTO __mj_BizAppsTasks."TaskRiskAssessment"
            (
                "ID", "TaskID", "AssessedAt", "ForecastCompletionDate", "ForecastConfidence",
                "HealthStatus", "MLBreachProbability", "Risks", "AgentRunID",
                "PromptTokens", "CompletionTokens", "TotalCostUSD"
            )
        VALUES
            (
                p_ID,
                p_TaskID,
                COALESCE(p_AssessedAt, NOW()),
                CASE WHEN p_ForecastCompletionDate_Clear = TRUE THEN NULL ELSE COALESCE(p_ForecastCompletionDate, NULL) END,
                CASE WHEN p_ForecastConfidence_Clear = TRUE THEN NULL ELSE COALESCE(p_ForecastConfidence, NULL) END,
                COALESCE(p_HealthStatus, 'OnTrack'),
                CASE WHEN p_MLBreachProbability_Clear = TRUE THEN NULL ELSE COALESCE(p_MLBreachProbability, NULL) END,
                COALESCE(p_Risks, '[]'),
                CASE WHEN p_AgentRunID_Clear = TRUE THEN NULL ELSE COALESCE(p_AgentRunID, NULL) END,
                CASE WHEN p_PromptTokens_Clear = TRUE THEN NULL ELSE COALESCE(p_PromptTokens, NULL) END,
                CASE WHEN p_CompletionTokens_Clear = TRUE THEN NULL ELSE COALESCE(p_CompletionTokens, NULL) END,
                CASE WHEN p_TotalCostUSD_Clear = TRUE THEN NULL ELSE COALESCE(p_TotalCostUSD, NULL) END
            )
        RETURNING "ID" INTO _v_id;
    ELSE
        INSERT INTO __mj_BizAppsTasks."TaskRiskAssessment"
            (
                "TaskID", "AssessedAt", "ForecastCompletionDate", "ForecastConfidence",
                "HealthStatus", "MLBreachProbability", "Risks", "AgentRunID",
                "PromptTokens", "CompletionTokens", "TotalCostUSD"
            )
        VALUES
            (
                p_TaskID,
                COALESCE(p_AssessedAt, NOW()),
                CASE WHEN p_ForecastCompletionDate_Clear = TRUE THEN NULL ELSE COALESCE(p_ForecastCompletionDate, NULL) END,
                CASE WHEN p_ForecastConfidence_Clear = TRUE THEN NULL ELSE COALESCE(p_ForecastConfidence, NULL) END,
                COALESCE(p_HealthStatus, 'OnTrack'),
                CASE WHEN p_MLBreachProbability_Clear = TRUE THEN NULL ELSE COALESCE(p_MLBreachProbability, NULL) END,
                COALESCE(p_Risks, '[]'),
                CASE WHEN p_AgentRunID_Clear = TRUE THEN NULL ELSE COALESCE(p_AgentRunID, NULL) END,
                CASE WHEN p_PromptTokens_Clear = TRUE THEN NULL ELSE COALESCE(p_PromptTokens, NULL) END,
                CASE WHEN p_CompletionTokens_Clear = TRUE THEN NULL ELSE COALESCE(p_CompletionTokens, NULL) END,
                CASE WHEN p_TotalCostUSD_Clear = TRUE THEN NULL ELSE COALESCE(p_TotalCostUSD, NULL) END
            )
        RETURNING "ID" INTO _v_id;
    END IF;
    RETURN QUERY SELECT * FROM __mj_BizAppsTasks."vwTaskRiskAssessments" WHERE "ID" = _v_id;
END;
$$ LANGUAGE plpgsql;

DO $$ DECLARE r record;
BEGIN
  FOR r IN SELECT oid::regprocedure AS sig FROM pg_proc
           WHERE proname = 'spUpdateTaskRiskAssessment'
             AND pronamespace = '__mj_bizappstasks'::regnamespace
  LOOP EXECUTE 'DROP FUNCTION IF EXISTS ' || r.sig || ' CASCADE';
  END LOOP;
END $$;
CREATE OR REPLACE FUNCTION __mj_BizAppsTasks."spUpdateTaskRiskAssessment"(
    IN p_ID UUID,
    IN p_TaskID UUID DEFAULT NULL,
    IN p_AssessedAt TIMESTAMPTZ DEFAULT NULL,
    IN p_ForecastCompletionDate_Clear BOOLEAN DEFAULT FALSE,
    IN p_ForecastCompletionDate TIMESTAMPTZ DEFAULT NULL,
    IN p_ForecastConfidence_Clear BOOLEAN DEFAULT FALSE,
    IN p_ForecastConfidence INTEGER DEFAULT NULL,
    IN p_HealthStatus VARCHAR(20) DEFAULT NULL,
    IN p_MLBreachProbability_Clear BOOLEAN DEFAULT FALSE,
    IN p_MLBreachProbability NUMERIC(5,4) DEFAULT NULL,
    IN p_Risks TEXT DEFAULT NULL,
    IN p_AgentRunID_Clear BOOLEAN DEFAULT FALSE,
    IN p_AgentRunID UUID DEFAULT NULL,
    IN p_PromptTokens_Clear BOOLEAN DEFAULT FALSE,
    IN p_PromptTokens INTEGER DEFAULT NULL,
    IN p_CompletionTokens_Clear BOOLEAN DEFAULT FALSE,
    IN p_CompletionTokens INTEGER DEFAULT NULL,
    IN p_TotalCostUSD_Clear BOOLEAN DEFAULT FALSE,
    IN p_TotalCostUSD NUMERIC(19,8) DEFAULT NULL
)
RETURNS SETOF __mj_BizAppsTasks."vwTaskRiskAssessments" AS
$$
DECLARE
    _v_row_count INTEGER;
BEGIN
    UPDATE
        __mj_BizAppsTasks."TaskRiskAssessment"
    SET
        "TaskID" = COALESCE(p_TaskID, "TaskID"),
        "AssessedAt" = COALESCE(p_AssessedAt, "AssessedAt"),
        "ForecastCompletionDate" = CASE WHEN p_ForecastCompletionDate_Clear = TRUE THEN NULL ELSE COALESCE(p_ForecastCompletionDate, "ForecastCompletionDate") END,
        "ForecastConfidence" = CASE WHEN p_ForecastConfidence_Clear = TRUE THEN NULL ELSE COALESCE(p_ForecastConfidence, "ForecastConfidence") END,
        "HealthStatus" = COALESCE(p_HealthStatus, "HealthStatus"),
        "MLBreachProbability" = CASE WHEN p_MLBreachProbability_Clear = TRUE THEN NULL ELSE COALESCE(p_MLBreachProbability, "MLBreachProbability") END,
        "Risks" = COALESCE(p_Risks, "Risks"),
        "AgentRunID" = CASE WHEN p_AgentRunID_Clear = TRUE THEN NULL ELSE COALESCE(p_AgentRunID, "AgentRunID") END,
        "PromptTokens" = CASE WHEN p_PromptTokens_Clear = TRUE THEN NULL ELSE COALESCE(p_PromptTokens, "PromptTokens") END,
        "CompletionTokens" = CASE WHEN p_CompletionTokens_Clear = TRUE THEN NULL ELSE COALESCE(p_CompletionTokens, "CompletionTokens") END,
        "TotalCostUSD" = CASE WHEN p_TotalCostUSD_Clear = TRUE THEN NULL ELSE COALESCE(p_TotalCostUSD, "TotalCostUSD") END,
        "__mj_UpdatedAt" = NOW()
    WHERE
        "ID" = p_ID;

    GET DIAGNOSTICS _v_row_count = ROW_COUNT;

    IF _v_row_count = 0 THEN
        RETURN QUERY SELECT * FROM __mj_BizAppsTasks."vwTaskRiskAssessments" WHERE 1=0;
    ELSE
        RETURN QUERY SELECT * FROM __mj_BizAppsTasks."vwTaskRiskAssessments" WHERE "ID" = p_ID;
    END IF;
END;
$$ LANGUAGE plpgsql;

DO $$ DECLARE r record;
BEGIN
  FOR r IN SELECT oid::regprocedure AS sig FROM pg_proc
           WHERE proname = 'spDeleteTaskRiskAssessment'
             AND pronamespace = '__mj_bizappstasks'::regnamespace
  LOOP EXECUTE 'DROP FUNCTION IF EXISTS ' || r.sig || ' CASCADE';
  END LOOP;
END $$;
CREATE OR REPLACE FUNCTION __mj_BizAppsTasks."spDeleteTaskRiskAssessment"(
    IN p_ID UUID
)
RETURNS TABLE("_result_id" UUID) AS
$$
DECLARE
    _v_row_count INTEGER;
BEGIN
    DELETE FROM
        __mj_BizAppsTasks."TaskRiskAssessment"
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
    IN p_Visibility VARCHAR(20) DEFAULT NULL,
    IN p_ForecastCompletionDate_Clear BOOLEAN DEFAULT FALSE,
    IN p_ForecastCompletionDate TIMESTAMPTZ DEFAULT NULL
)
RETURNS SETOF __mj_BizAppsTasks."vwTasks" AS
$$
DECLARE
    _v_id UUID;
BEGIN
    IF p_ID IS NOT NULL THEN
        INSERT INTO __mj_BizAppsTasks."Task"
            (
                "ID", "Name", "Description", "TypeID", "CategoryID", "ParentID",
                "Status", "Priority", "StartedAt", "DueAt", "CompletedAt",
                "HoursEstimated", "HoursActual", "PercentComplete", "Sequence",
                "BlockedReason", "CompletionNotes", "CreatedByPersonID",
                "OverdueNotifiedAt", "TaskTypeStatusID",
                "PredictedSLABreachProbability", "PredictedSLARiskBand", "PredictedSLAScoredAt",
                "HealthStatus", "ConfidenceScore", "BaselineValue", "TargetValue", "CurrentValue",
                "UnitOfMeasure", "MetricDirection", "RollupWeight", "PlanningPeriod",
                "CheckInCadence", "LastCheckInAt", "NextCheckInDueAt",
                "OrganizationID", "Visibility", "ForecastCompletionDate"
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
                COALESCE(p_Visibility, 'Standard'),
                CASE WHEN p_ForecastCompletionDate_Clear = TRUE THEN NULL ELSE COALESCE(p_ForecastCompletionDate, NULL) END
            )
        RETURNING "ID" INTO _v_id;
    ELSE
        INSERT INTO __mj_BizAppsTasks."Task"
            (
                "Name", "Description", "TypeID", "CategoryID", "ParentID",
                "Status", "Priority", "StartedAt", "DueAt", "CompletedAt",
                "HoursEstimated", "HoursActual", "PercentComplete", "Sequence",
                "BlockedReason", "CompletionNotes", "CreatedByPersonID",
                "OverdueNotifiedAt", "TaskTypeStatusID",
                "PredictedSLABreachProbability", "PredictedSLARiskBand", "PredictedSLAScoredAt",
                "HealthStatus", "ConfidenceScore", "BaselineValue", "TargetValue", "CurrentValue",
                "UnitOfMeasure", "MetricDirection", "RollupWeight", "PlanningPeriod",
                "CheckInCadence", "LastCheckInAt", "NextCheckInDueAt",
                "OrganizationID", "Visibility", "ForecastCompletionDate"
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
                COALESCE(p_Visibility, 'Standard'),
                CASE WHEN p_ForecastCompletionDate_Clear = TRUE THEN NULL ELSE COALESCE(p_ForecastCompletionDate, NULL) END
            )
        RETURNING "ID" INTO _v_id;
    END IF;
    RETURN QUERY SELECT * FROM __mj_BizAppsTasks."vwTasks" WHERE "ID" = _v_id;
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
    IN p_Visibility VARCHAR(20) DEFAULT NULL,
    IN p_ForecastCompletionDate_Clear BOOLEAN DEFAULT FALSE,
    IN p_ForecastCompletionDate TIMESTAMPTZ DEFAULT NULL
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
        "ForecastCompletionDate" = CASE WHEN p_ForecastCompletionDate_Clear = TRUE THEN NULL ELSE COALESCE(p_ForecastCompletionDate, "ForecastCompletionDate") END,
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

-- ===================== Triggers =====================

CREATE OR REPLACE FUNCTION __mj_BizAppsTasks."trgUpdateTaskRiskAssessment_func"()
RETURNS TRIGGER AS $$
BEGIN
    NEW."__mj_UpdatedAt" = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS "trgUpdateTaskRiskAssessment" ON __mj_BizAppsTasks."TaskRiskAssessment";
CREATE TRIGGER "trgUpdateTaskRiskAssessment"
    BEFORE UPDATE ON __mj_BizAppsTasks."TaskRiskAssessment"
    FOR EACH ROW
    EXECUTE FUNCTION __mj_BizAppsTasks."trgUpdateTaskRiskAssessment_func"();

-- ===================== Data (INSERT/UPDATE/DELETE) =====================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."Entity"
        WHERE "ID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'
           OR "Name" = 'MJ_BizApps_Tasks: Task Risk Assessments'
    ) THEN
        INSERT INTO ${mjSchema}."Entity" (
            "ID", "Name", "DisplayName", "Description", "NameSuffix", "BaseTable", "BaseView",
            "SchemaName", "IncludeInAPI", "AllowUserSearchAPI", "AllowCaching", "TrackRecordChanges",
            "AuditRecordAccess", "AuditViewRuns", "AllowAllRowsAPI", "AllowCreateAPI", "AllowUpdateAPI",
            "AllowDeleteAPI", "UserViewMaxRows", "__mj_CreatedAt", "__mj_UpdatedAt"
        ) VALUES (
            '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
            'MJ_BizApps_Tasks: Task Risk Assessments',
            'Task Risk Assessments',
            'AI-generated project risk assessments and completion date forecasts linked to a root project Task, syncing latest health, confidence, and forecast completion date onto the Task.',
            NULL,
            'TaskRiskAssessment',
            'vwTaskRiskAssessments',
            '__mj_BizAppsTasks',
            TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, 1000, NOW(), NOW()
        );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."ApplicationEntity"
        WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'
          AND "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'
    ) THEN
        INSERT INTO ${mjSchema}."ApplicationEntity"
            ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES (
            '22541055-8ED4-4850-8ACD-E5EE1887B15B',
            '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce',
            (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'),
            NOW(),
            NOW()
        );
    END IF;
END $$;

INSERT INTO ${mjSchema}."EntityPermission"
    ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
SELECT '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'::uuid, 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E'::uuid, 'Allow', TRUE, TRUE, TRUE, FALSE, NOW(), NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM ${mjSchema}."EntityPermission"
    WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'::uuid
      AND "RoleID" = 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E'::uuid
      AND "Type" = 'Allow'
);

INSERT INTO ${mjSchema}."EntityPermission"
    ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
SELECT '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'::uuid, 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E'::uuid, 'Allow', TRUE, TRUE, TRUE, TRUE, NOW(), NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM ${mjSchema}."EntityPermission"
    WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'::uuid
      AND "RoleID" = 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E'::uuid
      AND "Type" = 'Allow'
);

INSERT INTO ${mjSchema}."EntityPermission"
    ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
SELECT '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'::uuid, 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E'::uuid, 'Allow', TRUE, TRUE, TRUE, TRUE, NOW(), NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM ${mjSchema}."EntityPermission"
    WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'::uuid
      AND "RoleID" = 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E'::uuid
      AND "Type" = 'Allow'
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'c7578da9-3615-4787-a509-b9d2d5ae8eb1' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'ForecastCompletionDate')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('c7578da9-3615-4787-a509-b9d2d5ae8eb1', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'ForecastCompletionDate', 'Forecast Completion Date', 'AI-forecasted completion date synced from the latest Task Risk Assessment for project health rollups and Chief of Staff briefings.', 'datetimeoffset', 10, 34, 7, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '1bc39b54-2a9c-41ff-b4ac-c213ae224465' OR ("EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "Name" = 'ID')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('1bc39b54-2a9c-41ff-b4ac-c213ae224465', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'), 'ID', 'ID', 'Primary key for the task risk assessment.', 'uniqueidentifier', 16, 0, 0, FALSE, 'newsequentialid()', FALSE, FALSE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, 'Search', NOW(), NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'd5514b62-2d3e-4552-a46b-1fdf38e80353' OR ("EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "Name" = 'TaskID')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('d5514b62-2d3e-4552-a46b-1fdf38e80353', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'), 'TaskID', 'Task', 'The project root task (or tracked task) evaluated by this risk assessment.', 'uniqueidentifier', 16, 0, 0, FALSE, NULL, FALSE, TRUE, FALSE, FALSE, 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'ID', FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, 'Search', NOW(), NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'ff6995c4-122e-4146-bb29-05ea29fe0d54' OR ("EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "Name" = 'AssessedAt')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('ff6995c4-122e-4146-bb29-05ea29fe0d54', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'), 'AssessedAt', 'Assessed At', 'Timestamp when this risk assessment was produced.', 'datetimeoffset', 10, 34, 7, FALSE, 'sysdatetimeoffset()', FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, 'Search', NOW(), NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '72389c68-539b-4e97-91fc-958fe3079dc9' OR ("EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "Name" = 'ForecastCompletionDate')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('72389c68-539b-4e97-91fc-958fe3079dc9', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'), 'ForecastCompletionDate', 'Forecast Completion Date', 'Forecasted completion timestamp estimated by the Project Risk Analyst.', 'datetimeoffset', 10, 34, 7, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, 'Search', NOW(), NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '0ac7d448-708b-41fd-85f2-fd769f894889' OR ("EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "Name" = 'ForecastConfidence')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('0ac7d448-708b-41fd-85f2-fd769f894889', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'), 'ForecastConfidence', 'Forecast Confidence', 'Confidence score (0-100) in the forecasted completion date and health status, synced onto Task.ConfidenceScore.', 'int', 4, 10, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, 'Search', NOW(), NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '37decbda-0bda-43aa-8778-4ca6f270d5b5' OR ("EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "Name" = 'HealthStatus')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('37decbda-0bda-43aa-8778-4ca6f270d5b5', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'), 'HealthStatus', 'Health Status', 'Assessed project health status: OnTrack, AtRisk, OffTrack, Completed, or Paused.', 'nvarchar', 40, 0, 0, FALSE, 'OnTrack', FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, 'Search', NOW(), NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'b8d32f3d-9329-4b50-87f8-20c9ed6ecb24' OR ("EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "Name" = 'MLBreachProbability')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('b8d32f3d-9329-4b50-87f8-20c9ed6ecb24', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'), 'MLBreachProbability', 'ML Breach Probability', 'ML model breach probability (0.0000 - 1.0000) consumed as one input to the risk assessment.', 'decimal', 5, 5, 4, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, 'Search', NOW(), NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'c20d9c0f-46f8-412a-84f3-ffcdfe66454c' OR ("EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "Name" = 'Risks')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('c20d9c0f-46f8-412a-84f3-ffcdfe66454c', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'), 'Risks', 'Risks', 'JSON array of structured risk items ({ kind, severity, evidenceLinks, suggestedMitigation }).', 'nvarchar', -1, 0, 0, FALSE, '[]', FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '18d0d5bf-d2bf-4647-b0f1-4fb477d4753f' OR ("EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "Name" = 'AgentRunID')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('18d0d5bf-d2bf-4647-b0f1-4fb477d4753f', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'), 'AgentRunID', 'Agent Run', 'Optional MemberJunction AI Agent Run that generated this assessment.', 'uniqueidentifier', 16, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, '5190AF93-4C39-4429-BDAA-0AEB492A0256', 'ID', FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'ab3afa26-5936-4c81-9e63-a8c15955bd08' OR ("EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "Name" = 'PromptTokens')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('ab3afa26-5936-4c81-9e63-a8c15955bd08', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'), 'PromptTokens', 'Prompt Tokens', 'Input prompt token count consumed while generating this risk assessment.', 'int', 4, 10, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '18a15160-8342-4646-88c7-27f79bf053f9' OR ("EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "Name" = 'CompletionTokens')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('18a15160-8342-4646-88c7-27f79bf053f9', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'), 'CompletionTokens', 'Completion Tokens', 'Output completion token count generated for this risk assessment.', 'int', 4, 10, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'dd012ae3-3117-47d8-8acf-675bf4fca4ff' OR ("EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "Name" = 'TotalCostUSD')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('dd012ae3-3117-47d8-8acf-675bf4fca4ff', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'), 'TotalCostUSD', 'Total Cost USD', 'Total LLM inference cost in USD attributed to this risk assessment.', 'decimal', 9, 19, 8, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '0023b612-a08a-4780-8617-17b68dc1b025' OR ("EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "Name" = '__mj_CreatedAt')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('0023b612-a08a-4780-8617-17b68dc1b025', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'), '__mj_CreatedAt', 'Created At', 'Record creation timestamp in UTC.', 'datetimeoffset', 10, 34, 7, FALSE, 'getutcdate()', FALSE, FALSE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'd9f0e762-536e-4d91-9e81-e67e8a4a57b5' OR ("EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "Name" = '__mj_UpdatedAt')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('d9f0e762-536e-4d91-9e81-e67e8a4a57b5', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'), '__mj_UpdatedAt', 'Updated At', 'Record last-updated timestamp in UTC.', 'datetimeoffset', 10, 34, 7, FALSE, 'getutcdate()', FALSE, FALSE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'c9acc059-bfa8-4145-9276-786e7a1690a8' OR ("EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "Name" = 'Task')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('c9acc059-bfa8-4145-9276-786e7a1690a8', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'), 'Task', 'Task Name', NULL, 'nvarchar', 510, 0, 0, TRUE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '22ddab28-fd8e-4777-823f-822537ca17fa' OR ("EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "Name" = 'AgentRun')) THEN
        INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('22ddab28-fd8e-4777-823f-822537ca17fa', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce'), 'AgentRun', 'Agent Run Name', NULL, 'nvarchar', 510, 0, 0, TRUE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
    END IF;
END $$;

INSERT INTO ${mjSchema}."EntityFieldValue" ("ID", "EntityFieldID", "Sequence", "Value", "Code", "Source", "__mj_CreatedAt", "__mj_UpdatedAt")
SELECT '39385cfd-df4a-4afe-b4aa-5c5d268ab137'::uuid, '37decbda-0bda-43aa-8778-4ca6f270d5b5'::uuid, 1, 'AtRisk', 'AtRisk', 'Check', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityFieldValue" WHERE "ID" = '39385cfd-df4a-4afe-b4aa-5c5d268ab137'::uuid);

INSERT INTO ${mjSchema}."EntityFieldValue" ("ID", "EntityFieldID", "Sequence", "Value", "Code", "Source", "__mj_CreatedAt", "__mj_UpdatedAt")
SELECT '37676547-e226-40b5-8009-935a285f8cff'::uuid, '37decbda-0bda-43aa-8778-4ca6f270d5b5'::uuid, 2, 'Completed', 'Completed', 'Check', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityFieldValue" WHERE "ID" = '37676547-e226-40b5-8009-935a285f8cff'::uuid);

INSERT INTO ${mjSchema}."EntityFieldValue" ("ID", "EntityFieldID", "Sequence", "Value", "Code", "Source", "__mj_CreatedAt", "__mj_UpdatedAt")
SELECT '2265f1f8-b6b1-4ac1-aa7b-9d71b91d960f'::uuid, '37decbda-0bda-43aa-8778-4ca6f270d5b5'::uuid, 3, 'OffTrack', 'OffTrack', 'Check', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityFieldValue" WHERE "ID" = '2265f1f8-b6b1-4ac1-aa7b-9d71b91d960f'::uuid);

INSERT INTO ${mjSchema}."EntityFieldValue" ("ID", "EntityFieldID", "Sequence", "Value", "Code", "Source", "__mj_CreatedAt", "__mj_UpdatedAt")
SELECT '253899ef-c0ec-47b0-b806-83b777479e0c'::uuid, '37decbda-0bda-43aa-8778-4ca6f270d5b5'::uuid, 4, 'OnTrack', 'OnTrack', 'Check', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityFieldValue" WHERE "ID" = '253899ef-c0ec-47b0-b806-83b777479e0c'::uuid);

INSERT INTO ${mjSchema}."EntityFieldValue" ("ID", "EntityFieldID", "Sequence", "Value", "Code", "Source", "__mj_CreatedAt", "__mj_UpdatedAt")
SELECT '7ca36f99-df06-4952-9a19-6d0841d1f441'::uuid, '37decbda-0bda-43aa-8778-4ca6f270d5b5'::uuid, 5, 'Paused', 'Paused', 'Check', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityFieldValue" WHERE "ID" = '7ca36f99-df06-4952-9a19-6d0841d1f441'::uuid);

UPDATE ${mjSchema}."EntityField" SET "ValueListType" = 'List' WHERE "ID" = '37decbda-0bda-43aa-8778-4ca6f270d5b5'::uuid;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship"
        WHERE "ID" = 'ed909e5b-eaf3-4913-ba4d-9ada74fa9a24'
           OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "RelatedEntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "RelatedEntityJoinField" = 'TaskID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('ed909e5b-eaf3-4913-ba4d-9ada74fa9a24', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', 'TaskID', 'One To Many', TRUE, TRUE, 17, NOW(), NOW());
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship"
        WHERE "ID" = '62c35b69-40fa-488a-a8ed-7def326e62f2'
           OR ("EntityID" = '5190AF93-4C39-4429-BDAA-0AEB492A0256' AND "RelatedEntityID" = '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce' AND "RelatedEntityJoinField" = 'AgentRunID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('62c35b69-40fa-488a-a8ed-7def326e62f2', '5190AF93-4C39-4429-BDAA-0AEB492A0256', '4f3289e7-c7d2-4eb1-9975-108ce39bb0ce', 'AgentRunID', 'One To Many', TRUE, TRUE, 18, NOW(), NOW());
    END IF;
END $$;

-- ===================== Grants =====================

DO $$
BEGIN
    IF to_regclass('__mj_BizAppsTasks."vwTaskRiskAssessments"') IS NOT NULL THEN
        BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskRiskAssessments" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END;
    END IF;
    IF to_regclass('__mj_BizAppsTasks."vwTasks"') IS NOT NULL THEN
        BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTasks" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END;
    END IF;
    IF to_regclass('__mj_BizAppsTasks."vwTasksGenerated"') IS NOT NULL THEN
        BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTasksGenerated" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END;
    END IF;
END $$;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskRiskAssessment" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskRiskAssessment" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskRiskAssessment" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTask" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTask" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;

-- ===================== Comments =====================

COMMENT ON COLUMN __mj_BizAppsTasks."Task"."ForecastCompletionDate" IS 'AI-forecasted completion date synced from the latest Task Risk Assessment for project health rollups and Chief of Staff briefings.';
COMMENT ON TABLE __mj_BizAppsTasks."TaskRiskAssessment" IS 'AI-generated project risk assessments and completion date forecasts linked to a root project Task, syncing latest health, confidence, and forecast completion date onto the Task.';
COMMENT ON COLUMN __mj_BizAppsTasks."TaskRiskAssessment"."ID" IS 'Primary key for the task risk assessment.';
COMMENT ON COLUMN __mj_BizAppsTasks."TaskRiskAssessment"."TaskID" IS 'The project root task (or tracked task) evaluated by this risk assessment.';
COMMENT ON COLUMN __mj_BizAppsTasks."TaskRiskAssessment"."AssessedAt" IS 'Timestamp when this risk assessment was produced.';
COMMENT ON COLUMN __mj_BizAppsTasks."TaskRiskAssessment"."ForecastCompletionDate" IS 'Forecasted completion timestamp estimated by the Project Risk Analyst.';
COMMENT ON COLUMN __mj_BizAppsTasks."TaskRiskAssessment"."ForecastConfidence" IS 'Confidence score (0-100) in the forecasted completion date and health status, synced onto Task.ConfidenceScore.';
COMMENT ON COLUMN __mj_BizAppsTasks."TaskRiskAssessment"."HealthStatus" IS 'Assessed project health status: OnTrack, AtRisk, OffTrack, Completed, or Paused.';
COMMENT ON COLUMN __mj_BizAppsTasks."TaskRiskAssessment"."MLBreachProbability" IS 'ML model breach probability (0.0000 - 1.0000) consumed as one input to the risk assessment.';
COMMENT ON COLUMN __mj_BizAppsTasks."TaskRiskAssessment"."Risks" IS 'JSON array of structured risk items ({ kind, severity, evidenceLinks, suggestedMitigation }).';
COMMENT ON COLUMN __mj_BizAppsTasks."TaskRiskAssessment"."AgentRunID" IS 'Optional MemberJunction AI Agent Run that generated this assessment.';
COMMENT ON COLUMN __mj_BizAppsTasks."TaskRiskAssessment"."PromptTokens" IS 'Input prompt token count consumed while generating this risk assessment.';
COMMENT ON COLUMN __mj_BizAppsTasks."TaskRiskAssessment"."CompletionTokens" IS 'Output completion token count generated for this risk assessment.';
COMMENT ON COLUMN __mj_BizAppsTasks."TaskRiskAssessment"."TotalCostUSD" IS 'Total LLM inference cost in USD attributed to this risk assessment.';
