-- ============================================================================
-- PostgreSQL counterpart of migrations/V202610171900__v1.9.x__Task_Priority_OKR_And_CheckIns.sql
-- Sections 1-3 (Task priority / OKR columns, the TaskCheckIn table, layered vwTasksGenerated/vwTasks)
-- are written by hand from the T-SQL. Metadata DML is converted from the T-SQL; the CodeGen sections
-- are native PostgreSQL CodeGen (MJ 6.1.6), not translated T-SQL.
-- ============================================================================

SET search_path TO __mj_bizappstasks, public;
SET standard_conforming_strings = on;

---------------------------------------------------------------------------
-- 1. Task: Add Priority / OKR & Check-In Rhythm Columns
---------------------------------------------------------------------------
ALTER TABLE __mj_bizappstasks."Task"
 ADD COLUMN "HealthStatus" VARCHAR(20) NULL,
 ADD COLUMN "ConfidenceScore" INTEGER NULL,
 ADD COLUMN "BaselineValue" DECIMAL(18, 4) NULL,
 ADD COLUMN "TargetValue" DECIMAL(18, 4) NULL,
 ADD COLUMN "CurrentValue" DECIMAL(18, 4) NULL,
 ADD COLUMN "UnitOfMeasure" VARCHAR(50) NULL,
 ADD COLUMN "MetricDirection" VARCHAR(20) NULL,
 ADD COLUMN "RollupWeight" DECIMAL(8, 2) NOT NULL DEFAULT 1.00,
 ADD COLUMN "PlanningPeriod" VARCHAR(50) NULL,
 ADD COLUMN "CheckInCadence" VARCHAR(20) NULL,
 ADD COLUMN "LastCheckInAt" TIMESTAMPTZ NULL,
 ADD COLUMN "NextCheckInDueAt" TIMESTAMPTZ NULL;

ALTER TABLE __mj_bizappstasks."Task"
 ADD CONSTRAINT CK_Task_HealthStatus
     CHECK ("HealthStatus" IS NULL OR "HealthStatus" IN ('OnTrack', 'AtRisk', 'OffTrack', 'Completed', 'Paused')),
 ADD CONSTRAINT CK_Task_ConfidenceScore
     CHECK ("ConfidenceScore" IS NULL OR ("ConfidenceScore" >= 0 AND "ConfidenceScore" <= 100)),
 ADD CONSTRAINT CK_Task_MetricDirection
     CHECK ("MetricDirection" IS NULL OR "MetricDirection" IN ('Increase', 'Decrease', 'Maintain')),
 ADD CONSTRAINT CK_Task_CheckInCadence
     CHECK ("CheckInCadence" IS NULL OR "CheckInCadence" IN ('Daily', 'Weekly', 'BiWeekly', 'Monthly', 'Quarterly', 'None'));

COMMENT ON COLUMN __mj_bizappstasks."Task"."HealthStatus" IS 'Qualitative health status for priority/OKR tracking: OnTrack, AtRisk, OffTrack, Completed, or Paused.';
COMMENT ON COLUMN __mj_bizappstasks."Task"."ConfidenceScore" IS 'Owner confidence score (0-100) that this task, key result, or objective will hit its target on time.';
COMMENT ON COLUMN __mj_bizappstasks."Task"."BaselineValue" IS 'Starting baseline value for measurable key results or quantitative deliverables.';
COMMENT ON COLUMN __mj_bizappstasks."Task"."TargetValue" IS 'Target goal value for measurable key results or quantitative deliverables.';
COMMENT ON COLUMN __mj_bizappstasks."Task"."CurrentValue" IS 'Latest actual measured value for this key result or deliverable, updated automatically by TaskCheckIn records.';
COMMENT ON COLUMN __mj_bizappstasks."Task"."UnitOfMeasure" IS 'Unit of measure for BaselineValue, TargetValue, and CurrentValue (e.g., %, USD, Days, Customers, NPS).';
COMMENT ON COLUMN __mj_bizappstasks."Task"."MetricDirection" IS 'Direction of improvement for quantitative metrics: Increase, Decrease, or Maintain.';
COMMENT ON COLUMN __mj_bizappstasks."Task"."RollupWeight" IS 'Relative weight (default 1.00) when rolling up child task or key result progress into a parent objective.';
COMMENT ON COLUMN __mj_bizappstasks."Task"."PlanningPeriod" IS 'Planning horizon or OKR cycle identifier (e.g., 2026-Q4, FY2027, H1-2026).';
COMMENT ON COLUMN __mj_bizappstasks."Task"."CheckInCadence" IS 'Expected progress check-in frequency: Daily, Weekly, BiWeekly, Monthly, Quarterly, or None.';
COMMENT ON COLUMN __mj_bizappstasks."Task"."LastCheckInAt" IS 'Timestamp when the most recent TaskCheckIn was recorded for this task.';
COMMENT ON COLUMN __mj_bizappstasks."Task"."NextCheckInDueAt" IS 'Timestamp when the next progress check-in is due based on CheckInCadence; used by Chief of Staff to nudge owners.';

---------------------------------------------------------------------------
-- 2. TaskCheckIn: Structured periodic progress updates for Tasks / OKRs
---------------------------------------------------------------------------
CREATE TABLE __mj_bizappstasks."TaskCheckIn" (
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
 CONSTRAINT PK_TaskCheckIn PRIMARY KEY ("ID"),
 CONSTRAINT FK_TaskCheckIn_Task FOREIGN KEY ("TaskID") REFERENCES __mj_bizappstasks."Task"("ID"),
 CONSTRAINT FK_TaskCheckIn_AuthorPerson FOREIGN KEY ("AuthorPersonID") REFERENCES __mj_bizappscommon."Person"("ID"),
 CONSTRAINT FK_TaskCheckIn_AuthorUser FOREIGN KEY ("AuthorUserID") REFERENCES ${mjSchema}."User"("ID"),
 CONSTRAINT FK_TaskCheckIn_AIAgent FOREIGN KEY ("ReportedByAIAgentID") REFERENCES ${mjSchema}."AIAgent"("ID"),
 CONSTRAINT CK_TaskCheckIn_HealthStatus CHECK ("HealthStatus" IN ('OnTrack', 'AtRisk', 'OffTrack', 'Completed', 'Paused')),
 CONSTRAINT CK_TaskCheckIn_ConfidenceScore CHECK ("ConfidenceScore" IS NULL OR ("ConfidenceScore" >= 0 AND "ConfidenceScore" <= 100)),
 CONSTRAINT CK_TaskCheckIn_PercentComplete CHECK ("PercentComplete" IS NULL OR ("PercentComplete" >= 0 AND "PercentComplete" <= 100))
);

