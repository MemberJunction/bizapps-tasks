-- ============================================================================
-- PostgreSQL counterpart of migrations/V202609202350__v1.5.0__Predictive_SLA_Breach_Fields.sql
-- Sections 1-2 (prediction columns, layered vwTasksGenerated/vwTasks) are written by hand
-- from the T-SQL. Metadata DML is converted from the T-SQL; the CodeGen sections are native PostgreSQL CodeGen (MJ 6.1.5), not translated T-SQL.
-- ============================================================================

SET search_path TO __mj_bizappstasks, public;
SET standard_conforming_strings = on;

---------------------------------------------------------------------------
-- 1. Task: Add materialized prediction fields
---------------------------------------------------------------------------
ALTER TABLE __mj_bizappstasks."Task"
 ADD COLUMN "PredictedSLABreachProbability" DECIMAL(5,4) NULL,
 ADD COLUMN "PredictedSLARiskBand" VARCHAR(20) NULL,
 ADD COLUMN "PredictedSLAScoredAt" TIMESTAMPTZ NULL,
 ADD CONSTRAINT CK_Task_PredictedSLARiskBand CHECK ("PredictedSLARiskBand" IN ('Low', 'Medium', 'High', 'Critical'));

COMMENT ON COLUMN __mj_bizappstasks."Task"."PredictedSLABreachProbability" IS 'Predicted probability (0.0000 - 1.0000) that this task breaches its target due date or SLA.';
COMMENT ON COLUMN __mj_bizappstasks."Task"."PredictedSLARiskBand" IS 'Operational SLA breach risk tier: Low (<0.30), Medium (0.30-0.70), High (>0.70), or Critical.';
COMMENT ON COLUMN __mj_bizappstasks."Task"."PredictedSLAScoredAt" IS 'Timestamp when this task was last scored by the predictive SLA breach model.';

---------------------------------------------------------------------------
-- 2. Establish Layered Base Views for Tasks
---------------------------------------------------------------------------
UPDATE ${mjSchema}."Entity"
   SET "BaseViewGenerated" = FALSE,
       "GeneratedBaseViewName" = 'vwTasksGenerated'
 WHERE "Name" = 'MJ_BizApps_Tasks: Tasks'
   AND ("BaseViewGenerated" <> FALSE
        OR "GeneratedBaseViewName" IS NULL
        OR "GeneratedBaseViewName" <> 'vwTasksGenerated');

-- spCreateTask and spUpdateTask return vwTasks rows, so PostgreSQL will not drop the view while
-- they exist. CASCADE drops those two functions (nothing else depends on vwTasks); the CodeGen
-- section below recreates them against the new view.
DROP VIEW IF EXISTS __mj_bizappstasks."vwTasks" CASCADE;
DROP VIEW IF EXISTS __mj_bizappstasks."vwTasksGenerated";

CREATE VIEW __mj_bizappstasks."vwTasksGenerated"
AS
SELECT
    t.*,
    mjBizAppsTasksTaskType_TypeID."Name" AS "Type",
    mjBizAppsTasksTaskCategory_CategoryID."Name" AS "Category",
    mjBizAppsTasksTask_ParentID."Name" AS "Parent",
    mjBizAppsCommonPerson_CreatedByPersonID."DisplayName" AS "CreatedByPerson",
    mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID."Name" AS "TaskTypeStatus"
FROM
    __mj_bizappstasks."Task" AS t
INNER JOIN
    __mj_bizappstasks."TaskType" AS mjBizAppsTasksTaskType_TypeID
  ON
    t."TypeID" = mjBizAppsTasksTaskType_TypeID."ID"
LEFT OUTER JOIN
    __mj_bizappstasks."TaskCategory" AS mjBizAppsTasksTaskCategory_CategoryID
  ON
    t."CategoryID" = mjBizAppsTasksTaskCategory_CategoryID."ID"
LEFT OUTER JOIN
    __mj_bizappstasks."Task" AS mjBizAppsTasksTask_ParentID
  ON
    t."ParentID" = mjBizAppsTasksTask_ParentID."ID"
LEFT OUTER JOIN
    __mj_bizappscommon."Person" AS mjBizAppsCommonPerson_CreatedByPersonID
  ON
    t."CreatedByPersonID" = mjBizAppsCommonPerson_CreatedByPersonID."ID"