COMMENT ON TABLE __mj_bizappstasks."TaskCheckIn" IS 'Structured periodic progress check-ins for tasks, priorities, and OKRs, authored by users or AI agents such as Chief of Staff.';
COMMENT ON COLUMN __mj_bizappstasks."TaskCheckIn"."TaskID" IS 'The task, priority objective, or key result this check-in updates.';
COMMENT ON COLUMN __mj_bizappstasks."TaskCheckIn"."AuthorPersonID" IS 'Optional Person record who authored or approved the check-in.';
COMMENT ON COLUMN __mj_bizappstasks."TaskCheckIn"."AuthorUserID" IS 'Optional MemberJunction User who authored or submitted the check-in.';
COMMENT ON COLUMN __mj_bizappstasks."TaskCheckIn"."ReportedByAIAgentID" IS 'Optional AI Agent (e.g., Chief of Staff) that synthesized and recorded this check-in.';
COMMENT ON COLUMN __mj_bizappstasks."TaskCheckIn"."CheckInAt" IS 'Timestamp when the check-in occurred.';
COMMENT ON COLUMN __mj_bizappstasks."TaskCheckIn"."HealthStatus" IS 'Health status reported at check-in: OnTrack, AtRisk, OffTrack, Completed, or Paused.';
COMMENT ON COLUMN __mj_bizappstasks."TaskCheckIn"."ConfidenceScore" IS 'Confidence score (0-100) reported at the time of check-in.';
COMMENT ON COLUMN __mj_bizappstasks."TaskCheckIn"."PreviousValue" IS 'Metric value prior to this check-in.';
COMMENT ON COLUMN __mj_bizappstasks."TaskCheckIn"."NewValue" IS 'Updated metric value reported in this check-in.';
COMMENT ON COLUMN __mj_bizappstasks."TaskCheckIn"."PercentComplete" IS 'Percent complete (0-100) reported or computed in this check-in.';
COMMENT ON COLUMN __mj_bizappstasks."TaskCheckIn"."Summary" IS 'Narrative summary of accomplishments and status since the last check-in.';
COMMENT ON COLUMN __mj_bizappstasks."TaskCheckIn"."Blockers" IS 'Risks, impediments, or cross-team blockers surfaced during the check-in.';
COMMENT ON COLUMN __mj_bizappstasks."TaskCheckIn"."NextSteps" IS 'Planned next steps and commitments before the next check-in.';

---------------------------------------------------------------------------
-- 3. Refresh Layered Base Views (vwTasksGenerated & vwTasks)
---------------------------------------------------------------------------
-- Task gained columns, and a PostgreSQL view fixes its column list when it is created, so both
-- layers are rebuilt. The bodies are unchanged from the v1.5.0 migration.
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

/* ============================================================================= */
/* GENERATED BY MemberJunction CodeGen — DO NOT EDIT BY HAND */
/* ============================================================================= */
/* SQL generated to create new entity MJ_BizApps_Tasks: Task Check Ins */
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
  "UserViewMaxRows",
  "__mj_CreatedAt",
  "__mj_UpdatedAt"
)
VALUES
  (
    '360ce0db-7207-4d3c-a35f-2f45c22a5399',
    'MJ_BizApps_Tasks: Task Check Ins',
    'Task Check Ins',
    'Structured periodic progress check-ins for tasks, priorities, and OKRs, authored by users or AI agents such as Chief of Staff.',
    NULL,
    'TaskCheckIn',
    'vwTaskCheckIns',
    '__mj_bizappstasks',
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
    1000,
    NOW(),
    NOW()
  );
/* SQL generated to add new entity MJ_BizApps_Tasks: Task Check Ins to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO ${mjSchema}."ApplicationEntity" (
  "ApplicationID",
  "EntityID",
  "Sequence",
  "__mj_CreatedAt",
  "__mj_UpdatedAt"
)
VALUES
  (
    '22541055-8ED4-4850-8ACD-E5EE1887B15B',
    '360ce0db-7207-4d3c-a35f-2f45c22a5399',
    (
      SELECT
        COALESCE(MAX("Sequence"), 0) + 1
      FROM ${mjSchema}."ApplicationEntity"
      WHERE
        "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'
    ),
    NOW(),
    NOW()
  );
/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Check Ins for role UI */
INSERT INTO ${mjSchema}."EntityPermission" (
  "EntityID",
  "RoleID",
  "Type",
  "CanRead",
  "CanCreate",
  "CanUpdate",
  "CanDelete",
  "__mj_CreatedAt",
  "__mj_UpdatedAt"
)
SELECT
  CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS UUID),
  CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID),
  'Allow',
  CAST(1 AS BOOLEAN),
  CAST(0 AS BOOLEAN),
  CAST(0 AS BOOLEAN),
  CAST(0 AS BOOLEAN),
  NOW(),
  NOW()
WHERE
  NOT EXISTS(
    SELECT
      1
    FROM ${mjSchema}."EntityPermission"
    WHERE
      "EntityID" = CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS UUID)
      AND "RoleID" = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID)
      AND "Type" = 'Allow'
  );
/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Check Ins for role Developer */
INSERT INTO ${mjSchema}."EntityPermission" (
  "EntityID",
  "RoleID",
  "Type",
  "CanRead",
  "CanCreate",
  "CanUpdate",
  "CanDelete",
  "__mj_CreatedAt",
  "__mj_UpdatedAt"
)
SELECT
  CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS UUID),
  CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID),
  'Allow',
  CAST(1 AS BOOLEAN),
  CAST(1 AS BOOLEAN),
  CAST(1 AS BOOLEAN),
  CAST(1 AS BOOLEAN),
  NOW(),
  NOW()
WHERE
  NOT EXISTS(
    SELECT
      1
    FROM ${mjSchema}."EntityPermission"
    WHERE
      "EntityID" = CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS UUID)
      AND "RoleID" = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID)
      AND "Type" = 'Allow'
  );
/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Check Ins for role Integration */
INSERT INTO ${mjSchema}."EntityPermission" (
  "EntityID",
  "RoleID",
  "Type",
  "CanRead",
  "CanCreate",
  "CanUpdate",
  "CanDelete",
  "__mj_CreatedAt",
  "__mj_UpdatedAt"
)
SELECT
  CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS UUID),
  CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID),
  'Allow',
  CAST(1 AS BOOLEAN),
  CAST(1 AS BOOLEAN),
  CAST(1 AS BOOLEAN),
  CAST(1 AS BOOLEAN),
  NOW(),
  NOW()
WHERE
  NOT EXISTS(
    SELECT
      1
    FROM ${mjSchema}."EntityPermission"
    WHERE
      "EntityID" = CAST('360ce0db-7207-4d3c-a35f-2f45c22a5399' AS UUID)
      AND "RoleID" = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID)
      AND "Type" = 'Allow'
  );
ALTER TABLE __mj_bizappstasks."TaskCheckIn"
ADD COLUMN "__mj_CreatedAt" TIMESTAMPTZ NULL /* SQL text to update existing entities from schema */ /* SQL text to add special date field __mj_CreatedAt to entity __mj_bizappstasks.TaskCheckIn */;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_bizappstasks.TaskCheckIn */
UPDATE __mj_bizappstasks."TaskCheckIn" SET "__mj_CreatedAt" = NOW()
WHERE
  "__mj_CreatedAt" IS NULL;

DO $$
DECLARE r RECORD;
BEGIN
  FOR r IN
    SELECT DISTINCT ns.nspname AS sch, dv.relname AS vw
    FROM pg_depend d
    JOIN pg_rewrite rw ON rw.oid = d.objid
    JOIN pg_class dv ON dv.oid = rw.ev_class AND dv.relkind = 'v'
    JOIN pg_namespace ns ON ns.oid = dv.relnamespace
    JOIN pg_class tc ON tc.oid = d.refobjid
    JOIN pg_attribute a ON a.attrelid = tc.oid AND a.attnum = d.refobjsubid
    WHERE tc.relname = 'TaskCheckIn' AND a.attname = '__mj_CreatedAt'
  LOOP
    EXECUTE format('DROP VIEW IF EXISTS %I.%I CASCADE', r.sch, r.vw);
  END LOOP;