LEFT OUTER JOIN
    __mj_bizappstasks."TaskTypeStatus" AS mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID
  ON
    t."TaskTypeStatusID" = mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID."ID";

-- LeadDays counts calendar-day boundaries in UTC, as SQL Server's DATEDIFF(day, ...) does on
-- DATETIMEOFFSET values. The counts are cast to INTEGER to match the T-SQL view's column types.
CREATE VIEW __mj_bizappstasks."vwTasks"
AS
SELECT
    g.*,
    root_ParentID.root_id AS "RootParentID",
    -- Engineered features for SLA prediction & historical ground truth
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
    __mj_bizappstasks."vwTasksGenerated" AS g
LEFT JOIN LATERAL (
    SELECT __mj_bizappstasks.fn_task_parent_id_get_root_id(g."ID", g."ParentID") AS root_id
) AS root_ParentID ON true
LEFT OUTER JOIN (
    SELECT "TaskID", COUNT(*)::INTEGER AS "AssignmentsCount"
    FROM __mj_bizappstasks."TaskAssignment"
    GROUP BY "TaskID"
) AS a ON a."TaskID" = g."ID"
LEFT OUTER JOIN (
    SELECT "TaskID", COUNT(*)::INTEGER AS "CommentsCount"
    FROM __mj_bizappstasks."TaskComment"
    GROUP BY "TaskID"
) AS c ON c."TaskID" = g."ID";

GRANT SELECT ON __mj_bizappstasks."vwTasks" TO "cdp_UI", "cdp_Developer", "cdp_Integration";



















































DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '33d3756e-8ac7-4a57-be61-946d1ae7c2d6' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'PredictedSLABreachProbability')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('33d3756e-8ac7-4a57-be61-946d1ae7c2d6', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'PredictedSLABreachProbability', 'Predicted SLA Breach Probability', 'Predicted probability (0.0000 - 1.0000) that this task breaches its target due date or SLA.', 'decimal', 5, 5, 4, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '54214dda-792c-4a7a-a6c0-115ba1c90aab' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'PredictedSLARiskBand')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('54214dda-792c-4a7a-a6c0-115ba1c90aab', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'PredictedSLARiskBand', 'Predicted SLA Risk Band', 'Operational SLA breach risk tier: Low (<0.30), Medium (0.30-0.70), High (>0.70), or Critical.', 'nvarchar', 40, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'a92eaf03-b039-4dc4-931c-8c6d7c038217' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'PredictedSLAScoredAt')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('a92eaf03-b039-4dc4-931c-8c6d7c038217', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'PredictedSLAScoredAt', 'Predicted SLA Scored At', 'Timestamp when this task was last scored by the predictive SLA breach model.', 'datetimeoffset', 10, 34, 7, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'e7737a78-1c54-4766-929c-bfe8ddf0555c' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'IsSLABreached')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('e7737a78-1c54-4766-929c-bfe8ddf0555c', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'IsSLABreached', 'Is SLA Breached', NULL, 'varchar', 8, 0, 0, TRUE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '35141732-5d6a-459a-a2fa-76808f95160b' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'LeadDays')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('35141732-5d6a-459a-a2fa-76808f95160b', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'LeadDays', 'Lead Days', NULL, 'int', 4, 10, 0, TRUE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'aad50345-db1b-4bc8-8515-979137c33382' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'AssignmentsCount')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('aad50345-db1b-4bc8-8515-979137c33382', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'AssignmentsCount', 'Assignments Count', NULL, 'int', 4, 10, 0, FALSE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '45355317-a1ab-468f-8901-4564b03ccc4b' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'CommentsCount')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('45355317-a1ab-468f-8901-4564b03ccc4b', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'CommentsCount', 'Comments Count', NULL, 'int', 4, 10, 0, FALSE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '9e82d5eb-b2ac-458f-8c8e-fb2dfee82244' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'RootParentID')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "Status", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('9e82d5eb-b2ac-458f-8c8e-fb2dfee82244', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'RootParentID', 'Root Parent ID', 'Root parent task in the hierarchy', 'uniqueidentifier', 16, 0, 0, TRUE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', 'Active', NOW(), NOW());
  END IF;
END $$;

/* SQL text to update existing entity fields from schema */
/* SQL text to set default column width where needed */
/* SQL text to insert entity field value with ID 5d642c95-b90d-497e-bc37-a1924ffd9f28 */
INSERT INTO ${mjSchema}."EntityFieldValue" (
  "ID",
  "EntityFieldID",
  "Sequence",
  "Value",
  "Code",
  "__mj_CreatedAt",
  "__mj_UpdatedAt"
)
VALUES
  (
    '5d642c95-b90d-497e-bc37-a1924ffd9f28',
    '54214DDA-792C-4A7A-A6C0-115BA1C90AAB',
    1,
    'Critical',
    'Critical',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID b063068f-8b10-4a2d-b9e6-0d24c52ee804 */
INSERT INTO ${mjSchema}."EntityFieldValue" (
  "ID",
  "EntityFieldID",
  "Sequence",
  "Value",
  "Code",
  "__mj_CreatedAt",
  "__mj_UpdatedAt"
)
VALUES
  (
    'b063068f-8b10-4a2d-b9e6-0d24c52ee804',
    '54214DDA-792C-4A7A-A6C0-115BA1C90AAB',
    2,
    'High',
    'High',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID 0122031c-e04a-4782-9f96-11e014325a3a */
INSERT INTO ${mjSchema}."EntityFieldValue" (
  "ID",
  "EntityFieldID",
  "Sequence",
  "Value",
  "Code",
  "__mj_CreatedAt",
  "__mj_UpdatedAt"
)
VALUES
  (
    '0122031c-e04a-4782-9f96-11e014325a3a',
    '54214DDA-792C-4A7A-A6C0-115BA1C90AAB',
    3,
    'Low',
    'Low',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID 7369bfd9-a4a7-4b57-a06b-14f2f58ece68 */
INSERT INTO ${mjSchema}."EntityFieldValue" (
  "ID",
  "EntityFieldID",
  "Sequence",
  "Value",
  "Code",
  "__mj_CreatedAt",
  "__mj_UpdatedAt"
)
VALUES
  (
    '7369bfd9-a4a7-4b57-a06b-14f2f58ece68',
    '54214DDA-792C-4A7A-A6C0-115BA1C90AAB',
    4,
    'Medium',
    'Medium',
    NOW(),
    NOW()
  );
/* SQL text to update ValueListType for entity field ID 54214DDA-792C-4A7A-A6C0-115BA1C90AAB */
UPDATE ${mjSchema}."EntityField" SET "ValueListType" = 'List'
WHERE
  "ID" = '54214DDA-792C-4A7A-A6C0-115BA1C90AAB';
/* SQL text to sync schema info from database schemas */;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntitySetting" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'FieldCategoryInfo') THEN
    INSERT INTO ${mjSchema}."EntitySetting" ("ID", "EntityID", "Name", "Value", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('9aa482c3-1a7f-53ba-9040-cdb96c79943c', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'FieldCategoryInfo', '{
  "Ownership and Audit": {
    "description": "Information about who created or owns the task",
    "icon": "fa fa-user-tag"
  },
  "Predictive SLA Metrics": {
    "description": "AI-driven insights regarding SLA breach risks",
    "icon": "fa fa-chart-line"
  },
  "System Metadata": {
    "description": "System-managed audit and tracking fields",
    "icon": "fa fa-database"
  },
  "Task Details": {
    "description": "Core task information including name, type, and hierarchy",
    "icon": "fa fa-info-circle"
  },
  "Timeline and Progress": {
    "description": "Task scheduling, duration, and completion progress",
    "icon": "fa fa-clock"
  }
}', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntitySetting" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'FieldCategoryIcons') THEN
    INSERT INTO ${mjSchema}."EntitySetting" ("ID", "EntityID", "Name", "Value", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('190fe5f2-3423-5e28-82d8-f35fb65f7ae8', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'FieldCategoryIcons', '{
  "Ownership and Audit": "fa fa-user-tag",
  "Predictive SLA Metrics": "fa fa-chart-line",
  "System Metadata": "fa fa-database",
  "Task Details": "fa fa-info-circle",
  "Timeline and Progress": "fa fa-clock"
}', NOW(), NOW());
  END IF;
END $$;

-- ===================== CodeGen (native PG, baked) =====================

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Tasks
-- Item: Index for Foreign Keys
-- ============================================================
CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_type_id"
    ON "__mj_bizappstasks"."Task" ("TypeID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_category_id"
    ON "__mj_bizappstasks"."Task" ("CategoryID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_parent_id"
    ON "__mj_bizappstasks"."Task" ("ParentID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_created_by_person_id"
    ON "__mj_bizappstasks"."Task" ("CreatedByPersonID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_task_type_status_id"
    ON "__mj_bizappstasks"."Task" ("TaskTypeStatusID");

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Tasks
-- Item: vwTasksGenerated
-- ============================================================

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Tasks
-----               SCHEMA:      __mj_bizappstasks
-----               BASE TABLE:  Task
-----               PRIMARY KEY: ID
------------------------------------------------------------
DO $vw_regen$
DECLARE
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_bizappstasks"."vwTasksGenerated"
AS
SELECT
    t.*,
    mjBizAppsTasksTaskType_TypeID."Name" AS "Type",
    mjBizAppsTasksTaskCategory_CategoryID."Name" AS "Category",
    mjBizAppsTasksTask_ParentID."Name" AS "Parent",
    mjBizAppsCommonPerson_CreatedByPersonID."DisplayName" AS "CreatedByPerson",
    mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID."Name" AS "TaskTypeStatus"
FROM
    "__mj_bizappstasks"."Task" AS t
INNER JOIN
    "__mj_bizappstasks"."TaskType" AS mjBizAppsTasksTaskType_TypeID
  ON
    "t"."TypeID" = mjBizAppsTasksTaskType_TypeID."ID"
LEFT OUTER JOIN
    "__mj_bizappstasks"."TaskCategory" AS mjBizAppsTasksTaskCategory_CategoryID
  ON
    "t"."CategoryID" = mjBizAppsTasksTaskCategory_CategoryID."ID"
LEFT OUTER JOIN
    "__mj_bizappstasks"."Task" AS mjBizAppsTasksTask_ParentID
  ON
    "t"."ParentID" = mjBizAppsTasksTask_ParentID."ID"
LEFT OUTER JOIN
    "__mj_bizappscommon"."Person" AS mjBizAppsCommonPerson_CreatedByPersonID
  ON
    "t"."CreatedByPersonID" = mjBizAppsCommonPerson_CreatedByPersonID."ID"
LEFT OUTER JOIN
    "__mj_bizappstasks"."TaskTypeStatus" AS mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID
  ON
    "t"."TaskTypeStatusID" = mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID."ID"
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
    AND tc.relname = 'vwTasksGenerated'
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
    AND tc.relname = 'vwTasksGenerated'
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
        AND tc.relname = 'vwTasksGenerated'
        AND tc.relkind IN ('v', 'm')
  );

  DROP VIEW IF EXISTS "__mj_bizappstasks"."vwTasksGenerated" CASCADE;
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

DO $if_view_exists$
BEGIN
  IF to_regclass('"__mj_bizappstasks"."vwTasks"') IS NOT NULL THEN
    EXECUTE 'GRANT SELECT ON "__mj_bizappstasks"."vwTasks" TO "cdp_UI";
GRANT SELECT ON "__mj_bizappstasks"."vwTasks" TO "cdp_Developer";
GRANT SELECT ON "__mj_bizappstasks"."vwTasks" TO "cdp_Integration";';
  END IF;
END
$if_view_exists$;


DO $if_view_exists$
BEGIN
  IF to_regclass('"__mj_bizappstasks"."vwTasks"') IS NOT NULL THEN
    EXECUTE 'SELECT ${mjSchema}."spRebindLayeredOuterView"(''__mj_bizappstasks'', ''vwTasks'', ''vwTasksGenerated'');';
  END IF;
END
$if_view_exists$;


-- CodeGen also emitted a "Permissions for vwTasks" block here that wraps the grant above in a
-- second DO $if_view_exists$ inside the first; the shared dollar-quote tag makes it unparseable.
-- The grant is already applied above, so the block is left out.


-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Tasks
-- Item: spCreateTask
-- ============================================================

------------------------------------------------------------
----- CREATE FUNCTION FOR Task
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spCreateTask'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spCreateTask"(
    p_id UUID DEFAULT NULL,
    p_name varchar(255) DEFAULT NULL,
    p_description_clear boolean DEFAULT false,
    p_description TEXT DEFAULT NULL,
    p_typeid UUID DEFAULT NULL,
    p_categoryid_clear boolean DEFAULT false,
    p_categoryid UUID DEFAULT NULL,
    p_parentid_clear boolean DEFAULT false,
    p_parentid UUID DEFAULT NULL,
    p_status varchar(50) DEFAULT NULL,
    p_priority varchar(20) DEFAULT NULL,
    p_startedat_clear boolean DEFAULT false,
    p_startedat TIMESTAMPTZ DEFAULT NULL,
    p_dueat_clear boolean DEFAULT false,
    p_dueat TIMESTAMPTZ DEFAULT NULL,
    p_completedat_clear boolean DEFAULT false,
    p_completedat TIMESTAMPTZ DEFAULT NULL,
    p_hoursestimated_clear boolean DEFAULT false,
    p_hoursestimated decimal(8, 2) DEFAULT NULL,
    p_hoursactual_clear boolean DEFAULT false,
    p_hoursactual decimal(8, 2) DEFAULT NULL,
    p_percentcomplete int DEFAULT NULL,
    p_sequence int DEFAULT NULL,
    p_blockedreason_clear boolean DEFAULT false,
    p_blockedreason TEXT DEFAULT NULL,
    p_completionnotes_clear boolean DEFAULT false,
    p_completionnotes TEXT DEFAULT NULL,
    p_createdbypersonid_clear boolean DEFAULT false,
    p_createdbypersonid UUID DEFAULT NULL,
    p_overduenotifiedat_clear boolean DEFAULT false,
    p_overduenotifiedat TIMESTAMPTZ DEFAULT NULL,
    p_tasktypestatusid_clear boolean DEFAULT false,
    p_tasktypestatusid UUID DEFAULT NULL,
    p_predictedslabreachprobability_clear boolean DEFAULT false,
    p_predictedslabreachprobability decimal(5, 4) DEFAULT NULL,
    p_predictedslariskband_clear boolean DEFAULT false,
    p_predictedslariskband varchar(20) DEFAULT NULL,
    p_predictedslascoredat_clear boolean DEFAULT false,
    p_predictedslascoredat TIMESTAMPTZ DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwTasks" AS $$
DECLARE
    v_new_id UUID;
BEGIN
    v_new_id := COALESCE(p_id, gen_random_uuid());
    INSERT INTO "__mj_bizappstasks"."Task"
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
                "PredictedSLAScoredAt"
        )
    VALUES
        (
            v_new_id,
            p_name,
                CASE WHEN p_description_clear = true THEN NULL ELSE COALESCE(p_description, NULL) END,
                p_typeid,
                CASE WHEN p_categoryid_clear = true THEN NULL ELSE COALESCE(p_categoryid, NULL) END,
                CASE WHEN p_parentid_clear = true THEN NULL ELSE COALESCE(p_parentid, NULL) END,
                COALESCE(p_status, 'Open'),
                COALESCE(p_priority, 'Medium'),
                CASE WHEN p_startedat_clear = true THEN NULL ELSE COALESCE(p_startedat, NULL) END,
                CASE WHEN p_dueat_clear = true THEN NULL ELSE COALESCE(p_dueat, NULL) END,
                CASE WHEN p_completedat_clear = true THEN NULL ELSE COALESCE(p_completedat, NULL) END,
                CASE WHEN p_hoursestimated_clear = true THEN NULL ELSE COALESCE(p_hoursestimated, NULL) END,
                CASE WHEN p_hoursactual_clear = true THEN NULL ELSE COALESCE(p_hoursactual, NULL) END,
                COALESCE(p_percentcomplete, 0),
                COALESCE(p_sequence, 100),
                CASE WHEN p_blockedreason_clear = true THEN NULL ELSE COALESCE(p_blockedreason, NULL) END,
                CASE WHEN p_completionnotes_clear = true THEN NULL ELSE COALESCE(p_completionnotes, NULL) END,
                CASE WHEN p_createdbypersonid_clear = true THEN NULL ELSE COALESCE(p_createdbypersonid, NULL) END,
                CASE WHEN p_overduenotifiedat_clear = true THEN NULL ELSE COALESCE(p_overduenotifiedat, NULL) END,
                CASE WHEN p_tasktypestatusid_clear = true THEN NULL ELSE COALESCE(p_tasktypestatusid, NULL) END,
                CASE WHEN p_predictedslabreachprobability_clear = true THEN NULL ELSE COALESCE(p_predictedslabreachprobability, NULL) END,
                CASE WHEN p_predictedslariskband_clear = true THEN NULL ELSE COALESCE(p_predictedslariskband, NULL) END,
                CASE WHEN p_predictedslascoredat_clear = true THEN NULL ELSE COALESCE(p_predictedslascoredat, NULL) END
        )
    ;

    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwTasks"
    WHERE "ID" = v_new_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTask" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTask" TO "cdp_Integration";


-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Tasks
-- Item: spUpdateTask
-- ============================================================

------------------------------------------------------------
----- UPDATE FUNCTION FOR Task
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spUpdateTask'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spUpdateTask"(
    p_id UUID,
    p_name varchar(255) DEFAULT NULL,
    p_description_clear boolean DEFAULT false,
    p_description TEXT DEFAULT NULL,
    p_typeid UUID DEFAULT NULL,
    p_categoryid_clear boolean DEFAULT false,
    p_categoryid UUID DEFAULT NULL,
    p_parentid_clear boolean DEFAULT false,
    p_parentid UUID DEFAULT NULL,
    p_status varchar(50) DEFAULT NULL,
    p_priority varchar(20) DEFAULT NULL,
    p_startedat_clear boolean DEFAULT false,
    p_startedat TIMESTAMPTZ DEFAULT NULL,
    p_dueat_clear boolean DEFAULT false,
    p_dueat TIMESTAMPTZ DEFAULT NULL,
    p_completedat_clear boolean DEFAULT false,
    p_completedat TIMESTAMPTZ DEFAULT NULL,
    p_hoursestimated_clear boolean DEFAULT false,
    p_hoursestimated decimal(8, 2) DEFAULT NULL,
    p_hoursactual_clear boolean DEFAULT false,
    p_hoursactual decimal(8, 2) DEFAULT NULL,
    p_percentcomplete int DEFAULT NULL,
    p_sequence int DEFAULT NULL,
    p_blockedreason_clear boolean DEFAULT false,
    p_blockedreason TEXT DEFAULT NULL,
    p_completionnotes_clear boolean DEFAULT false,
    p_completionnotes TEXT DEFAULT NULL,
    p_createdbypersonid_clear boolean DEFAULT false,
    p_createdbypersonid UUID DEFAULT NULL,
    p_overduenotifiedat_clear boolean DEFAULT false,
    p_overduenotifiedat TIMESTAMPTZ DEFAULT NULL,
    p_tasktypestatusid_clear boolean DEFAULT false,
    p_tasktypestatusid UUID DEFAULT NULL,
    p_predictedslabreachprobability_clear boolean DEFAULT false,
    p_predictedslabreachprobability decimal(5, 4) DEFAULT NULL,
    p_predictedslariskband_clear boolean DEFAULT false,
    p_predictedslariskband varchar(20) DEFAULT NULL,
    p_predictedslascoredat_clear boolean DEFAULT false,
    p_predictedslascoredat TIMESTAMPTZ DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwTasks" AS $$
DECLARE
    v_updated_count INTEGER;
BEGIN
    UPDATE "__mj_bizappstasks"."Task"
    SET
        "Name" = COALESCE(p_name, "Name"),
        "Description" = CASE WHEN p_description_clear = true THEN NULL ELSE COALESCE(p_description, "Description") END,
        "TypeID" = COALESCE(p_typeid, "TypeID"),
        "CategoryID" = CASE WHEN p_categoryid_clear = true THEN NULL ELSE COALESCE(p_categoryid, "CategoryID") END,
        "ParentID" = CASE WHEN p_parentid_clear = true THEN NULL ELSE COALESCE(p_parentid, "ParentID") END,
        "Status" = COALESCE(p_status, "Status"),
        "Priority" = COALESCE(p_priority, "Priority"),
        "StartedAt" = CASE WHEN p_startedat_clear = true THEN NULL ELSE COALESCE(p_startedat, "StartedAt") END,
        "DueAt" = CASE WHEN p_dueat_clear = true THEN NULL ELSE COALESCE(p_dueat, "DueAt") END,
        "CompletedAt" = CASE WHEN p_completedat_clear = true THEN NULL ELSE COALESCE(p_completedat, "CompletedAt") END,
        "HoursEstimated" = CASE WHEN p_hoursestimated_clear = true THEN NULL ELSE COALESCE(p_hoursestimated, "HoursEstimated") END,
        "HoursActual" = CASE WHEN p_hoursactual_clear = true THEN NULL ELSE COALESCE(p_hoursactual, "HoursActual") END,
        "PercentComplete" = COALESCE(p_percentcomplete, "PercentComplete"),
        "Sequence" = COALESCE(p_sequence, "Sequence"),
        "BlockedReason" = CASE WHEN p_blockedreason_clear = true THEN NULL ELSE COALESCE(p_blockedreason, "BlockedReason") END,
        "CompletionNotes" = CASE WHEN p_completionnotes_clear = true THEN NULL ELSE COALESCE(p_completionnotes, "CompletionNotes") END,
        "CreatedByPersonID" = CASE WHEN p_createdbypersonid_clear = true THEN NULL ELSE COALESCE(p_createdbypersonid, "CreatedByPersonID") END,
        "OverdueNotifiedAt" = CASE WHEN p_overduenotifiedat_clear = true THEN NULL ELSE COALESCE(p_overduenotifiedat, "OverdueNotifiedAt") END,
        "TaskTypeStatusID" = CASE WHEN p_tasktypestatusid_clear = true THEN NULL ELSE COALESCE(p_tasktypestatusid, "TaskTypeStatusID") END,
        "PredictedSLABreachProbability" = CASE WHEN p_predictedslabreachprobability_clear = true THEN NULL ELSE COALESCE(p_predictedslabreachprobability, "PredictedSLABreachProbability") END,
        "PredictedSLARiskBand" = CASE WHEN p_predictedslariskband_clear = true THEN NULL ELSE COALESCE(p_predictedslariskband, "PredictedSLARiskBand") END,
        "PredictedSLAScoredAt" = CASE WHEN p_predictedslascoredat_clear = true THEN NULL ELSE COALESCE(p_predictedslascoredat, "PredictedSLAScoredAt") END
    WHERE
        "ID" = p_id;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    IF v_updated_count = 0 THEN
        -- Nothing was updated, return empty result set
        RETURN;
    END IF;

    -- Return the updated record from the base view
    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwTasks"
    WHERE "ID" = p_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateTask" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateTask" TO "cdp_Integration";


------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Task table
------------------------------------------------------------
CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."fn_trg_update_task"()
RETURNS TRIGGER AS $$
BEGIN
    NEW."__mj_UpdatedAt" := NOW() AT TIME ZONE 'UTC';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS "trg_update_task" ON "__mj_bizappstasks"."Task";

CREATE TRIGGER "trg_update_task"
BEFORE UPDATE ON "__mj_bizappstasks"."Task"
FOR EACH ROW
EXECUTE FUNCTION "__mj_bizappstasks"."fn_trg_update_task"();



-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Tasks
-- Item: spDeleteTask
-- ============================================================

------------------------------------------------------------
----- DELETE FUNCTION FOR Task
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spDeleteTask'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spDeleteTask"(
    p_id UUID
) RETURNS TABLE("ID" UUID) AS $$
#variable_conflict use_column
DECLARE
    v_affected_count INTEGER;
BEGIN

    DELETE FROM "__mj_bizappstasks"."Task"
    WHERE "ID" = p_id;

    GET DIAGNOSTICS v_affected_count = ROW_COUNT;

    IF v_affected_count = 0 THEN
        RETURN QUERY SELECT NULL::UUID AS "ID";
    ELSE
        RETURN QUERY SELECT p_id AS "ID";
    END IF;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteTask" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteTask" TO "cdp_Integration";

-- ===================== CodeGen metadata after the generated objects =====================
-- Field settings, categories, icons and entity settings that CodeGen wrote after the objects
-- in the T-SQL migration, in the same order.

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'System Metadata'
WHERE
   "ID" = 'B8AD1F96-886C-4903-8D8D-FBEBB27BB506';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Name

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Task Details'
WHERE
   "ID" = '4C041CC2-D419-485C-9896-790003F638B9';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Description

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Task Details'
WHERE
   "ID" = '53F5B3E8-7220-48BD-A8E7-AEA68A83CB82';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.TypeID

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Task Details'
WHERE
   "ID" = '7EA597ED-DA32-4CBC-A774-AD5E1986586A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CategoryID

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Task Details'
WHERE
   "ID" = '4E328156-A0FF-4D3F-8C01-C75B89F235A6';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.ParentID

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Task Details'
WHERE
   "ID" = 'D419FC58-9802-454E-8D34-1DFAEBEE7DF4';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Type

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Task Details'
WHERE
   "ID" = '5E003CC8-55FC-4401-A7D9-7687BE6BD753';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Category

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Task Details'
WHERE
   "ID" = '411B26C4-2AEC-41EB-96C1-897C92770598';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Parent

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Task Details'
WHERE
   "ID" = '16BEA5BD-358F-4E40-AB62-09BE3478345F';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Status

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Status and Priority'
WHERE
   "ID" = '832E90CA-B150-4B19-AACE-F5385DB15E64';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Priority

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Status and Priority'
WHERE
   "ID" = 'BB921C78-2BAD-4B36-B7CB-E4A471372340';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.StartedAt

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Timeline and Progress'
WHERE
   "ID" = '3C7731EA-D59C-4DB0-9A48-D2C40F7EFF04';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.DueAt

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Timeline and Progress'
WHERE
   "ID" = 'E50C83FB-BB14-4DAB-B1A5-9BC108988D7B';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CompletedAt

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Timeline and Progress'
WHERE
   "ID" = '3B2893B6-9E68-4563-B25B-FEB90FEFF201';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.HoursEstimated

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Timeline and Progress'
WHERE
   "ID" = '0CF37CC9-7B64-4E9C-A79A-B7CF5BE85244';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.HoursActual

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Timeline and Progress'
WHERE
   "ID" = '7DC18266-AE9A-42F2-BF47-B406842712B8';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.PercentComplete

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Timeline and Progress'
WHERE
   "ID" = '5812F201-256C-47AC-AEEB-3402FD1E9846';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Sequence

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Timeline and Progress'
WHERE
   "ID" = '34C579D6-1FB8-4353-8F38-E75764139826';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.BlockedReason

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Timeline and Progress'
WHERE
   "ID" = '72888BFB-A442-414A-96C5-6D8B3A3AA67F';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CompletionNotes

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Timeline and Progress'
WHERE
   "ID" = '0A2F1BE2-D205-47E7-A804-679C04348EFC';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.OverdueNotifiedAt

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Timeline and Progress'
WHERE
   "ID" = '65CB1110-12E0-4E48-BED3-6BF1B2926807';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CreatedByPersonID

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Ownership and Audit'
WHERE
   "ID" = '0259C564-2DFE-480B-9075-3FD4C71FA46C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CreatedByPerson

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Ownership and Audit'
WHERE
   "ID" = '4EE84219-D7CB-408F-8EAD-410973B487AF';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.__mj_CreatedAt

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'System Metadata'
WHERE
   "ID" = 'DA16A787-212A-43BD-87E4-4D239F3EB12C';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.__mj_UpdatedAt

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'System Metadata'
WHERE
   "ID" = '8711F2AD-0BDC-4398-819F-F87F1D11F34A';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.PredictedSLABreachProbability

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Predictive SLA Metrics',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'SLA Breach Probability'
WHERE
   "ID" = '33D3756E-8AC7-4A57-BE61-946D1AE7C2D6';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.PredictedSLARiskBand

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Predictive SLA Metrics',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'SLA Risk Band'
WHERE
   "ID" = '54214DDA-792C-4A7A-A6C0-115BA1C90AAB';

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.PredictedSLAScoredAt

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Predictive SLA Metrics',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'SLA Scored At'
WHERE
   "ID" = 'A92EAF03-B039-4DC4-931C-8C6D7C038217';

/* Set entity icon to fa fa-tasks */


               UPDATE ${mjSchema}."Entity"
               SET "Icon" = 'fa fa-tasks', "__mj_UpdatedAt" = NOW()
               WHERE "ID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466';


-- ===================== Other =====================

/* Set categories for 28 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.ID