END $$;
ALTER TABLE __mj_bizappstasks."TaskCheckIn" ALTER COLUMN "__mj_CreatedAt" TYPE TIMESTAMPTZ, ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE __mj_bizappstasks."TaskCheckIn" ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

ALTER TABLE __mj_bizappstasks."TaskCheckIn"
ADD COLUMN "__mj_UpdatedAt" TIMESTAMPTZ NULL /* SQL text to add special date field __mj_UpdatedAt to entity __mj_bizappstasks.TaskCheckIn */;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_bizappstasks.TaskCheckIn */
UPDATE __mj_bizappstasks."TaskCheckIn" SET "__mj_UpdatedAt" = NOW()
WHERE
  "__mj_UpdatedAt" IS NULL;

DO $$
DECLARE r RECORD;
BEGIN
  FOR r IN
    SELECT DISTINCT ns.nspname AS sch, dv.relname AS vw
    FROM pg_depend d
    JOIN pg_rewrite rw ON rw.oid = d.objid
    JOIN pg_class dv ON dv.oid = rw.ev_class AND dv.relkind = 'v'
    JOIN pg_namespace ns ON ns.oid = dv.relnamespace
    JOIN pg_class tc ON tc.oid = d.refobjid
    JOIN pg_attribute a ON a.attrelid = tc.oid AND a.attnum = d.refobjsubid
    WHERE tc.relname = 'TaskCheckIn' AND a.attname = '__mj_UpdatedAt'
  LOOP
    EXECUTE format('DROP VIEW IF EXISTS %I.%I CASCADE', r.sch, r.vw);
  END LOOP;
END $$;
ALTER TABLE __mj_bizappstasks."TaskCheckIn" ALTER COLUMN "__mj_UpdatedAt" TYPE TIMESTAMPTZ, ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE __mj_bizappstasks."TaskCheckIn" ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'b4b892af-baa4-4ecd-a99b-1a34bbb21723' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'ID')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('b4b892af-baa4-4ecd-a99b-1a34bbb21723', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'ID', 'ID', NULL, 'uniqueidentifier', 16, 0, 0, FALSE, 'newsequentialid()', FALSE, FALSE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '228c3ad3-a70a-44ab-8d35-49acd8450741' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'TaskID')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('228c3ad3-a70a-44ab-8d35-49acd8450741', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'TaskID', 'Task ID', 'The task, priority objective, or key result this check-in updates.', 'uniqueidentifier', 16, 0, 0, FALSE, NULL, FALSE, TRUE, FALSE, FALSE, 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'ID', FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'c7db972b-3cb3-48ab-81ef-ac4f4d9801a1' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'AuthorPersonID')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('c7db972b-3cb3-48ab-81ef-ac4f4d9801a1', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'AuthorPersonID', 'Author Person ID', 'Optional Person record who authored or approved the check-in.', 'uniqueidentifier', 16, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'ID', FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '8b69c4d1-c536-4063-b775-fbee891cca7a' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'AuthorUserID')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('8b69c4d1-c536-4063-b775-fbee891cca7a', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'AuthorUserID', 'Author User ID', 'Optional MemberJunction User who authored or submitted the check-in.', 'uniqueidentifier', 16, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, 'E1238F34-2837-EF11-86D4-6045BDEE16E6', 'ID', FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '8d0d30ae-8449-4921-b155-3eb275e824d1' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'ReportedByAIAgentID')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('8d0d30ae-8449-4921-b155-3eb275e824d1', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'ReportedByAIAgentID', 'Reported By AI Agent ID', 'Optional AI Agent (e.g., Chief of Staff) that synthesized and recorded this check-in.', 'uniqueidentifier', 16, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, 'CDB135CC-6D3C-480B-90AE-25B7805F82C1', 'ID', FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '9637e429-90e1-4016-9be7-635b0c446dfc' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'CheckInAt')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('9637e429-90e1-4016-9be7-635b0c446dfc', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'CheckInAt', 'Check In At', 'Timestamp when the check-in occurred.', 'datetimeoffset', 10, 34, 7, FALSE, 'sysdatetimeoffset()', FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '7da8b600-d924-4822-b80b-b273cb41feab' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'HealthStatus')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('7da8b600-d924-4822-b80b-b273cb41feab', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'HealthStatus', 'Health Status', 'Health status reported at check-in: OnTrack, AtRisk, OffTrack, Completed, or Paused.', 'nvarchar', 40, 0, 0, FALSE, 'OnTrack', FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '9fc7a284-c3df-4b94-910d-c2460dbde8ab' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'ConfidenceScore')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('9fc7a284-c3df-4b94-910d-c2460dbde8ab', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'ConfidenceScore', 'Confidence Score', 'Confidence score (0-100) reported at the time of check-in.', 'int', 4, 10, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '6df3ec7b-6920-4a83-a2f0-afc43a64a91b' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'PreviousValue')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('6df3ec7b-6920-4a83-a2f0-afc43a64a91b', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'PreviousValue', 'Previous Value', 'Metric value prior to this check-in.', 'decimal', 9, 18, 4, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '3db75504-f5f0-4f85-8bbf-5e8ff7e6932b' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'NewValue')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('3db75504-f5f0-4f85-8bbf-5e8ff7e6932b', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'NewValue', 'New Value', 'Updated metric value reported in this check-in.', 'decimal', 9, 18, 4, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'd4261555-e5e9-4b47-9c76-c212559758de' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'PercentComplete')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('d4261555-e5e9-4b47-9c76-c212559758de', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'PercentComplete', 'Percent Complete', 'Percent complete (0-100) reported or computed in this check-in.', 'int', 4, 10, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '5bd1ecac-1336-4545-82b7-54f7d773c10c' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'Summary')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('5bd1ecac-1336-4545-82b7-54f7d773c10c', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'Summary', 'Summary', 'Narrative summary of accomplishments and status since the last check-in.', 'nvarchar', -1, 0, 0, FALSE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '05563452-fab1-4bbc-81c1-4c0949f62e87' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'Blockers')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('05563452-fab1-4bbc-81c1-4c0949f62e87', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'Blockers', 'Blockers', 'Risks, impediments, or cross-team blockers surfaced during the check-in.', 'nvarchar', -1, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '393f9b09-36a3-4bc2-9b79-8dd6218d265d' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'NextSteps')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('393f9b09-36a3-4bc2-9b79-8dd6218d265d', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'NextSteps', 'Next Steps', 'Planned next steps and commitments before the next check-in.', 'nvarchar', -1, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '515acc10-2c6a-4cc7-a720-0fc2d8427ef0' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = '__mj_CreatedAt')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('515acc10-2c6a-4cc7-a720-0fc2d8427ef0', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), '__mj_CreatedAt', 'Created At', NULL, 'datetimeoffset', 10, 34, 7, FALSE, 'getutcdate()', FALSE, FALSE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'd6ec2e84-5bf9-495a-a614-6221af56e9ba' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = '__mj_UpdatedAt')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('d6ec2e84-5bf9-495a-a614-6221af56e9ba', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), '__mj_UpdatedAt', 'Updated At', NULL, 'datetimeoffset', 10, 34, 7, FALSE, 'getutcdate()', FALSE, FALSE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '7532fdf8-d979-441e-9dad-8d3f9e55a84e' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'HealthStatus')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('7532fdf8-d979-441e-9dad-8d3f9e55a84e', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'HealthStatus', 'Health Status', 'Qualitative health status for priority/OKR tracking: OnTrack, AtRisk, OffTrack, Completed, or Paused.', 'nvarchar', 40, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'a5ca80f8-1ab4-43df-98ec-926d88c95da0' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'ConfidenceScore')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('a5ca80f8-1ab4-43df-98ec-926d88c95da0', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'ConfidenceScore', 'Confidence Score', 'Owner confidence score (0-100) that this task, key result, or objective will hit its target on time.', 'int', 4, 10, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '07437566-1823-4882-b196-b4473a824190' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'BaselineValue')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('07437566-1823-4882-b196-b4473a824190', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'BaselineValue', 'Baseline Value', 'Starting baseline value for measurable key results or quantitative deliverables.', 'decimal', 9, 18, 4, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '346dcca6-8dd6-40f4-ad44-0adae04afa36' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'TargetValue')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('346dcca6-8dd6-40f4-ad44-0adae04afa36', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'TargetValue', 'Target Value', 'Target goal value for measurable key results or quantitative deliverables.', 'decimal', 9, 18, 4, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'eeeb991a-70c8-4ae1-a1bc-859047d74135' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'CurrentValue')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('eeeb991a-70c8-4ae1-a1bc-859047d74135', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'CurrentValue', 'Current Value', 'Latest actual measured value for this key result or deliverable, updated automatically by TaskCheckIn records.', 'decimal', 9, 18, 4, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'af223c6d-6f70-4c13-8bf6-c61aa27173f8' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'UnitOfMeasure')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('af223c6d-6f70-4c13-8bf6-c61aa27173f8', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'UnitOfMeasure', 'Unit Of Measure', 'Unit of measure for BaselineValue, TargetValue, and CurrentValue (e.g., %, USD, Days, Customers, NPS).', 'nvarchar', 100, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'defbd4e1-c3c0-48d4-b297-b4c1ebe75a56' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'MetricDirection')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('defbd4e1-c3c0-48d4-b297-b4c1ebe75a56', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'MetricDirection', 'Metric Direction', 'Direction of improvement for quantitative metrics: Increase, Decrease, or Maintain.', 'nvarchar', 40, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '65e2f993-2fe6-4889-9d58-e57ecfbfc82a' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'RollupWeight')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('65e2f993-2fe6-4889-9d58-e57ecfbfc82a', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'RollupWeight', 'Rollup Weight', 'Relative weight (default 1.00) when rolling up child task or key result progress into a parent objective.', 'decimal', 5, 8, 2, FALSE, '(1.00)', FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'ab060b49-73e6-4925-a734-772a6e615a1e' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'PlanningPeriod')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('ab060b49-73e6-4925-a734-772a6e615a1e', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'PlanningPeriod', 'Planning Period', 'Planning horizon or OKR cycle identifier (e.g., 2026-Q4, FY2027, H1-2026).', 'nvarchar', 100, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'cbbe3a1d-b115-4906-af54-42adce9a5973' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'CheckInCadence')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('cbbe3a1d-b115-4906-af54-42adce9a5973', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'CheckInCadence', 'Check In Cadence', 'Expected progress check-in frequency: Daily, Weekly, BiWeekly, Monthly, Quarterly, or None.', 'nvarchar', 40, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'df95636f-e402-40e1-a53c-7abb34996f9e' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'LastCheckInAt')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('df95636f-e402-40e1-a53c-7abb34996f9e', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'LastCheckInAt', 'Last Check In At', 'Timestamp when the most recent TaskCheckIn was recorded for this task.', 'datetimeoffset', 10, 34, 7, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '3828d96c-44e3-40c8-a907-b7a916a829d6' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'NextCheckInDueAt')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('3828d96c-44e3-40c8-a907-b7a916a829d6', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'), 'NextCheckInDueAt', 'Next Check In Due At', 'Timestamp when the next progress check-in is due based on CheckInCadence; used by Chief of Staff to nudge owners.', 'datetimeoffset', 10, 34, 7, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

/* SQL text to update existing entity fields from schema */
/* SQL text to set default column width where needed */
/* SQL text to insert entity field value with ID 2d1da61d-caae-490a-b3c5-9b9eeea3e98b */
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
    '2d1da61d-caae-490a-b3c5-9b9eeea3e98b',
    '7532FDF8-D979-441E-9DAD-8D3F9E55A84E',
    1,
    'AtRisk',
    'AtRisk',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID 0e381e48-b41d-49dc-8c77-2a3e2412f240 */
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
    '0e381e48-b41d-49dc-8c77-2a3e2412f240',
    '7532FDF8-D979-441E-9DAD-8D3F9E55A84E',
    2,
    'Completed',
    'Completed',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID a35bd3a6-b328-4b8b-87a4-1d7b2f68588d */
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
    'a35bd3a6-b328-4b8b-87a4-1d7b2f68588d',
    '7532FDF8-D979-441E-9DAD-8D3F9E55A84E',
    3,
    'OffTrack',
    'OffTrack',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID 78bd5be3-62e9-4254-8119-d5bdf1025cf3 */
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
    '78bd5be3-62e9-4254-8119-d5bdf1025cf3',
    '7532FDF8-D979-441E-9DAD-8D3F9E55A84E',
    4,
    'OnTrack',
    'OnTrack',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID f3b28978-4d13-43b7-92cf-9c50cdb97c82 */
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
    'f3b28978-4d13-43b7-92cf-9c50cdb97c82',
    '7532FDF8-D979-441E-9DAD-8D3F9E55A84E',
    5,
    'Paused',
    'Paused',
    NOW(),
    NOW()
  );
/* SQL text to update ValueListType for entity field ID 7532FDF8-D979-441E-9DAD-8D3F9E55A84E */
UPDATE ${mjSchema}."EntityField" SET "ValueListType" = 'List'
WHERE
  "ID" = '7532FDF8-D979-441E-9DAD-8D3F9E55A84E';
/* SQL text to insert entity field value with ID 71809b6d-bfff-494a-a139-bf7569cffbe6 */
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
    '71809b6d-bfff-494a-a139-bf7569cffbe6',
    'DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56',
    1,
    'Decrease',
    'Decrease',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID f3e5ad4a-7f3a-40bc-86e8-eb996023d911 */
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
    'f3e5ad4a-7f3a-40bc-86e8-eb996023d911',
    'DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56',
    2,
    'Increase',
    'Increase',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID ef71a1bc-8503-4807-85c6-4236a4dd4935 */
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
    'ef71a1bc-8503-4807-85c6-4236a4dd4935',
    'DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56',
    3,
    'Maintain',
    'Maintain',
    NOW(),
    NOW()
  );
/* SQL text to update ValueListType for entity field ID DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56 */
UPDATE ${mjSchema}."EntityField" SET "ValueListType" = 'List'
WHERE
  "ID" = 'DEFBD4E1-C3C0-48D4-B297-B4C1EBE75A56';
/* SQL text to insert entity field value with ID e73100ea-6879-482c-9c65-8e395393e188 */
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
    'e73100ea-6879-482c-9c65-8e395393e188',
    'CBBE3A1D-B115-4906-AF54-42ADCE9A5973',
    1,
    'BiWeekly',
    'BiWeekly',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID 98aa8d90-4fa6-4c4d-9b8e-89d51989ab37 */
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
    '98aa8d90-4fa6-4c4d-9b8e-89d51989ab37',
    'CBBE3A1D-B115-4906-AF54-42ADCE9A5973',
    2,
    'Daily',
    'Daily',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID a48f70e4-69ba-4206-b424-9dee180a251e */
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
    'a48f70e4-69ba-4206-b424-9dee180a251e',
    'CBBE3A1D-B115-4906-AF54-42ADCE9A5973',
    3,
    'Monthly',
    'Monthly',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID e092392b-f130-4856-abe2-3d060e590282 */
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
    'e092392b-f130-4856-abe2-3d060e590282',
    'CBBE3A1D-B115-4906-AF54-42ADCE9A5973',
    4,
    'None',
    'None',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID 0e6a25c1-3213-4dae-9686-f8d688af2102 */
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
    '0e6a25c1-3213-4dae-9686-f8d688af2102',
    'CBBE3A1D-B115-4906-AF54-42ADCE9A5973',
    5,
    'Quarterly',
    'Quarterly',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID 50d54b01-1df3-4d74-bd73-438708ef0548 */
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
    '50d54b01-1df3-4d74-bd73-438708ef0548',
    'CBBE3A1D-B115-4906-AF54-42ADCE9A5973',
    6,
    'Weekly',
    'Weekly',
    NOW(),
    NOW()
  );
/* SQL text to update ValueListType for entity field ID CBBE3A1D-B115-4906-AF54-42ADCE9A5973 */
UPDATE ${mjSchema}."EntityField" SET "ValueListType" = 'List'
WHERE
  "ID" = 'CBBE3A1D-B115-4906-AF54-42ADCE9A5973';
/* SQL text to insert entity field value with ID 0509c923-75c4-422c-a0b0-a45c5977d773 */
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
    '0509c923-75c4-422c-a0b0-a45c5977d773',
    '7DA8B600-D924-4822-B80B-B273CB41FEAB',
    1,
    'AtRisk',
    'AtRisk',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID 3634dd1f-e2b1-4d25-aa82-5eddf33fb266 */
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
    '3634dd1f-e2b1-4d25-aa82-5eddf33fb266',
    '7DA8B600-D924-4822-B80B-B273CB41FEAB',
    2,
    'Completed',
    'Completed',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID f0595906-74aa-4efd-83e9-c7297878277b */
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
    'f0595906-74aa-4efd-83e9-c7297878277b',
    '7DA8B600-D924-4822-B80B-B273CB41FEAB',
    3,
    'OffTrack',
    'OffTrack',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID 71da79a8-c0ed-4fc5-b9b1-1166a4a038c9 */
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
    '71da79a8-c0ed-4fc5-b9b1-1166a4a038c9',
    '7DA8B600-D924-4822-B80B-B273CB41FEAB',
    4,
    'OnTrack',
    'OnTrack',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID 7ec8681c-c3c2-468d-925e-27293a06a4bd */
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
    '7ec8681c-c3c2-468d-925e-27293a06a4bd',
    '7DA8B600-D924-4822-B80B-B273CB41FEAB',
    5,
    'Paused',
    'Paused',
    NOW(),
    NOW()
  );
/* SQL text to update ValueListType for entity field ID 7DA8B600-D924-4822-B80B-B273CB41FEAB */
UPDATE ${mjSchema}."EntityField" SET "ValueListType" = 'List'
WHERE
  "ID" = '7DA8B600-D924-4822-B80B-B273CB41FEAB';
/* Deterministic search-flag hygiene — clear AllowUserSearchAPI */
-- The excluded schema names are lowercase here: PostgreSQL stores them folded, so the T-SQL
-- spelling would exclude nothing.
UPDATE ${mjSchema}."Entity" SET "AllowUserSearchAPI" = CAST(0 AS BOOLEAN)
WHERE
  "ID" IN (
    SELECT
      "e"."ID"
    FROM ${mjSchema}."Entity" AS "e"
    WHERE
      "e"."AllowUserSearchAPI" = CAST(1 AS BOOLEAN)
      AND "e"."AutoUpdateAllowUserSearchAPI" = CAST(1 AS BOOLEAN)
      AND "e"."VirtualEntity" = CAST(0 AS BOOLEAN)
      AND COALESCE("e"."FullTextSearchEnabled", CAST(0 AS BOOLEAN)) = CAST(0 AS BOOLEAN)
      AND NOT "e"."SchemaName" IN (
        '${mjSchema}',
        '__mj_bizappscommon',
        '__mj_bizappscontactcenter',
        '__mj_bizappsissues',
        'sys'
      )
      AND NOT EXISTS(
        SELECT
          1
        FROM ${mjSchema}."EntityField" AS "f2"
        WHERE
          "f2"."EntityID" = "e"."ID" AND "f2"."IncludeInUserSearchAPI" = CAST(1 AS BOOLEAN)
      )
  );
/* Create Entity Relationship: MJ: AI Agents -> MJ_BizApps_Tasks: Task Check Ins (One To Many via ReportedByAIAgentID) */;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '973f7e5e-ab65-4858-b1f3-fc2c612dc1c7') THEN
    INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('973f7e5e-ab65-4858-b1f3-fc2c612dc1c7', 'CDB135CC-6D3C-480B-90AE-25B7805F82C1', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'ReportedByAIAgentID', 'One To Many', TRUE, TRUE, 47, NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '4d8b4b49-872a-4806-a86d-ba9c6eb69b86') THEN
    INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('4d8b4b49-872a-4806-a86d-ba9c6eb69b86', 'E1238F34-2837-EF11-86D4-6045BDEE16E6', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'AuthorUserID', 'One To Many', TRUE, TRUE, 128, NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = 'e58a89a6-4df2-4216-bfe3-f52b32f7c381') THEN
    INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('e58a89a6-4df2-4216-bfe3-f52b32f7c381', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'AuthorPersonID', 'One To Many', TRUE, TRUE, 16, NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '703bbb06-9361-4b9b-bda7-5bb908f8415f') THEN
    INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('703bbb06-9361-4b9b-bda7-5bb908f8415f', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'TaskID', 'One To Many', TRUE, TRUE, 11, NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'f063969d-25e5-4e0d-95a6-94a16b756582' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'Task')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('f063969d-25e5-4e0d-95a6-94a16b756582', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'Task', 'Task', NULL, 'nvarchar', 510, 0, 0, FALSE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'f5f32716-4215-46f5-a128-cb8b9353656a' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'AuthorPerson')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('f5f32716-4215-46f5-a128-cb8b9353656a', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'AuthorPerson', 'Author Person', NULL, 'nvarchar', 500, 0, 0, TRUE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'a0c840e8-ff54-430c-b3ed-8224e9517af5' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'AuthorUser')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('a0c840e8-ff54-430c-b3ed-8224e9517af5', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'AuthorUser', 'Author User', NULL, 'nvarchar', 200, 0, 0, TRUE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '25f2a091-b01c-49a0-a5e2-b2f4036b27e6' OR ("EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'ReportedByAIAgent')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('25f2a091-b01c-49a0-a5e2-b2f4036b27e6', '360CE0DB-7207-4D3C-A35F-2F45C22A5399' /* Entity: MJ_BizApps_Tasks: Task Check Ins */, (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399'), 'ReportedByAIAgent', 'Reported By AI Agent', NULL, 'nvarchar', 510, 0, 0, TRUE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntitySetting" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'FieldCategoryInfo') THEN
    INSERT INTO ${mjSchema}."EntitySetting" ("ID", "EntityID", "Name", "Value", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('202ee568-9da4-5430-8ab5-d84859643fd9', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'FieldCategoryInfo', '{
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
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntitySetting" WHERE "EntityID" = '360CE0DB-7207-4D3C-A35F-2F45C22A5399' AND "Name" = 'FieldCategoryIcons') THEN
    INSERT INTO ${mjSchema}."EntitySetting" ("ID", "EntityID", "Name", "Value", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('8028c881-e7c6-5b67-bb21-7ae6ed9e5390', '360CE0DB-7207-4D3C-A35F-2F45C22A5399', 'FieldCategoryIcons', '{
  "Authorship and Agents": "fa fa-user-shield",
  "Check-In Details": "fa fa-calendar-check",
  "Progress Narrative": "fa fa-align-left",
  "Status and Metrics": "fa fa-chart-line",
  "System Metadata": "fa fa-cog"
}', NOW(), NOW());
  END IF;
END $$;

-- ===================== CodeGen (native PG, baked) =====================

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Check Ins
-- Item: Index for Foreign Keys
-- ============================================================
CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_check_in_task_id"
    ON "__mj_bizappstasks"."TaskCheckIn" ("TaskID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_check_in_author_person_id"
    ON "__mj_bizappstasks"."TaskCheckIn" ("AuthorPersonID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_check_in_author_user_id"
    ON "__mj_bizappstasks"."TaskCheckIn" ("AuthorUserID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_check_in_reported_by_ai_agent_id"
    ON "__mj_bizappstasks"."TaskCheckIn" ("ReportedByAIAgentID");

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Check Ins
-- Item: vwTaskCheckIns
-- ============================================================

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Check Ins
-----               SCHEMA:      __mj_bizappstasks
-----               BASE TABLE:  TaskCheckIn
-----               PRIMARY KEY: ID
------------------------------------------------------------
DO $vw_regen$
DECLARE
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_bizappstasks"."vwTaskCheckIns"
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID."Name" AS "Task",
    mjBizAppsCommonPerson_AuthorPersonID."DisplayName" AS "AuthorPerson",
    MJUser_AuthorUserID."Name" AS "AuthorUser",
    MJAIAgent_ReportedByAIAgentID."Name" AS "ReportedByAIAgent"
FROM
    "__mj_bizappstasks"."TaskCheckIn" AS t
INNER JOIN
    "__mj_bizappstasks"."Task" AS mjBizAppsTasksTask_TaskID
  ON
    "t"."TaskID" = mjBizAppsTasksTask_TaskID."ID"
LEFT OUTER JOIN
    "__mj_bizappscommon"."Person" AS mjBizAppsCommonPerson_AuthorPersonID
  ON
    "t"."AuthorPersonID" = mjBizAppsCommonPerson_AuthorPersonID."ID"
LEFT OUTER JOIN
    ${mjSchema}."User" AS MJUser_AuthorUserID
  ON
    "t"."AuthorUserID" = MJUser_AuthorUserID."ID"
LEFT OUTER JOIN
    ${mjSchema}."AIAgent" AS MJAIAgent_ReportedByAIAgentID
  ON
    "t"."ReportedByAIAgentID" = MJAIAgent_ReportedByAIAgentID."ID"
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
    AND tc.relname = 'vwTaskCheckIns'
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
    AND tc.relname = 'vwTaskCheckIns'
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
        AND tc.relname = 'vwTaskCheckIns'
        AND tc.relkind IN ('v', 'm')
  );

  DROP VIEW IF EXISTS "__mj_bizappstasks"."vwTaskCheckIns" CASCADE;
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
GRANT SELECT ON "__mj_bizappstasks"."vwTaskCheckIns" TO "cdp_UI";
GRANT SELECT ON "__mj_bizappstasks"."vwTaskCheckIns" TO "cdp_Developer";
GRANT SELECT ON "__mj_bizappstasks"."vwTaskCheckIns" TO "cdp_Integration";

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Check Ins
-- Item: spCreateTaskCheckIn
-- ============================================================

------------------------------------------------------------
----- CREATE FUNCTION FOR TaskCheckIn
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spCreateTaskCheckIn'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spCreateTaskCheckIn"(
    p_id UUID DEFAULT NULL,
    p_taskid UUID DEFAULT NULL,
    p_authorpersonid_clear boolean DEFAULT false,
    p_authorpersonid UUID DEFAULT NULL,
    p_authoruserid_clear boolean DEFAULT false,
    p_authoruserid UUID DEFAULT NULL,
    p_reportedbyaiagentid_clear boolean DEFAULT false,
    p_reportedbyaiagentid UUID DEFAULT NULL,
    p_checkinat TIMESTAMPTZ DEFAULT NULL,
    p_healthstatus varchar(20) DEFAULT NULL,
    p_confidencescore_clear boolean DEFAULT false,
    p_confidencescore int DEFAULT NULL,
    p_previousvalue_clear boolean DEFAULT false,
    p_previousvalue decimal(18, 4) DEFAULT NULL,
    p_newvalue_clear boolean DEFAULT false,
    p_newvalue decimal(18, 4) DEFAULT NULL,
    p_percentcomplete_clear boolean DEFAULT false,
    p_percentcomplete int DEFAULT NULL,
    p_summary TEXT DEFAULT NULL,
    p_blockers_clear boolean DEFAULT false,
    p_blockers TEXT DEFAULT NULL,
    p_nextsteps_clear boolean DEFAULT false,
    p_nextsteps TEXT DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwTaskCheckIns" AS $$
DECLARE
    v_new_id UUID;
BEGIN
    v_new_id := COALESCE(p_id, gen_random_uuid());
    INSERT INTO "__mj_bizappstasks"."TaskCheckIn"
        (
            "ID",
            "TaskID",
                "AuthorPersonID",
                "AuthorUserID",
                "ReportedByAIAgentID",
                "CheckInAt",
                "HealthStatus",
                "ConfidenceScore",
                "PreviousValue",
                "NewValue",
                "PercentComplete",
                "Summary",
                "Blockers",
                "NextSteps"
        )
    VALUES
        (
            v_new_id,
            p_taskid,
                CASE WHEN p_authorpersonid_clear = true THEN NULL ELSE COALESCE(p_authorpersonid, NULL) END,
                CASE WHEN p_authoruserid_clear = true THEN NULL ELSE COALESCE(p_authoruserid, NULL) END,
                CASE WHEN p_reportedbyaiagentid_clear = true THEN NULL ELSE COALESCE(p_reportedbyaiagentid, NULL) END,
                COALESCE(p_checkinat, NOW() AT TIME ZONE 'UTC'),
                COALESCE(p_healthstatus, 'OnTrack'),
                CASE WHEN p_confidencescore_clear = true THEN NULL ELSE COALESCE(p_confidencescore, NULL) END,
                CASE WHEN p_previousvalue_clear = true THEN NULL ELSE COALESCE(p_previousvalue, NULL) END,
                CASE WHEN p_newvalue_clear = true THEN NULL ELSE COALESCE(p_newvalue, NULL) END,
                CASE WHEN p_percentcomplete_clear = true THEN NULL ELSE COALESCE(p_percentcomplete, NULL) END,
                p_summary,
                CASE WHEN p_blockers_clear = true THEN NULL ELSE COALESCE(p_blockers, NULL) END,
                CASE WHEN p_nextsteps_clear = true THEN NULL ELSE COALESCE(p_nextsteps, NULL) END
        )
    ;

    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwTaskCheckIns"
    WHERE "ID" = v_new_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTaskCheckIn" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTaskCheckIn" TO "cdp_Integration";


-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Check Ins
-- Item: spUpdateTaskCheckIn
-- ============================================================

------------------------------------------------------------
----- UPDATE FUNCTION FOR TaskCheckIn
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spUpdateTaskCheckIn'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spUpdateTaskCheckIn"(
    p_id UUID,
    p_taskid UUID DEFAULT NULL,
    p_authorpersonid_clear boolean DEFAULT false,
    p_authorpersonid UUID DEFAULT NULL,
    p_authoruserid_clear boolean DEFAULT false,
    p_authoruserid UUID DEFAULT NULL,
    p_reportedbyaiagentid_clear boolean DEFAULT false,
    p_reportedbyaiagentid UUID DEFAULT NULL,
    p_checkinat TIMESTAMPTZ DEFAULT NULL,
    p_healthstatus varchar(20) DEFAULT NULL,
    p_confidencescore_clear boolean DEFAULT false,
    p_confidencescore int DEFAULT NULL,
    p_previousvalue_clear boolean DEFAULT false,
    p_previousvalue decimal(18, 4) DEFAULT NULL,
    p_newvalue_clear boolean DEFAULT false,
    p_newvalue decimal(18, 4) DEFAULT NULL,
    p_percentcomplete_clear boolean DEFAULT false,
    p_percentcomplete int DEFAULT NULL,
    p_summary TEXT DEFAULT NULL,
    p_blockers_clear boolean DEFAULT false,
    p_blockers TEXT DEFAULT NULL,
    p_nextsteps_clear boolean DEFAULT false,
    p_nextsteps TEXT DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwTaskCheckIns" AS $$
DECLARE
    v_updated_count INTEGER;
BEGIN
    UPDATE "__mj_bizappstasks"."TaskCheckIn"
    SET
        "TaskID" = COALESCE(p_taskid, "TaskID"),
        "AuthorPersonID" = CASE WHEN p_authorpersonid_clear = true THEN NULL ELSE COALESCE(p_authorpersonid, "AuthorPersonID") END,
        "AuthorUserID" = CASE WHEN p_authoruserid_clear = true THEN NULL ELSE COALESCE(p_authoruserid, "AuthorUserID") END,
        "ReportedByAIAgentID" = CASE WHEN p_reportedbyaiagentid_clear = true THEN NULL ELSE COALESCE(p_reportedbyaiagentid, "ReportedByAIAgentID") END,
        "CheckInAt" = COALESCE(p_checkinat, "CheckInAt"),
        "HealthStatus" = COALESCE(p_healthstatus, "HealthStatus"),
        "ConfidenceScore" = CASE WHEN p_confidencescore_clear = true THEN NULL ELSE COALESCE(p_confidencescore, "ConfidenceScore") END,
        "PreviousValue" = CASE WHEN p_previousvalue_clear = true THEN NULL ELSE COALESCE(p_previousvalue, "PreviousValue") END,
        "NewValue" = CASE WHEN p_newvalue_clear = true THEN NULL ELSE COALESCE(p_newvalue, "NewValue") END,
        "PercentComplete" = CASE WHEN p_percentcomplete_clear = true THEN NULL ELSE COALESCE(p_percentcomplete, "PercentComplete") END,
        "Summary" = COALESCE(p_summary, "Summary"),
        "Blockers" = CASE WHEN p_blockers_clear = true THEN NULL ELSE COALESCE(p_blockers, "Blockers") END,
        "NextSteps" = CASE WHEN p_nextsteps_clear = true THEN NULL ELSE COALESCE(p_nextsteps, "NextSteps") END
    WHERE
        "ID" = p_id;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    IF v_updated_count = 0 THEN
        -- Nothing was updated, return empty result set
        RETURN;
    END IF;

    -- Return the updated record from the base view
    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwTaskCheckIns"
    WHERE "ID" = p_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateTaskCheckIn" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateTaskCheckIn" TO "cdp_Integration";


------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskCheckIn table
------------------------------------------------------------
CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."fn_trg_update_task_check_in"()
RETURNS TRIGGER AS $$
BEGIN
    NEW."__mj_UpdatedAt" := NOW() AT TIME ZONE 'UTC';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS "trg_update_task_check_in" ON "__mj_bizappstasks"."TaskCheckIn";

CREATE TRIGGER "trg_update_task_check_in"
BEFORE UPDATE ON "__mj_bizappstasks"."TaskCheckIn"
FOR EACH ROW
EXECUTE FUNCTION "__mj_bizappstasks"."fn_trg_update_task_check_in"();



-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Check Ins
-- Item: spDeleteTaskCheckIn
-- ============================================================

------------------------------------------------------------
----- DELETE FUNCTION FOR TaskCheckIn
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spDeleteTaskCheckIn'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spDeleteTaskCheckIn"(
    p_id UUID
) RETURNS TABLE("ID" UUID) AS $$
#variable_conflict use_column
DECLARE
    v_affected_count INTEGER;
BEGIN

    DELETE FROM "__mj_bizappstasks"."TaskCheckIn"
    WHERE "ID" = p_id;

    GET DIAGNOSTICS v_affected_count = ROW_COUNT;

    IF v_affected_count = 0 THEN
        RETURN QUERY SELECT NULL::UUID AS "ID";
    ELSE
        RETURN QUERY SELECT p_id AS "ID";
    END IF;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteTaskCheckIn" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteTaskCheckIn" TO "cdp_Integration";

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
    EXECUTE 'GRANT SELECT ON "__mj_bizappstasks"."vwTasks" TO "cdp_Developer";
GRANT SELECT ON "__mj_bizappstasks"."vwTasks" TO "cdp_Integration";
GRANT SELECT ON "__mj_bizappstasks"."vwTasks" TO "cdp_UI";';
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


-- CodeGen also emitted a "Permissions for vwTasks" block here that wraps the grant in a second
-- DO $if_view_exists$ inside the first; the shared dollar-quote tag makes it unparseable. The grant
-- is applied in section 3, so the block is left out.


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
    p_predictedslascoredat TIMESTAMPTZ DEFAULT NULL,
    p_healthstatus_clear boolean DEFAULT false,
    p_healthstatus varchar(20) DEFAULT NULL,
    p_confidencescore_clear boolean DEFAULT false,
    p_confidencescore int DEFAULT NULL,
    p_baselinevalue_clear boolean DEFAULT false,
    p_baselinevalue decimal(18, 4) DEFAULT NULL,
    p_targetvalue_clear boolean DEFAULT false,
    p_targetvalue decimal(18, 4) DEFAULT NULL,
    p_currentvalue_clear boolean DEFAULT false,
    p_currentvalue decimal(18, 4) DEFAULT NULL,
    p_unitofmeasure_clear boolean DEFAULT false,
    p_unitofmeasure varchar(50) DEFAULT NULL,
    p_metricdirection_clear boolean DEFAULT false,
    p_metricdirection varchar(20) DEFAULT NULL,
    p_rollupweight decimal(8, 2) DEFAULT NULL,
    p_planningperiod_clear boolean DEFAULT false,
    p_planningperiod varchar(50) DEFAULT NULL,
    p_checkincadence_clear boolean DEFAULT false,
    p_checkincadence varchar(20) DEFAULT NULL,
    p_lastcheckinat_clear boolean DEFAULT false,
    p_lastcheckinat TIMESTAMPTZ DEFAULT NULL,
    p_nextcheckindueat_clear boolean DEFAULT false,
    p_nextcheckindueat TIMESTAMPTZ DEFAULT NULL
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
                "NextCheckInDueAt"
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
                CASE WHEN p_predictedslascoredat_clear = true THEN NULL ELSE COALESCE(p_predictedslascoredat, NULL) END,
                CASE WHEN p_healthstatus_clear = true THEN NULL ELSE COALESCE(p_healthstatus, NULL) END,
                CASE WHEN p_confidencescore_clear = true THEN NULL ELSE COALESCE(p_confidencescore, NULL) END,
                CASE WHEN p_baselinevalue_clear = true THEN NULL ELSE COALESCE(p_baselinevalue, NULL) END,
                CASE WHEN p_targetvalue_clear = true THEN NULL ELSE COALESCE(p_targetvalue, NULL) END,
                CASE WHEN p_currentvalue_clear = true THEN NULL ELSE COALESCE(p_currentvalue, NULL) END,
                CASE WHEN p_unitofmeasure_clear = true THEN NULL ELSE COALESCE(p_unitofmeasure, NULL) END,
                CASE WHEN p_metricdirection_clear = true THEN NULL ELSE COALESCE(p_metricdirection, NULL) END,
                COALESCE(p_rollupweight, 1.00),
                CASE WHEN p_planningperiod_clear = true THEN NULL ELSE COALESCE(p_planningperiod, NULL) END,
                CASE WHEN p_checkincadence_clear = true THEN NULL ELSE COALESCE(p_checkincadence, NULL) END,
                CASE WHEN p_lastcheckinat_clear = true THEN NULL ELSE COALESCE(p_lastcheckinat, NULL) END,
                CASE WHEN p_nextcheckindueat_clear = true THEN NULL ELSE COALESCE(p_nextcheckindueat, NULL) END
        )
    ;

    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwTasks"
    WHERE "ID" = v_new_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTask" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTask" TO "cdp_Integration";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTask" TO "cdp_UI";


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
    p_predictedslascoredat TIMESTAMPTZ DEFAULT NULL,
    p_healthstatus_clear boolean DEFAULT false,
    p_healthstatus varchar(20) DEFAULT NULL,
    p_confidencescore_clear boolean DEFAULT false,
    p_confidencescore int DEFAULT NULL,
    p_baselinevalue_clear boolean DEFAULT false,
    p_baselinevalue decimal(18, 4) DEFAULT NULL,
    p_targetvalue_clear boolean DEFAULT false,
    p_targetvalue decimal(18, 4) DEFAULT NULL,
    p_currentvalue_clear boolean DEFAULT false,
    p_currentvalue decimal(18, 4) DEFAULT NULL,
    p_unitofmeasure_clear boolean DEFAULT false,
    p_unitofmeasure varchar(50) DEFAULT NULL,
    p_metricdirection_clear boolean DEFAULT false,
    p_metricdirection varchar(20) DEFAULT NULL,
    p_rollupweight decimal(8, 2) DEFAULT NULL,
    p_planningperiod_clear boolean DEFAULT false,
    p_planningperiod varchar(50) DEFAULT NULL,
    p_checkincadence_clear boolean DEFAULT false,
    p_checkincadence varchar(20) DEFAULT NULL,
    p_lastcheckinat_clear boolean DEFAULT false,
    p_lastcheckinat TIMESTAMPTZ DEFAULT NULL,
    p_nextcheckindueat_clear boolean DEFAULT false,
    p_nextcheckindueat TIMESTAMPTZ DEFAULT NULL
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
        "PredictedSLAScoredAt" = CASE WHEN p_predictedslascoredat_clear = true THEN NULL ELSE COALESCE(p_predictedslascoredat, "PredictedSLAScoredAt") END,
        "HealthStatus" = CASE WHEN p_healthstatus_clear = true THEN NULL ELSE COALESCE(p_healthstatus, "HealthStatus") END,
        "ConfidenceScore" = CASE WHEN p_confidencescore_clear = true THEN NULL ELSE COALESCE(p_confidencescore, "ConfidenceScore") END,
        "BaselineValue" = CASE WHEN p_baselinevalue_clear = true THEN NULL ELSE COALESCE(p_baselinevalue, "BaselineValue") END,
        "TargetValue" = CASE WHEN p_targetvalue_clear = true THEN NULL ELSE COALESCE(p_targetvalue, "TargetValue") END,
        "CurrentValue" = CASE WHEN p_currentvalue_clear = true THEN NULL ELSE COALESCE(p_currentvalue, "CurrentValue") END,
        "UnitOfMeasure" = CASE WHEN p_unitofmeasure_clear = true THEN NULL ELSE COALESCE(p_unitofmeasure, "UnitOfMeasure") END,
        "MetricDirection" = CASE WHEN p_metricdirection_clear = true THEN NULL ELSE COALESCE(p_metricdirection, "MetricDirection") END,
        "RollupWeight" = COALESCE(p_rollupweight, "RollupWeight"),
        "PlanningPeriod" = CASE WHEN p_planningperiod_clear = true THEN NULL ELSE COALESCE(p_planningperiod, "PlanningPeriod") END,
        "CheckInCadence" = CASE WHEN p_checkincadence_clear = true THEN NULL ELSE COALESCE(p_checkincadence, "CheckInCadence") END,
        "LastCheckInAt" = CASE WHEN p_lastcheckinat_clear = true THEN NULL ELSE COALESCE(p_lastcheckinat, "LastCheckInAt") END,
        "NextCheckInDueAt" = CASE WHEN p_nextcheckindueat_clear = true THEN NULL ELSE COALESCE(p_nextcheckindueat, "NextCheckInDueAt") END
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
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateTask" TO "cdp_UI";


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
-- Field settings, categories, icons, entity settings and validators that CodeGen wrote after the
-- objects in the T-SQL migration, in the same order.

-- Related-entity name field maps, which the T-SQL sets through the same core procedure.
SELECT 1 FROM ${mjSchema}."spUpdateEntityFieldRelatedEntityNameFieldMap"(p_entityfieldid := '228C3AD3-A70A-44AB-8D35-49ACD8450741', p_relatedentitynamefieldmap := 'Task');
SELECT 1 FROM ${mjSchema}."spUpdateEntityFieldRelatedEntityNameFieldMap"(p_entityfieldid := 'C7DB972B-3CB3-48AB-81EF-AC4F4D9801A1', p_relatedentitynamefieldmap := 'AuthorPerson');
SELECT 1 FROM ${mjSchema}."spUpdateEntityFieldRelatedEntityNameFieldMap"(p_entityfieldid := '8B69C4D1-C536-4063-B775-FBEE891CCA7A', p_relatedentitynamefieldmap := 'AuthorUser');
SELECT 1 FROM ${mjSchema}."spUpdateEntityFieldRelatedEntityNameFieldMap"(p_entityfieldid := '8D0D30AE-8449-4921-B155-3EB275E824D1', p_relatedentitynamefieldmap := 'ReportedByAIAgent');

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



UPDATE ${mjSchema}."ApplicationEntity"
         SET "DefaultForNewUser" = CAST(1 AS BOOLEAN), "__mj_UpdatedAt" = NOW()
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

/* Generated Validation Functions for MJ_BizApps_Tasks: Task Check Ins */
-- CHECK constraint for MJ_BizApps_Tasks: Task Check Ins: Field: ConfidenceScore was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function

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
