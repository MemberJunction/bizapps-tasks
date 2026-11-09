-- ============================================================================
-- PostgreSQL counterpart of migrations/V202608200800__v1.2.x_TaskType_Code_Statuses_Workflow_Hooks.sql
-- Sections 1-3 (TaskType Code and hooks, TaskTypeStatus, Task.TaskTypeStatusID) are written
-- by hand from the T-SQL. Metadata DML is converted from the T-SQL; the CodeGen sections are native PostgreSQL CodeGen (MJ 6.1.5), not translated T-SQL.
-- ============================================================================

SET search_path TO __mj_bizappstasks, public;
SET standard_conforming_strings = on;

---------------------------------------------------------------------------
-- 1. TaskType: add Code (unique machine identifier) and new event action hooks
---------------------------------------------------------------------------
ALTER TABLE __mj_bizappstasks."TaskType" ADD COLUMN "Code" VARCHAR(50) NULL;

-- Backfill existing seeded task types using stable IDs
UPDATE __mj_bizappstasks."TaskType" SET "Code" = 'GENERAL' WHERE "ID" = 'F7C1E8DE-8DAC-4BF8-943E-3D5A1210BE82' AND "Code" IS NULL;
UPDATE __mj_bizappstasks."TaskType" SET "Code" = 'ACTION_ITEM' WHERE "ID" = 'EA525DE3-B4A9-471C-AD13-1881E2055121' AND "Code" IS NULL;
UPDATE __mj_bizappstasks."TaskType" SET "Code" = 'FOLLOW_UP' WHERE "ID" = 'EE1A6B5A-A5AD-4A62-89DB-D16FFD2A415C' AND "Code" IS NULL;
UPDATE __mj_bizappstasks."TaskType" SET "Code" = 'DELIVERABLE' WHERE "ID" = '3F002EBA-0F6A-4433-BD98-83BC5982E916' AND "Code" IS NULL;
UPDATE __mj_bizappstasks."TaskType" SET "Code" = 'APPROVAL_REQUEST' WHERE "ID" = '5961EDE5-B996-4083-BE48-64634B4D8D1C' AND "Code" IS NULL;
-- Fallback for any custom/legacy rows
UPDATE __mj_bizappstasks."TaskType" SET "Code" = UPPER(REPLACE("Name", ' ', '_')) WHERE "Code" IS NULL;

ALTER TABLE __mj_bizappstasks."TaskType"
 ALTER COLUMN "Code" SET NOT NULL,
 ADD COLUMN "OnCreateActionID" UUID NULL,
 ADD COLUMN "OnStatusChangeActionID" UUID NULL,
 ADD CONSTRAINT UQ_TaskType_Code UNIQUE ("Code"),
 ADD CONSTRAINT FK_TaskType_OnCreateAction FOREIGN KEY ("OnCreateActionID") REFERENCES ${mjSchema}."Action"("ID"),
 ADD CONSTRAINT FK_TaskType_OnStatusChangeAction FOREIGN KEY ("OnStatusChangeActionID") REFERENCES ${mjSchema}."Action"("ID");

COMMENT ON COLUMN __mj_bizappstasks."TaskType"."Code" IS 'Stable unique machine code for programmatic lookups and cross-app metadata references.';
COMMENT ON COLUMN __mj_bizappstasks."TaskType"."OnCreateActionID" IS 'Action invoked when a task of this type is first created (e.g. kicks off a task graph workflow, initialization agent, or subtask template generator).';
COMMENT ON COLUMN __mj_bizappstasks."TaskType"."OnStatusChangeActionID" IS 'Action invoked whenever a task of this type changes status.';

---------------------------------------------------------------------------
-- 2. TaskTypeStatus: dynamic domain-specific lifecycle statuses per TaskType
---------------------------------------------------------------------------
CREATE TABLE __mj_bizappstasks."TaskTypeStatus" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TaskTypeID" UUID NOT NULL,
 "Name" VARCHAR(100) NOT NULL,
 "Code" VARCHAR(50) NOT NULL,
 "Description" TEXT,
 "MacroStatus" VARCHAR(20) NOT NULL DEFAULT 'Open',
 "Sequence" INTEGER NOT NULL DEFAULT 100,
 "IsDefault" BOOLEAN NOT NULL DEFAULT FALSE,
 "IsTerminal" BOOLEAN NOT NULL DEFAULT FALSE,
 "Color" VARCHAR(50),
 "IconClass" VARCHAR(100),
 "OnEnterActionID" UUID,
 "OnExitActionID" UUID,
 "IsActive" BOOLEAN NOT NULL DEFAULT TRUE,
 "__mj_CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 "__mj_UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 CONSTRAINT PK_TaskTypeStatus PRIMARY KEY ("ID"),
 CONSTRAINT FK_TaskTypeStatus_TaskType FOREIGN KEY ("TaskTypeID") REFERENCES __mj_bizappstasks."TaskType"("ID") ON DELETE CASCADE,
 CONSTRAINT UQ_TaskTypeStatus_TaskType_Code UNIQUE ("TaskTypeID", "Code"),
 CONSTRAINT UQ_TaskTypeStatus_TaskType_Name UNIQUE ("TaskTypeID", "Name"),
 CONSTRAINT CK_TaskTypeStatus_MacroStatus CHECK ("MacroStatus" IN ('Open', 'InProgress', 'Blocked', 'Completed', 'Cancelled')),
 CONSTRAINT FK_TaskTypeStatus_OnEnterAction FOREIGN KEY ("OnEnterActionID") REFERENCES ${mjSchema}."Action"("ID"),
 CONSTRAINT FK_TaskTypeStatus_OnExitAction FOREIGN KEY ("OnExitActionID") REFERENCES ${mjSchema}."Action"("ID")
);

COMMENT ON TABLE __mj_bizappstasks."TaskTypeStatus" IS 'Dynamic domain statuses and lifecycle stages configured per Task Type.';
COMMENT ON COLUMN __mj_bizappstasks."TaskTypeStatus"."TaskTypeID" IS 'The Task Type this status belongs to.';
COMMENT ON COLUMN __mj_bizappstasks."TaskTypeStatus"."Name" IS 'Display name of the status (e.g. Legal Review, Redlining, Pending Signature).';
COMMENT ON COLUMN __mj_bizappstasks."TaskTypeStatus"."Code" IS 'Stable machine code for this status within its Task Type (e.g. LEGAL_REVIEW, REDLINING).';
COMMENT ON COLUMN __mj_bizappstasks."TaskTypeStatus"."MacroStatus" IS 'The standard macro-lifecycle state this domain status maps to (Open, InProgress, Blocked, Completed, Cancelled). Ensures progress rollup and Gantt calculations remain consistent.';
COMMENT ON COLUMN __mj_bizappstasks."TaskTypeStatus"."Sequence" IS 'Ordering sequence for pickers, stage progression bars, and Kanban columns.';
COMMENT ON COLUMN __mj_bizappstasks."TaskTypeStatus"."IsDefault" IS 'Whether this is the initial default status when a task of this type is created.';
COMMENT ON COLUMN __mj_bizappstasks."TaskTypeStatus"."IsTerminal" IS 'Whether this status represents a closed terminal state for the task.';
COMMENT ON COLUMN __mj_bizappstasks."TaskTypeStatus"."OnEnterActionID" IS 'Action invoked when a task enters this specific status.';
COMMENT ON COLUMN __mj_bizappstasks."TaskTypeStatus"."OnExitActionID" IS 'Action invoked when a task leaves this specific status.';

---------------------------------------------------------------------------
-- 3. Task: link to dynamic TaskTypeStatus
---------------------------------------------------------------------------
ALTER TABLE __mj_bizappstasks."Task"
 ADD COLUMN "TaskTypeStatusID" UUID NULL,
 ADD CONSTRAINT FK_Task_TaskTypeStatus FOREIGN KEY ("TaskTypeStatusID") REFERENCES __mj_bizappstasks."TaskTypeStatus"("ID");

COMMENT ON COLUMN __mj_bizappstasks."Task"."TaskTypeStatusID" IS 'Optional reference to the dynamic TaskTypeStatus definition for tasks with type-specific lifecycles.';



















































/* ============================================================================= */
/* GENERATED BY MemberJunction CodeGen — DO NOT EDIT BY HAND */
/* ============================================================================= */
/* SQL generated to create new entity MJ_BizApps_Tasks: Task Type Status */
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
    '6c8516b0-d87c-4b57-87f8-474d7ff6cdd9',
    'MJ_BizApps_Tasks: Task Type Status',
    'Task Type Status',
    'Dynamic domain statuses and lifecycle stages configured per Task Type.',
    NULL,
    'TaskTypeStatus',
    'vwTaskTypeStatus',
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
/* SQL generated to add new entity MJ_BizApps_Tasks: Task Type Status to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
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
    '6c8516b0-d87c-4b57-87f8-474d7ff6cdd9',
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
/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Type Status for role UI */
INSERT INTO ${mjSchema}."EntityPermission" (
  "EntityID",
  "RoleID",
  "CanRead",
  "CanCreate",
  "CanUpdate",
  "CanDelete",
  "__mj_CreatedAt",
  "__mj_UpdatedAt"
)
VALUES
  (
    '6c8516b0-d87c-4b57-87f8-474d7ff6cdd9',
    'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E',
    TRUE,
    FALSE,
    FALSE,
    FALSE,
    NOW(),
    NOW()
  );
/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Type Status for role Developer */
INSERT INTO ${mjSchema}."EntityPermission" (
  "EntityID",
  "RoleID",
  "CanRead",
  "CanCreate",
  "CanUpdate",
  "CanDelete",
  "__mj_CreatedAt",
  "__mj_UpdatedAt"
)
VALUES
  (
    '6c8516b0-d87c-4b57-87f8-474d7ff6cdd9',
    'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E',
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    NOW(),
    NOW()
  );
/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Type Status for role Integration */
INSERT INTO ${mjSchema}."EntityPermission" (
  "EntityID",
  "RoleID",
  "CanRead",
  "CanCreate",
  "CanUpdate",
  "CanDelete",
  "__mj_CreatedAt",
  "__mj_UpdatedAt"
)
VALUES
  (
    '6c8516b0-d87c-4b57-87f8-474d7ff6cdd9',
    'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E',
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    NOW(),
    NOW()
  );
/* SQL text to update existing entities from schema */ /* SQL text to insert 20 new entity field(s) */;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '164adeb0-e6aa-4ca4-bdd2-09532549a425' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'ID')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('164adeb0-e6aa-4ca4-bdd2-09532549a425', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100001, 'ID', 'ID', NULL, 'uniqueidentifier', 16, 0, 0, FALSE, 'newsequentialid()', FALSE, FALSE, FALSE, FALSE, NULL, NULL, FALSE, TRUE, FALSE, FALSE, TRUE, TRUE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '79a984fe-76f4-4c83-b03f-360369c18898' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'TaskTypeID')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('79a984fe-76f4-4c83-b03f-360369c18898', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100002, 'TaskTypeID', 'Task Type ID', 'The Task Type this status belongs to.', 'uniqueidentifier', 16, 0, 0, FALSE, NULL, FALSE, TRUE, FALSE, FALSE, '1E30141A-826F-4278-BAA9-BBE14D29E606', 'ID', FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '824e1d6b-5a3a-4211-8a05-0da2e15499c2' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'Name')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('824e1d6b-5a3a-4211-8a05-0da2e15499c2', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100003, 'Name', 'Name', 'Display name of the status (e.g. Legal Review, Redlining, Pending Signature).', 'nvarchar', 200, 0, 0, FALSE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '6f02ddca-2018-4f9a-b39e-3f5068d9401d' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'Code')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('6f02ddca-2018-4f9a-b39e-3f5068d9401d', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100004, 'Code', 'Code', 'Stable machine code for this status within its Task Type (e.g. LEGAL_REVIEW, REDLINING).', 'nvarchar', 100, 0, 0, FALSE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '119b6137-4212-4e45-b83b-98d61ffc0c48' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'Description')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('119b6137-4212-4e45-b83b-98d61ffc0c48', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100005, 'Description', 'Description', NULL, 'nvarchar', -1, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '34b18848-c2ba-406a-858f-1a074788cc07' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'MacroStatus')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('34b18848-c2ba-406a-858f-1a074788cc07', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100006, 'MacroStatus', 'Macro Status', 'The standard macro-lifecycle state this domain status maps to (Open, InProgress, Blocked, Completed, Cancelled). Ensures progress rollup and Gantt calculations remain consistent.', 'nvarchar', 40, 0, 0, FALSE, 'Open', FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '9499a61f-7eb5-40c1-8f6b-9f30d92eeb28' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'Sequence')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('9499a61f-7eb5-40c1-8f6b-9f30d92eeb28', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100007, 'Sequence', 'Sequence', 'Ordering sequence for pickers, stage progression bars, and Kanban columns.', 'int', 4, 10, 0, FALSE, '(100)', FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '25da14ee-06db-48dd-8f63-647aa0df52c3' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'IsDefault')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('25da14ee-06db-48dd-8f63-647aa0df52c3', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100008, 'IsDefault', 'Is Default', 'Whether this is the initial default status when a task of this type is created.', 'bit', 1, 1, 0, FALSE, '(0)', FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'c4af1535-3578-4c8b-844a-f13bfdf1cc54' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'IsTerminal')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('c4af1535-3578-4c8b-844a-f13bfdf1cc54', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100009, 'IsTerminal', 'Is Terminal', 'Whether this status represents a closed terminal state for the task.', 'bit', 1, 1, 0, FALSE, '(0)', FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '6bc13897-9336-4f24-a670-46afbba71c19' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'Color')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('6bc13897-9336-4f24-a670-46afbba71c19', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100010, 'Color', 'Color', NULL, 'nvarchar', 100, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'b2c3c6f7-306e-430f-84c2-9e0ab464797a' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'IconClass')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('b2c3c6f7-306e-430f-84c2-9e0ab464797a', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100011, 'IconClass', 'Icon Class', NULL, 'nvarchar', 200, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '910020ac-5d20-486c-97ff-846504f38e63' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'OnEnterActionID')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('910020ac-5d20-486c-97ff-846504f38e63', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100012, 'OnEnterActionID', 'On Enter Action ID', 'Action invoked when a task enters this specific status.', 'uniqueidentifier', 16, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, '38248F34-2837-EF11-86D4-6045BDEE16E6', 'ID', FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '182bf4c0-6850-4641-83a9-c97b8abd16e8' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'OnExitActionID')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('182bf4c0-6850-4641-83a9-c97b8abd16e8', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100013, 'OnExitActionID', 'On Exit Action ID', 'Action invoked when a task leaves this specific status.', 'uniqueidentifier', 16, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, '38248F34-2837-EF11-86D4-6045BDEE16E6', 'ID', FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '94184deb-01e0-4824-9d66-65519a9b5585' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'IsActive')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('94184deb-01e0-4824-9d66-65519a9b5585', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100014, 'IsActive', 'Is Active', NULL, 'bit', 1, 1, 0, FALSE, '(1)', FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'ff5798a2-620d-4c3d-84a7-c146fc84a0dd' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = '__mj_CreatedAt')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('ff5798a2-620d-4c3d-84a7-c146fc84a0dd', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100015, '__mj_CreatedAt', 'Created At', NULL, 'datetimeoffset', 10, 34, 7, FALSE, 'getutcdate()', FALSE, FALSE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'c12fcae1-e043-4b77-be64-9a81485d6a31' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = '__mj_UpdatedAt')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('c12fcae1-e043-4b77-be64-9a81485d6a31', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100016, '__mj_UpdatedAt', 'Updated At', NULL, 'datetimeoffset', 10, 34, 7, FALSE, 'getutcdate()', FALSE, FALSE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'd010dcc4-5e0c-4fe2-bff4-c35328bf48b0' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'Code')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('d010dcc4-5e0c-4fe2-bff4-c35328bf48b0', '1E30141A-826F-4278-BAA9-BBE14D29E606' /* Entity: MJ_BizApps_Tasks: Task Types */, 100035, 'Code', 'Code', 'Stable unique machine code for programmatic lookups and cross-app metadata references.', 'nvarchar', 100, 0, 0, FALSE, NULL, FALSE, TRUE, FALSE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '555144f5-34ae-40a7-8c06-de892de859b7' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'OnCreateActionID')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('555144f5-34ae-40a7-8c06-de892de859b7', '1E30141A-826F-4278-BAA9-BBE14D29E606' /* Entity: MJ_BizApps_Tasks: Task Types */, 100036, 'OnCreateActionID', 'On Create Action ID', 'Action invoked when a task of this type is first created (e.g. kicks off a task graph workflow, initialization agent, or subtask template generator).', 'uniqueidentifier', 16, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, '38248F34-2837-EF11-86D4-6045BDEE16E6', 'ID', FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '31c5fb7d-2fd4-4d32-85ed-2e3771a083e0' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'OnStatusChangeActionID')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('31c5fb7d-2fd4-4d32-85ed-2e3771a083e0', '1E30141A-826F-4278-BAA9-BBE14D29E606' /* Entity: MJ_BizApps_Tasks: Task Types */, 100037, 'OnStatusChangeActionID', 'On Status Change Action ID', 'Action invoked whenever a task of this type changes status.', 'uniqueidentifier', 16, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, '38248F34-2837-EF11-86D4-6045BDEE16E6', 'ID', FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '70558cbd-0d69-41fb-a453-526878cd83d0' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'TaskTypeStatusID')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('70558cbd-0d69-41fb-a453-526878cd83d0', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, 100052, 'TaskTypeStatusID', 'Task Type Status ID', 'Optional reference to the dynamic TaskTypeStatus definition for tasks with type-specific lifecycles.', 'uniqueidentifier', 16, 0, 0, TRUE, NULL, FALSE, TRUE, FALSE, FALSE, '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', 'ID', FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

/* SQL text to update existing entity fields from schema */
/* SQL text to set default column width where needed */
/* SQL text to insert entity field value with ID 635846e8-e8f9-4be2-9e6b-ad783bae05cf */
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
    '635846e8-e8f9-4be2-9e6b-ad783bae05cf',
    '34B18848-C2BA-406A-858F-1A074788CC07',
    1,
    'Blocked',
    'Blocked',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID c95bf1fd-38aa-476a-86c4-cce1daa7ab65 */
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
    'c95bf1fd-38aa-476a-86c4-cce1daa7ab65',
    '34B18848-C2BA-406A-858F-1A074788CC07',
    2,
    'Cancelled',
    'Cancelled',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID b6c11250-d2db-4b0f-9594-bcd9271dbb8b */
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
    'b6c11250-d2db-4b0f-9594-bcd9271dbb8b',
    '34B18848-C2BA-406A-858F-1A074788CC07',
    3,
    'Completed',
    'Completed',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID 3a40307f-ef27-4079-8fb3-d9c0403a1199 */
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
    '3a40307f-ef27-4079-8fb3-d9c0403a1199',
    '34B18848-C2BA-406A-858F-1A074788CC07',
    4,
    'InProgress',
    'InProgress',
    NOW(),
    NOW()
  );
/* SQL text to insert entity field value with ID 9e75f106-9f72-4f58-9181-4a08e8bb577c */
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
    '9e75f106-9f72-4f58-9181-4a08e8bb577c',
    '34B18848-C2BA-406A-858F-1A074788CC07',
    5,
    'Open',
    'Open',
    NOW(),
    NOW()
  );
/* SQL text to update ValueListType for entity field ID 34B18848-C2BA-406A-858F-1A074788CC07 */
UPDATE ${mjSchema}."EntityField" SET "ValueListType" = 'List'
WHERE
  "ID" = '34B18848-C2BA-406A-858F-1A074788CC07';
/* Create Entity Relationship: MJ_BizApps_Tasks: Task Type Status -> MJ_BizApps_Tasks: Tasks (One To Many via TaskTypeStatusID) */;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '504d4e57-e414-41d8-b688-1284c93ec983') THEN
    INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('504d4e57-e414-41d8-b688-1284c93ec983', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'TaskTypeStatusID', 'One To Many', TRUE, TRUE, 1, NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '13b8d337-7e91-4e15-b230-bac55d14a8e7') THEN
    INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('13b8d337-7e91-4e15-b230-bac55d14a8e7', '38248F34-2837-EF11-86D4-6045BDEE16E6', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'OnStatusChangeActionID', 'One To Many', TRUE, TRUE, 26, NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '556a1e00-4e4e-4723-9b62-bcdf0c3014d4') THEN
    INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('556a1e00-4e4e-4723-9b62-bcdf0c3014d4', '38248F34-2837-EF11-86D4-6045BDEE16E6', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'OnCreateActionID', 'One To Many', TRUE, TRUE, 27, NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '8bb50b47-c4eb-47d7-b84a-3953ad2b201f') THEN
    INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('8bb50b47-c4eb-47d7-b84a-3953ad2b201f', '38248F34-2837-EF11-86D4-6045BDEE16E6', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', 'OnExitActionID', 'One To Many', TRUE, TRUE, 28, NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '156a3349-422d-4e84-b3b7-e21d04b18b98') THEN
    INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('156a3349-422d-4e84-b3b7-e21d04b18b98', '38248F34-2837-EF11-86D4-6045BDEE16E6', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', 'OnEnterActionID', 'One To Many', TRUE, TRUE, 29, NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '16f8a22c-c68a-4ade-b3c9-a4fb8bb8cb84') THEN
    INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('16f8a22c-c68a-4ade-b3c9-a4fb8bb8cb84', '1E30141A-826F-4278-BAA9-BBE14D29E606', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', 'TaskTypeID', 'One To Many', TRUE, TRUE, 5, NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'fad67d4d-89bf-4b5c-b593-556b56d1b68c' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'TaskType')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('fad67d4d-89bf-4b5c-b593-556b56d1b68c', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100033, 'TaskType', 'Task Type', NULL, 'nvarchar', 200, 0, 0, FALSE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'f299e44e-7c52-44ef-ad98-59d68fa154f5' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'OnEnterAction')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('f299e44e-7c52-44ef-ad98-59d68fa154f5', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100034, 'OnEnterAction', 'On Enter Action', NULL, 'nvarchar', 850, 0, 0, TRUE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '7d89b146-90e4-4681-89f9-d89ffd21fc57' OR ("EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' AND "Name" = 'OnExitAction')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('7d89b146-90e4-4681-89f9-d89ffd21fc57', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9' /* Entity: MJ_BizApps_Tasks: Task Type Status */, 100035, 'OnExitAction', 'On Exit Action', NULL, 'nvarchar', 850, 0, 0, TRUE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'd2a2d5fb-e3ba-4965-86ce-50a4856e1169' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'OnCreateAction')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('d2a2d5fb-e3ba-4965-86ce-50a4856e1169', '1E30141A-826F-4278-BAA9-BBE14D29E606' /* Entity: MJ_BizApps_Tasks: Task Types */, 100047, 'OnCreateAction', 'On Create Action', NULL, 'nvarchar', 850, 0, 0, TRUE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '091a787f-6a51-45ae-9ca4-e5fe0d2b2c7e' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'OnStatusChangeAction')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('091a787f-6a51-45ae-9ca4-e5fe0d2b2c7e', '1E30141A-826F-4278-BAA9-BBE14D29E606' /* Entity: MJ_BizApps_Tasks: Task Types */, 100048, 'OnStatusChangeAction', 'On Status Change Action', NULL, 'nvarchar', 850, 0, 0, TRUE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '0e437172-663e-481f-a1be-8f3f90c55383' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'TaskTypeStatus')) THEN
    INSERT INTO ${mjSchema}."EntityField" ("ID", "EntityID", "Sequence", "Name", "DisplayName", "Description", "Type", "Length", "Precision", "Scale", "AllowsNull", "DefaultValue", "AutoIncrement", "AllowUpdateAPI", "IsVirtual", "IsComputed", "RelatedEntityID", "RelatedEntityFieldName", "IsNameField", "IncludeInUserSearchAPI", "IncludeRelatedEntityNameFieldInBaseView", "DefaultInView", "IsPrimaryKey", "IsUnique", "RelatedEntityDisplayType", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES ('0e437172-663e-481f-a1be-8f3f90c55383', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' /* Entity: MJ_BizApps_Tasks: Tasks */, 100054, 'TaskTypeStatus', 'Task Type Status', NULL, 'nvarchar', 200, 0, 0, TRUE, NULL, FALSE, FALSE, TRUE, FALSE, NULL, NULL, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 'Search', NOW(), NOW());
  END IF;
END $$;

-- ===================== CodeGen (native PG, baked) =====================

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Categories
-- Item: Index for Foreign Keys
-- ============================================================
CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_category_parent_id"
    ON "__mj_bizappstasks"."TaskCategory" ("ParentID");

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Categories
-- Item: vwTaskCategories
-- ============================================================

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Categories
-----               SCHEMA:      __mj_bizappstasks
-----               BASE TABLE:  TaskCategory
-----               PRIMARY KEY: ID
------------------------------------------------------------
DO $vw_regen$
DECLARE
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_bizappstasks"."vwTaskCategories"
AS
SELECT
    t.*,
    mjBizAppsTasksTaskCategory_ParentID."Name" AS "Parent"
FROM
    "__mj_bizappstasks"."TaskCategory" AS t
LEFT OUTER JOIN
    "__mj_bizappstasks"."TaskCategory" AS mjBizAppsTasksTaskCategory_ParentID
  ON
    "t"."ParentID" = mjBizAppsTasksTaskCategory_ParentID."ID"
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
    AND tc.relname = 'vwTaskCategories'
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
    AND tc.relname = 'vwTaskCategories'
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
        AND tc.relname = 'vwTaskCategories'
        AND tc.relkind IN ('v', 'm')
  );

  DROP VIEW IF EXISTS "__mj_bizappstasks"."vwTaskCategories" CASCADE;
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
GRANT SELECT ON "__mj_bizappstasks"."vwTaskCategories" TO "cdp_UI";
GRANT SELECT ON "__mj_bizappstasks"."vwTaskCategories" TO "cdp_Developer";
GRANT SELECT ON "__mj_bizappstasks"."vwTaskCategories" TO "cdp_Integration";

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Categories
-- Item: spCreateTaskCategory
-- ============================================================

------------------------------------------------------------
----- CREATE FUNCTION FOR TaskCategory
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spCreateTaskCategory'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spCreateTaskCategory"(
    p_id UUID DEFAULT NULL,
    p_name varchar(255) DEFAULT NULL,
    p_description_clear boolean DEFAULT false,
    p_description TEXT DEFAULT NULL,
    p_parentid_clear boolean DEFAULT false,
    p_parentid UUID DEFAULT NULL,
    p_colorcode_clear boolean DEFAULT false,
    p_colorcode varchar(20) DEFAULT NULL,
    p_sequence int DEFAULT NULL,
    p_isactive BOOLEAN DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwTaskCategories" AS $$
DECLARE
    v_new_id UUID;
BEGIN
    v_new_id := COALESCE(p_id, gen_random_uuid());
    INSERT INTO "__mj_bizappstasks"."TaskCategory"
        (
            "ID",
            "Name",
                "Description",
                "ParentID",
                "ColorCode",
                "Sequence",
                "IsActive"
        )
    VALUES
        (
            v_new_id,
            p_name,
                CASE WHEN p_description_clear = true THEN NULL ELSE COALESCE(p_description, NULL) END,
                CASE WHEN p_parentid_clear = true THEN NULL ELSE COALESCE(p_parentid, NULL) END,
                CASE WHEN p_colorcode_clear = true THEN NULL ELSE COALESCE(p_colorcode, NULL) END,
                COALESCE(p_sequence, 100),
                COALESCE(p_isactive, TRUE)
        )
    ;

    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwTaskCategories"
    WHERE "ID" = v_new_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTaskCategory" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTaskCategory" TO "cdp_Integration";


-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Categories
-- Item: spUpdateTaskCategory
-- ============================================================

------------------------------------------------------------
----- UPDATE FUNCTION FOR TaskCategory
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spUpdateTaskCategory'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spUpdateTaskCategory"(
    p_id UUID,
    p_name varchar(255) DEFAULT NULL,
    p_description_clear boolean DEFAULT false,
    p_description TEXT DEFAULT NULL,
    p_parentid_clear boolean DEFAULT false,
    p_parentid UUID DEFAULT NULL,
    p_colorcode_clear boolean DEFAULT false,
    p_colorcode varchar(20) DEFAULT NULL,
    p_sequence int DEFAULT NULL,
    p_isactive BOOLEAN DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwTaskCategories" AS $$
DECLARE
    v_updated_count INTEGER;
BEGIN
    UPDATE "__mj_bizappstasks"."TaskCategory"
    SET
        "Name" = COALESCE(p_name, "Name"),
        "Description" = CASE WHEN p_description_clear = true THEN NULL ELSE COALESCE(p_description, "Description") END,
        "ParentID" = CASE WHEN p_parentid_clear = true THEN NULL ELSE COALESCE(p_parentid, "ParentID") END,
        "ColorCode" = CASE WHEN p_colorcode_clear = true THEN NULL ELSE COALESCE(p_colorcode, "ColorCode") END,
        "Sequence" = COALESCE(p_sequence, "Sequence"),
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
    SELECT * FROM "__mj_bizappstasks"."vwTaskCategories"
    WHERE "ID" = p_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateTaskCategory" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateTaskCategory" TO "cdp_Integration";


------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskCategory table
------------------------------------------------------------
CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."fn_trg_update_task_category"()
RETURNS TRIGGER AS $$
BEGIN
    NEW."__mj_UpdatedAt" := NOW() AT TIME ZONE 'UTC';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS "trg_update_task_category" ON "__mj_bizappstasks"."TaskCategory";

CREATE TRIGGER "trg_update_task_category"
BEFORE UPDATE ON "__mj_bizappstasks"."TaskCategory"
FOR EACH ROW
EXECUTE FUNCTION "__mj_bizappstasks"."fn_trg_update_task_category"();



-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Categories
-- Item: spDeleteTaskCategory
-- ============================================================

------------------------------------------------------------
----- DELETE FUNCTION FOR TaskCategory
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spDeleteTaskCategory'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spDeleteTaskCategory"(
    p_id UUID
) RETURNS TABLE("ID" UUID) AS $$
#variable_conflict use_column
DECLARE
    v_affected_count INTEGER;
BEGIN

    DELETE FROM "__mj_bizappstasks"."TaskCategory"
    WHERE "ID" = p_id;

    GET DIAGNOSTICS v_affected_count = ROW_COUNT;

    IF v_affected_count = 0 THEN
        RETURN QUERY SELECT NULL::UUID AS "ID";
    ELSE
        RETURN QUERY SELECT p_id AS "ID";
    END IF;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteTaskCategory" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteTaskCategory" TO "cdp_Integration";

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Comments
-- Item: Index for Foreign Keys
-- ============================================================
CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_comment_task_id"
    ON "__mj_bizappstasks"."TaskComment" ("TaskID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_comment_parent_id"
    ON "__mj_bizappstasks"."TaskComment" ("ParentID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_comment_person_id"
    ON "__mj_bizappstasks"."TaskComment" ("PersonID");

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Comments
-- Item: vwTaskComments
-- ============================================================

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Comments
-----               SCHEMA:      __mj_bizappstasks
-----               BASE TABLE:  TaskComment
-----               PRIMARY KEY: ID
------------------------------------------------------------
DO $vw_regen$
DECLARE
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_bizappstasks"."vwTaskComments"
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID."Name" AS "Task",
    mjBizAppsCommonPerson_PersonID."DisplayName" AS "Person"
FROM
    "__mj_bizappstasks"."TaskComment" AS t
INNER JOIN
    "__mj_bizappstasks"."Task" AS mjBizAppsTasksTask_TaskID
  ON
    "t"."TaskID" = mjBizAppsTasksTask_TaskID."ID"
INNER JOIN
    "__mj_bizappscommon"."Person" AS mjBizAppsCommonPerson_PersonID
  ON
    "t"."PersonID" = mjBizAppsCommonPerson_PersonID."ID"
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
    AND tc.relname = 'vwTaskComments'
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
    AND tc.relname = 'vwTaskComments'
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
        AND tc.relname = 'vwTaskComments'
        AND tc.relkind IN ('v', 'm')
  );

  DROP VIEW IF EXISTS "__mj_bizappstasks"."vwTaskComments" CASCADE;
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
GRANT SELECT ON "__mj_bizappstasks"."vwTaskComments" TO "cdp_UI";
GRANT SELECT ON "__mj_bizappstasks"."vwTaskComments" TO "cdp_Developer";
GRANT SELECT ON "__mj_bizappstasks"."vwTaskComments" TO "cdp_Integration";

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Comments
-- Item: spCreateTaskComment
-- ============================================================

------------------------------------------------------------
----- CREATE FUNCTION FOR TaskComment
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spCreateTaskComment'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spCreateTaskComment"(
    p_id UUID DEFAULT NULL,
    p_taskid UUID DEFAULT NULL,
    p_parentid_clear boolean DEFAULT false,
    p_parentid UUID DEFAULT NULL,
    p_personid UUID DEFAULT NULL,
    p_content TEXT DEFAULT NULL,
    p_isedited BOOLEAN DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwTaskComments" AS $$
DECLARE
    v_new_id UUID;
BEGIN
    v_new_id := COALESCE(p_id, gen_random_uuid());
    INSERT INTO "__mj_bizappstasks"."TaskComment"
        (
            "ID",
            "TaskID",
                "ParentID",
                "PersonID",
                "Content",
                "IsEdited"
        )
    VALUES
        (
            v_new_id,
            p_taskid,
                CASE WHEN p_parentid_clear = true THEN NULL ELSE COALESCE(p_parentid, NULL) END,
                p_personid,
                p_content,
                COALESCE(p_isedited, FALSE)
        )
    ;

    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwTaskComments"
    WHERE "ID" = v_new_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTaskComment" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTaskComment" TO "cdp_Integration";


-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Comments
-- Item: spUpdateTaskComment
-- ============================================================

------------------------------------------------------------
----- UPDATE FUNCTION FOR TaskComment
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spUpdateTaskComment'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spUpdateTaskComment"(
    p_id UUID,
    p_taskid UUID DEFAULT NULL,
    p_parentid_clear boolean DEFAULT false,
    p_parentid UUID DEFAULT NULL,
    p_personid UUID DEFAULT NULL,
    p_content TEXT DEFAULT NULL,
    p_isedited BOOLEAN DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwTaskComments" AS $$
DECLARE
    v_updated_count INTEGER;
BEGIN
    UPDATE "__mj_bizappstasks"."TaskComment"
    SET
        "TaskID" = COALESCE(p_taskid, "TaskID"),
        "ParentID" = CASE WHEN p_parentid_clear = true THEN NULL ELSE COALESCE(p_parentid, "ParentID") END,
        "PersonID" = COALESCE(p_personid, "PersonID"),
        "Content" = COALESCE(p_content, "Content"),
        "IsEdited" = COALESCE(p_isedited, "IsEdited")
    WHERE
        "ID" = p_id;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    IF v_updated_count = 0 THEN
        -- Nothing was updated, return empty result set
        RETURN;
    END IF;

    -- Return the updated record from the base view
    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwTaskComments"
    WHERE "ID" = p_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateTaskComment" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateTaskComment" TO "cdp_Integration";


------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskComment table
------------------------------------------------------------
CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."fn_trg_update_task_comment"()
RETURNS TRIGGER AS $$
BEGIN
    NEW."__mj_UpdatedAt" := NOW() AT TIME ZONE 'UTC';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS "trg_update_task_comment" ON "__mj_bizappstasks"."TaskComment";

CREATE TRIGGER "trg_update_task_comment"
BEFORE UPDATE ON "__mj_bizappstasks"."TaskComment"
FOR EACH ROW
EXECUTE FUNCTION "__mj_bizappstasks"."fn_trg_update_task_comment"();



-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Comments
-- Item: spDeleteTaskComment
-- ============================================================

------------------------------------------------------------
----- DELETE FUNCTION FOR TaskComment
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spDeleteTaskComment'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spDeleteTaskComment"(
    p_id UUID
) RETURNS TABLE("ID" UUID) AS $$
#variable_conflict use_column
DECLARE
    v_affected_count INTEGER;
BEGIN

    DELETE FROM "__mj_bizappstasks"."TaskComment"
    WHERE "ID" = p_id;

    GET DIAGNOSTICS v_affected_count = ROW_COUNT;

    IF v_affected_count = 0 THEN
        RETURN QUERY SELECT NULL::UUID AS "ID";
    ELSE
        RETURN QUERY SELECT p_id AS "ID";
    END IF;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteTaskComment" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteTaskComment" TO "cdp_Integration";

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Type Status
-- Item: Index for Foreign Keys
-- ============================================================
CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_type_status_task_type_id"
    ON "__mj_bizappstasks"."TaskTypeStatus" ("TaskTypeID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_type_status_on_enter_action_id"
    ON "__mj_bizappstasks"."TaskTypeStatus" ("OnEnterActionID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_type_status_on_exit_action_id"
    ON "__mj_bizappstasks"."TaskTypeStatus" ("OnExitActionID");

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Type Status
-- Item: vwTaskTypeStatus
-- ============================================================

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Type Status
-----               SCHEMA:      __mj_bizappstasks
-----               BASE TABLE:  TaskTypeStatus
-----               PRIMARY KEY: ID
------------------------------------------------------------
DO $vw_regen$
DECLARE
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_bizappstasks"."vwTaskTypeStatus"
AS
SELECT
    t.*,
    mjBizAppsTasksTaskType_TaskTypeID."Name" AS "TaskType",
    MJAction_OnEnterActionID."Name" AS "OnEnterAction",
    MJAction_OnExitActionID."Name" AS "OnExitAction"
FROM
    "__mj_bizappstasks"."TaskTypeStatus" AS t
INNER JOIN
    "__mj_bizappstasks"."TaskType" AS mjBizAppsTasksTaskType_TaskTypeID
  ON
    "t"."TaskTypeID" = mjBizAppsTasksTaskType_TaskTypeID."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS MJAction_OnEnterActionID
  ON
    "t"."OnEnterActionID" = MJAction_OnEnterActionID."ID"
LEFT OUTER JOIN
    ${mjSchema}."Action" AS MJAction_OnExitActionID
  ON
    "t"."OnExitActionID" = MJAction_OnExitActionID."ID"
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
    AND tc.relname = 'vwTaskTypeStatus'
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
    AND tc.relname = 'vwTaskTypeStatus'
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
        AND tc.relname = 'vwTaskTypeStatus'
        AND tc.relkind IN ('v', 'm')
  );

  DROP VIEW IF EXISTS "__mj_bizappstasks"."vwTaskTypeStatus" CASCADE;
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
GRANT SELECT ON "__mj_bizappstasks"."vwTaskTypeStatus" TO "cdp_UI";
GRANT SELECT ON "__mj_bizappstasks"."vwTaskTypeStatus" TO "cdp_Developer";
GRANT SELECT ON "__mj_bizappstasks"."vwTaskTypeStatus" TO "cdp_Integration";

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Type Status
-- Item: spCreateTaskTypeStatus
-- ============================================================

------------------------------------------------------------
----- CREATE FUNCTION FOR TaskTypeStatus
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spCreateTaskTypeStatus'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spCreateTaskTypeStatus"(
    p_id UUID DEFAULT NULL,
    p_tasktypeid UUID DEFAULT NULL,
    p_name varchar(100) DEFAULT NULL,
    p_code varchar(50) DEFAULT NULL,
    p_description_clear boolean DEFAULT false,
    p_description TEXT DEFAULT NULL,
    p_macrostatus varchar(20) DEFAULT NULL,
    p_sequence int DEFAULT NULL,
    p_isdefault BOOLEAN DEFAULT NULL,
    p_isterminal BOOLEAN DEFAULT NULL,
    p_color_clear boolean DEFAULT false,
    p_color varchar(50) DEFAULT NULL,
    p_iconclass_clear boolean DEFAULT false,
    p_iconclass varchar(100) DEFAULT NULL,
    p_onenteractionid_clear boolean DEFAULT false,
    p_onenteractionid UUID DEFAULT NULL,
    p_onexitactionid_clear boolean DEFAULT false,
    p_onexitactionid UUID DEFAULT NULL,
    p_isactive BOOLEAN DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwTaskTypeStatus" AS $$
DECLARE
    v_new_id UUID;
BEGIN
    v_new_id := COALESCE(p_id, gen_random_uuid());
    INSERT INTO "__mj_bizappstasks"."TaskTypeStatus"
        (
            "ID",
            "TaskTypeID",
                "Name",
                "Code",
                "Description",
                "MacroStatus",
                "Sequence",
                "IsDefault",
                "IsTerminal",
                "Color",
                "IconClass",
                "OnEnterActionID",
                "OnExitActionID",
                "IsActive"
        )
    VALUES
        (
            v_new_id,
            p_tasktypeid,
                p_name,
                p_code,
                CASE WHEN p_description_clear = true THEN NULL ELSE COALESCE(p_description, NULL) END,
                COALESCE(p_macrostatus, 'Open'),
                COALESCE(p_sequence, 100),
                COALESCE(p_isdefault, FALSE),
                COALESCE(p_isterminal, FALSE),
                CASE WHEN p_color_clear = true THEN NULL ELSE COALESCE(p_color, NULL) END,
                CASE WHEN p_iconclass_clear = true THEN NULL ELSE COALESCE(p_iconclass, NULL) END,
                CASE WHEN p_onenteractionid_clear = true THEN NULL ELSE COALESCE(p_onenteractionid, NULL) END,
                CASE WHEN p_onexitactionid_clear = true THEN NULL ELSE COALESCE(p_onexitactionid, NULL) END,
                COALESCE(p_isactive, TRUE)
        )
    ;

    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwTaskTypeStatus"
    WHERE "ID" = v_new_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTaskTypeStatus" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTaskTypeStatus" TO "cdp_Integration";


-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Type Status
-- Item: spUpdateTaskTypeStatus
-- ============================================================

------------------------------------------------------------
----- UPDATE FUNCTION FOR TaskTypeStatus
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spUpdateTaskTypeStatus'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spUpdateTaskTypeStatus"(
    p_id UUID,
    p_tasktypeid UUID DEFAULT NULL,
    p_name varchar(100) DEFAULT NULL,
    p_code varchar(50) DEFAULT NULL,
    p_description_clear boolean DEFAULT false,
    p_description TEXT DEFAULT NULL,
    p_macrostatus varchar(20) DEFAULT NULL,
    p_sequence int DEFAULT NULL,
    p_isdefault BOOLEAN DEFAULT NULL,
    p_isterminal BOOLEAN DEFAULT NULL,
    p_color_clear boolean DEFAULT false,
    p_color varchar(50) DEFAULT NULL,
    p_iconclass_clear boolean DEFAULT false,
    p_iconclass varchar(100) DEFAULT NULL,
    p_onenteractionid_clear boolean DEFAULT false,
    p_onenteractionid UUID DEFAULT NULL,
    p_onexitactionid_clear boolean DEFAULT false,
    p_onexitactionid UUID DEFAULT NULL,
    p_isactive BOOLEAN DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwTaskTypeStatus" AS $$
DECLARE
    v_updated_count INTEGER;
BEGIN
    UPDATE "__mj_bizappstasks"."TaskTypeStatus"
    SET
        "TaskTypeID" = COALESCE(p_tasktypeid, "TaskTypeID"),
        "Name" = COALESCE(p_name, "Name"),
        "Code" = COALESCE(p_code, "Code"),
        "Description" = CASE WHEN p_description_clear = true THEN NULL ELSE COALESCE(p_description, "Description") END,
        "MacroStatus" = COALESCE(p_macrostatus, "MacroStatus"),
        "Sequence" = COALESCE(p_sequence, "Sequence"),
        "IsDefault" = COALESCE(p_isdefault, "IsDefault"),
        "IsTerminal" = COALESCE(p_isterminal, "IsTerminal"),
        "Color" = CASE WHEN p_color_clear = true THEN NULL ELSE COALESCE(p_color, "Color") END,
        "IconClass" = CASE WHEN p_iconclass_clear = true THEN NULL ELSE COALESCE(p_iconclass, "IconClass") END,
        "OnEnterActionID" = CASE WHEN p_onenteractionid_clear = true THEN NULL ELSE COALESCE(p_onenteractionid, "OnEnterActionID") END,
        "OnExitActionID" = CASE WHEN p_onexitactionid_clear = true THEN NULL ELSE COALESCE(p_onexitactionid, "OnExitActionID") END,
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
    SELECT * FROM "__mj_bizappstasks"."vwTaskTypeStatus"
    WHERE "ID" = p_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateTaskTypeStatus" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateTaskTypeStatus" TO "cdp_Integration";


------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTypeStatus table
------------------------------------------------------------
CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."fn_trg_update_task_type_status"()
RETURNS TRIGGER AS $$
BEGIN
    NEW."__mj_UpdatedAt" := NOW() AT TIME ZONE 'UTC';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS "trg_update_task_type_status" ON "__mj_bizappstasks"."TaskTypeStatus";

CREATE TRIGGER "trg_update_task_type_status"
BEFORE UPDATE ON "__mj_bizappstasks"."TaskTypeStatus"
FOR EACH ROW
EXECUTE FUNCTION "__mj_bizappstasks"."fn_trg_update_task_type_status"();



-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Type Status
-- Item: spDeleteTaskTypeStatus
-- ============================================================

------------------------------------------------------------
----- DELETE FUNCTION FOR TaskTypeStatus
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spDeleteTaskTypeStatus'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spDeleteTaskTypeStatus"(
    p_id UUID
) RETURNS TABLE("ID" UUID) AS $$
#variable_conflict use_column
DECLARE
    v_affected_count INTEGER;
BEGIN

    DELETE FROM "__mj_bizappstasks"."TaskTypeStatus"
    WHERE "ID" = p_id;

    GET DIAGNOSTICS v_affected_count = ROW_COUNT;

    IF v_affected_count = 0 THEN
        RETURN QUERY SELECT NULL::UUID AS "ID";
    ELSE
        RETURN QUERY SELECT p_id AS "ID";
    END IF;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteTaskTypeStatus" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteTaskTypeStatus" TO "cdp_Integration";

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
    p_onstatuschangeactionid UUID DEFAULT NULL
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
                "OnStatusChangeActionID"
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
                CASE WHEN p_onstatuschangeactionid_clear = true THEN NULL ELSE COALESCE(p_onstatuschangeactionid, NULL) END
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
    p_onstatuschangeactionid UUID DEFAULT NULL
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
        "OnStatusChangeActionID" = CASE WHEN p_onstatuschangeactionid_clear = true THEN NULL ELSE COALESCE(p_onstatuschangeactionid, "OnStatusChangeActionID") END
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
-- Item: vwTasks
-- ============================================================

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Tasks
-----               SCHEMA:      __mj_bizappstasks
-----               BASE TABLE:  Task
-----               PRIMARY KEY: ID
------------------------------------------------------------
DO $vw_regen$
DECLARE
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_bizappstasks"."vwTasks"
AS
SELECT
    t.*,
    mjBizAppsTasksTaskType_TypeID."Name" AS "Type",
    mjBizAppsTasksTaskCategory_CategoryID."Name" AS "Category",
    mjBizAppsTasksTask_ParentID."Name" AS "Parent",
    mjBizAppsCommonPerson_CreatedByPersonID."DisplayName" AS "CreatedByPerson",
    mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID."Name" AS "TaskTypeStatus",
    root_ParentID.root_id AS "RootParentID"
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
LEFT JOIN LATERAL (
    SELECT "__mj_bizappstasks".fn_task_parent_id_get_root_id(t."ID", t."ParentID") AS root_id
) AS root_ParentID ON true
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
    AND tc.relname = 'vwTasks'
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
    AND tc.relname = 'vwTasks'
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
        AND tc.relname = 'vwTasks'
        AND tc.relkind IN ('v', 'm')
  );

  DROP VIEW IF EXISTS "__mj_bizappstasks"."vwTasks" CASCADE;
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
GRANT SELECT ON "__mj_bizappstasks"."vwTasks" TO "cdp_UI";
GRANT SELECT ON "__mj_bizappstasks"."vwTasks" TO "cdp_Developer";
GRANT SELECT ON "__mj_bizappstasks"."vwTasks" TO "cdp_Integration";

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
    p_tasktypestatusid UUID DEFAULT NULL
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
                "TaskTypeStatusID"
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
                CASE WHEN p_tasktypestatusid_clear = true THEN NULL ELSE COALESCE(p_tasktypestatusid, NULL) END
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
    p_tasktypestatusid UUID DEFAULT NULL
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
        "TaskTypeStatusID" = CASE WHEN p_tasktypestatusid_clear = true THEN NULL ELSE COALESCE(p_tasktypestatusid, "TaskTypeStatusID") END
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

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: Index for Foreign Keys
-- ============================================================
CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_template_item_template_id"
    ON "__mj_bizappstasks"."TaskTemplateItem" ("TemplateID");

CREATE INDEX IF NOT EXISTS "idx_auto_mj_fkey_task_template_item_parent_item_id"
    ON "__mj_bizappstasks"."TaskTemplateItem" ("ParentItemID");

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: vwTaskTemplateItems
-- ============================================================

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Template Items
-----               SCHEMA:      __mj_bizappstasks
-----               BASE TABLE:  TaskTemplateItem
-----               PRIMARY KEY: ID
------------------------------------------------------------
DO $vw_regen$
DECLARE
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_bizappstasks"."vwTaskTemplateItems"
AS
SELECT
    t.*,
    mjBizAppsTasksTaskTemplate_TemplateID."Name" AS "Template",
    mjBizAppsTasksTaskTemplateItem_ParentItemID."Name" AS "ParentItem"
FROM
    "__mj_bizappstasks"."TaskTemplateItem" AS t
INNER JOIN
    "__mj_bizappstasks"."TaskTemplate" AS mjBizAppsTasksTaskTemplate_TemplateID
  ON
    "t"."TemplateID" = mjBizAppsTasksTaskTemplate_TemplateID."ID"
LEFT OUTER JOIN
    "__mj_bizappstasks"."TaskTemplateItem" AS mjBizAppsTasksTaskTemplateItem_ParentItemID
  ON
    "t"."ParentItemID" = mjBizAppsTasksTaskTemplateItem_ParentItemID."ID"
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
    AND tc.relname = 'vwTaskTemplateItems'
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
    AND tc.relname = 'vwTaskTemplateItems'
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
        AND tc.relname = 'vwTaskTemplateItems'
        AND tc.relkind IN ('v', 'm')
  );

  DROP VIEW IF EXISTS "__mj_bizappstasks"."vwTaskTemplateItems" CASCADE;
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
GRANT SELECT ON "__mj_bizappstasks"."vwTaskTemplateItems" TO "cdp_UI";
GRANT SELECT ON "__mj_bizappstasks"."vwTaskTemplateItems" TO "cdp_Developer";
GRANT SELECT ON "__mj_bizappstasks"."vwTaskTemplateItems" TO "cdp_Integration";

-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: spCreateTaskTemplateItem
-- ============================================================

------------------------------------------------------------
----- CREATE FUNCTION FOR TaskTemplateItem
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spCreateTaskTemplateItem'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spCreateTaskTemplateItem"(
    p_id UUID DEFAULT NULL,
    p_templateid UUID DEFAULT NULL,
    p_name varchar(255) DEFAULT NULL,
    p_description_clear boolean DEFAULT false,
    p_description TEXT DEFAULT NULL,
    p_parentitemid_clear boolean DEFAULT false,
    p_parentitemid UUID DEFAULT NULL,
    p_priority varchar(20) DEFAULT NULL,
    p_daysfromstart_clear boolean DEFAULT false,
    p_daysfromstart int DEFAULT NULL,
    p_hoursestimated_clear boolean DEFAULT false,
    p_hoursestimated decimal(8, 2) DEFAULT NULL,
    p_sequence int DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwTaskTemplateItems" AS $$
DECLARE
    v_new_id UUID;
BEGIN
    v_new_id := COALESCE(p_id, gen_random_uuid());
    INSERT INTO "__mj_bizappstasks"."TaskTemplateItem"
        (
            "ID",
            "TemplateID",
                "Name",
                "Description",
                "ParentItemID",
                "Priority",
                "DaysFromStart",
                "HoursEstimated",
                "Sequence"
        )
    VALUES
        (
            v_new_id,
            p_templateid,
                p_name,
                CASE WHEN p_description_clear = true THEN NULL ELSE COALESCE(p_description, NULL) END,
                CASE WHEN p_parentitemid_clear = true THEN NULL ELSE COALESCE(p_parentitemid, NULL) END,
                COALESCE(p_priority, 'Medium'),
                CASE WHEN p_daysfromstart_clear = true THEN NULL ELSE COALESCE(p_daysfromstart, NULL) END,
                CASE WHEN p_hoursestimated_clear = true THEN NULL ELSE COALESCE(p_hoursestimated, NULL) END,
                COALESCE(p_sequence, 100)
        )
    ;

    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwTaskTemplateItems"
    WHERE "ID" = v_new_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTaskTemplateItem" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spCreateTaskTemplateItem" TO "cdp_Integration";


-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: spUpdateTaskTemplateItem
-- ============================================================

------------------------------------------------------------
----- UPDATE FUNCTION FOR TaskTemplateItem
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spUpdateTaskTemplateItem'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spUpdateTaskTemplateItem"(
    p_id UUID,
    p_templateid UUID DEFAULT NULL,
    p_name varchar(255) DEFAULT NULL,
    p_description_clear boolean DEFAULT false,
    p_description TEXT DEFAULT NULL,
    p_parentitemid_clear boolean DEFAULT false,
    p_parentitemid UUID DEFAULT NULL,
    p_priority varchar(20) DEFAULT NULL,
    p_daysfromstart_clear boolean DEFAULT false,
    p_daysfromstart int DEFAULT NULL,
    p_hoursestimated_clear boolean DEFAULT false,
    p_hoursestimated decimal(8, 2) DEFAULT NULL,
    p_sequence int DEFAULT NULL
) RETURNS SETOF "__mj_bizappstasks"."vwTaskTemplateItems" AS $$
DECLARE
    v_updated_count INTEGER;
BEGIN
    UPDATE "__mj_bizappstasks"."TaskTemplateItem"
    SET
        "TemplateID" = COALESCE(p_templateid, "TemplateID"),
        "Name" = COALESCE(p_name, "Name"),
        "Description" = CASE WHEN p_description_clear = true THEN NULL ELSE COALESCE(p_description, "Description") END,
        "ParentItemID" = CASE WHEN p_parentitemid_clear = true THEN NULL ELSE COALESCE(p_parentitemid, "ParentItemID") END,
        "Priority" = COALESCE(p_priority, "Priority"),
        "DaysFromStart" = CASE WHEN p_daysfromstart_clear = true THEN NULL ELSE COALESCE(p_daysfromstart, "DaysFromStart") END,
        "HoursEstimated" = CASE WHEN p_hoursestimated_clear = true THEN NULL ELSE COALESCE(p_hoursestimated, "HoursEstimated") END,
        "Sequence" = COALESCE(p_sequence, "Sequence")
    WHERE
        "ID" = p_id;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    IF v_updated_count = 0 THEN
        -- Nothing was updated, return empty result set
        RETURN;
    END IF;

    -- Return the updated record from the base view
    RETURN QUERY
    SELECT * FROM "__mj_bizappstasks"."vwTaskTemplateItems"
    WHERE "ID" = p_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateTaskTemplateItem" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spUpdateTaskTemplateItem" TO "cdp_Integration";


------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTemplateItem table
------------------------------------------------------------
CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."fn_trg_update_task_template_item"()
RETURNS TRIGGER AS $$
BEGIN
    NEW."__mj_UpdatedAt" := NOW() AT TIME ZONE 'UTC';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS "trg_update_task_template_item" ON "__mj_bizappstasks"."TaskTemplateItem";

CREATE TRIGGER "trg_update_task_template_item"
BEFORE UPDATE ON "__mj_bizappstasks"."TaskTemplateItem"
FOR EACH ROW
EXECUTE FUNCTION "__mj_bizappstasks"."fn_trg_update_task_template_item"();



-- ============================================================
-- PostgreSQL Generated SQL for Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: spDeleteTaskTemplateItem
-- ============================================================

------------------------------------------------------------
----- DELETE FUNCTION FOR TaskTemplateItem
------------------------------------------------------------
DO $do$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT oid::regprocedure AS sig
             FROM pg_proc
             WHERE proname = 'spDeleteTaskTemplateItem'
               AND pronamespace = '__mj_bizappstasks'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || r.sig::text;
    END LOOP;
END
$do$;

CREATE OR REPLACE FUNCTION "__mj_bizappstasks"."spDeleteTaskTemplateItem"(
    p_id UUID
) RETURNS TABLE("ID" UUID) AS $$
#variable_conflict use_column
DECLARE
    v_affected_count INTEGER;
BEGIN

    DELETE FROM "__mj_bizappstasks"."TaskTemplateItem"
    WHERE "ID" = p_id;

    GET DIAGNOSTICS v_affected_count = ROW_COUNT;

    IF v_affected_count = 0 THEN
        RETURN QUERY SELECT NULL::UUID AS "ID";
    ELSE
        RETURN QUERY SELECT p_id AS "ID";
    END IF;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteTaskTemplateItem" TO "cdp_Developer";
GRANT EXECUTE ON FUNCTION "__mj_bizappstasks"."spDeleteTaskTemplateItem" TO "cdp_Integration";

-- ===================== CodeGen metadata after the generated objects =====================
-- Field settings, categories, icons and entity settings that CodeGen wrote after the objects
-- in the T-SQL migration, in the same order.

UPDATE ${mjSchema}."EntityField"
               SET "DefaultInView" = TRUE
               WHERE "ID" = '6F02DDCA-2018-4F9A-B39E-3F5068D9401D'
               AND "AutoUpdateDefaultInView" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "DefaultInView" = TRUE
               WHERE "ID" = '34B18848-C2BA-406A-858F-1A074788CC07'
               AND "AutoUpdateDefaultInView" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "DefaultInView" = TRUE
               WHERE "ID" = '9499A61F-7EB5-40C1-8F6B-9F30D92EEB28'
               AND "AutoUpdateDefaultInView" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "DefaultInView" = TRUE
               WHERE "ID" = '25DA14EE-06DB-48DD-8F63-647AA0DF52C3'
               AND "AutoUpdateDefaultInView" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "DefaultInView" = TRUE
               WHERE "ID" = 'C4AF1535-3578-4C8B-844A-F13BFDF1CC54'
               AND "AutoUpdateDefaultInView" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "IncludeInUserSearchAPI" = TRUE
               WHERE "ID" = '6F02DDCA-2018-4F9A-B39E-3F5068D9401D'
               AND "AutoUpdateIncludeInUserSearchAPI" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "UserSearchPredicateAPI" = 'BeginsWith'
               WHERE "ID" = '824E1D6B-5A3A-4211-8A05-0DA2E15499C2'
               AND "AutoUpdateUserSearchPredicate" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "UserSearchPredicateAPI" = 'Exact'
               WHERE "ID" = '6F02DDCA-2018-4F9A-B39E-3F5068D9401D'
               AND "AutoUpdateUserSearchPredicate" = TRUE;

UPDATE ${mjSchema}."Entity"
            SET "AllowUserSearchAPI" = FALSE
            WHERE "ID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9'
            AND "AutoUpdateAllowUserSearchAPI" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "DefaultInView" = TRUE
               WHERE "ID" = '55D2A288-00C8-425F-8E69-06BCED11D706'
               AND "AutoUpdateDefaultInView" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "DefaultInView" = TRUE
               WHERE "ID" = '4383F518-7AE7-4C9E-B105-D9090FC545F1'
               AND "AutoUpdateDefaultInView" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "DefaultInView" = TRUE
               WHERE "ID" = 'D010DCC4-5E0C-4FE2-BFF4-C35328BF48B0'
               AND "AutoUpdateDefaultInView" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "IncludeInUserSearchAPI" = TRUE
               WHERE "ID" = 'D010DCC4-5E0C-4FE2-BFF4-C35328BF48B0'
               AND "AutoUpdateIncludeInUserSearchAPI" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "UserSearchPredicateAPI" = 'BeginsWith'
               WHERE "ID" = '00619351-6557-42B0-B412-1FC4283CB682'
               AND "AutoUpdateUserSearchPredicate" = TRUE;

UPDATE ${mjSchema}."EntityField"
               SET "UserSearchPredicateAPI" = 'Exact'
               WHERE "ID" = 'D010DCC4-5E0C-4FE2-BFF4-C35328BF48B0'
               AND "AutoUpdateUserSearchPredicate" = TRUE;

UPDATE ${mjSchema}."Entity"
            SET "AllowUserSearchAPI" = FALSE
            WHERE "ID" = '1E30141A-826F-4278-BAA9-BBE14D29E606'
            AND "AutoUpdateAllowUserSearchAPI" = TRUE;

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'System Metadata',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '164ADEB0-E6AA-4CA4-BDD2-09532549A425' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.TaskTypeID

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Status Configuration',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '79A984FE-76F4-4C83-B03F-360369C18898' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.TaskType

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Status Configuration',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'FAD67D4D-89BF-4B5C-B593-556B56D1B68C' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.Name

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Status Configuration',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '824E1D6B-5A3A-4211-8A05-0DA2E15499C2' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.Code

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Status Configuration',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '6F02DDCA-2018-4F9A-B39E-3F5068D9401D' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.Description

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Status Configuration',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '119B6137-4212-4E45-B83B-98D61FFC0C48' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.MacroStatus

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Lifecycle Settings',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '34B18848-C2BA-406A-858F-1A074788CC07' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.Sequence

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Lifecycle Settings',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '9499A61F-7EB5-40C1-8F6B-9F30D92EEB28' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.IsDefault

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Lifecycle Settings',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '25DA14EE-06DB-48DD-8F63-647AA0DF52C3' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.IsTerminal

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Lifecycle Settings',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'C4AF1535-3578-4C8B-844A-F13BFDF1CC54' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.IsActive

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Lifecycle Settings',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '94184DEB-01E0-4824-9D66-65519A9B5585' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.Color

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'UI Presentation',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '6BC13897-9336-4F24-A670-46AFBBA71C19' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.IconClass

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'UI Presentation',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'B2C3C6F7-306E-430F-84C2-9E0AB464797A' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.OnEnterActionID

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Automation Hooks',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '910020AC-5D20-486C-97FF-846504F38E63' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.OnEnterAction

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Automation Hooks',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'F299E44E-7C52-44EF-AD98-59D68FA154F5' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.OnExitActionID

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Automation Hooks',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '182BF4C0-6850-4641-83A9-C97B8ABD16E8' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.OnExitAction

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Automation Hooks',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '7D89B146-90E4-4681-89F9-D89FFD21FC57' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.__mj_CreatedAt

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'System Metadata',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'FF5798A2-620D-4C3D-84A7-C146FC84A0DD' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.__mj_UpdatedAt

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'System Metadata',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'C12FCAE1-E043-4B77-BE64-9A81485D6A31' AND "AutoUpdateCategory" = TRUE;

/* Set entity icon to fa fa-tasks */

               UPDATE ${mjSchema}."Entity"
               SET "Icon" = 'fa fa-tasks', "__mj_UpdatedAt" = NOW()
               WHERE "ID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO ${mjSchema}."EntitySetting" ("ID", "EntityID", "Name", "Value", "__mj_CreatedAt", "__mj_UpdatedAt")
               VALUES ('db34f261-4f4e-4d65-be6b-e9a287b8404d', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', 'FieldCategoryInfo', '{"Status Configuration":{"icon":"fa fa-info-circle","description":"Basic identification and descriptive information for the task status"},"Lifecycle Settings":{"icon":"fa fa-random","description":"Configuration for status behavior, sequence, and lifecycle progression"},"UI Presentation":{"icon":"fa fa-palette","description":"Visual styling settings including colors and icons"},"Automation Hooks":{"icon":"fa fa-bolt","description":"Automated actions executed when entering or exiting this status"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', NOW(), NOW());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO ${mjSchema}."EntitySetting" ("ID", "EntityID", "Name", "Value", "__mj_CreatedAt", "__mj_UpdatedAt")
               VALUES ('7cda7d3f-7b35-4cea-aaf2-62b434884480', '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9', 'FieldCategoryIcons', '{"Status Configuration":"fa fa-info-circle","Lifecycle Settings":"fa fa-random","UI Presentation":"fa fa-palette","Automation Hooks":"fa fa-bolt","System Metadata":"fa fa-cog"}', NOW(), NOW());

/* Set DefaultForNewUser=false for NEW entity (category: reference, confidence: high) */

         UPDATE ${mjSchema}."ApplicationEntity"
         SET "DefaultForNewUser" = FALSE, "__mj_UpdatedAt" = NOW()
         WHERE "EntityID" = '6C8516B0-D87C-4B57-87F8-474D7FF6CDD9';

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'B8AD1F96-886C-4903-8D8D-FBEBB27BB506' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Name

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '4C041CC2-D419-485C-9896-790003F638B9' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Description

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '53F5B3E8-7220-48BD-A8E7-AEA68A83CB82' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.TypeID

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '7EA597ED-DA32-4CBC-A774-AD5E1986586A' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CategoryID

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '4E328156-A0FF-4D3F-8C01-C75B89F235A6' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.ParentID

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'D419FC58-9802-454E-8D34-1DFAEBEE7DF4' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Status

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '832E90CA-B150-4B19-AACE-F5385DB15E64' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Priority

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'BB921C78-2BAD-4B36-B7CB-E4A471372340' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.StartedAt

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '3C7731EA-D59C-4DB0-9A48-D2C40F7EFF04' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.DueAt

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Due Date',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'E50C83FB-BB14-4DAB-B1A5-9BC108988D7B' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CompletedAt

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '3B2893B6-9E68-4563-B25B-FEB90FEFF201' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.HoursEstimated

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '0CF37CC9-7B64-4E9C-A79A-B7CF5BE85244' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.HoursActual

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '7DC18266-AE9A-42F2-BF47-B406842712B8' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.PercentComplete

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '5812F201-256C-47AC-AEEB-3402FD1E9846' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Sequence

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '34C579D6-1FB8-4353-8F38-E75764139826' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.BlockedReason

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '72888BFB-A442-414A-96C5-6D8B3A3AA67F' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CompletionNotes

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '0A2F1BE2-D205-47E7-A804-679C04348EFC' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CreatedByPersonID

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '0259C564-2DFE-480B-9075-3FD4C71FA46C' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.OverdueNotifiedAt

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '65CB1110-12E0-4E48-BED3-6BF1B2926807' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.__mj_CreatedAt

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'DA16A787-212A-43BD-87E4-4D239F3EB12C' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.__mj_UpdatedAt

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '8711F2AD-0BDC-4398-819F-F87F1D11F34A' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.TaskTypeStatusID

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Status and Priority',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Task Type Status',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '70558CBD-0D69-41FB-A453-526878CD83D0' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Type

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '5E003CC8-55FC-4401-A7D9-7687BE6BD753' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Category

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '411B26C4-2AEC-41EB-96C1-897C92770598' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.Parent

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '16BEA5BD-358F-4E40-AB62-09BE3478345F' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.CreatedByPerson

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '4EE84219-D7CB-408F-8EAD-410973B487AF' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.TaskTypeStatus

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Status and Priority',
   "GeneratedFormSection" = 'Category',
   "DisplayName" = 'Task Type Status Name',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '0E437172-663E-481F-A1BE-8F3F90C55383' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.RootParentID

UPDATE ${mjSchema}."EntityField"
SET
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '3205C212-1737-4748-B232-3A64ABD3C93C' AND "AutoUpdateCategory" = TRUE;

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'System Metadata',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'B5D4A231-3F9F-45F8-B1E5-3B0FCCABFE8B' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.Name

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Task Type Definition',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '00619351-6557-42B0-B412-1FC4283CB682' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.Description

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Task Type Definition',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '231B2378-3454-4A1E-A002-412FD7C8AD75' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.Code

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Task Type Definition',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'D010DCC4-5E0C-4FE2-BFF4-C35328BF48B0' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.IconClass

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Task Type Definition',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '756BD750-22B9-40AF-B38A-C59A7B93FFFE' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.DefaultPriority

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Task Type Definition',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '55D2A288-00C8-425F-8E69-06BCED11D706' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.IsActive

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Task Type Definition',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '4383F518-7AE7-4C9E-B105-D9090FC545F1' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnCreateActionID

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Workflow Actions',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '555144F5-34AE-40A7-8C06-DE892DE859B7' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnCreateAction

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Workflow Actions',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'D2A2D5FB-E3BA-4965-86CE-50A4856E1169' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnAssignActionID

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Workflow Actions',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '2352E1F5-18CA-4495-85DA-516FEFC20463' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnAssignAction

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Workflow Actions',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '4391ECE2-8780-413A-8605-4569F84CFF03' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnStatusChangeActionID

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Workflow Actions',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '31C5FB7D-2FD4-4D32-85ED-2E3771A083E0' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnStatusChangeAction

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Workflow Actions',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '091A787F-6A51-45AE-9CA4-E5FE0D2B2C7E' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnPercentChangeActionID

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Workflow Actions',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'D6D015D3-C9D9-4EAC-B17C-4EAD902B6322' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnPercentChangeAction

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Workflow Actions',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'F91576C2-90C5-407D-820F-7FAEB246CFBD' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnCompleteActionID

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Workflow Actions',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '31F3F7CC-C0D0-4DD9-84F1-255BDB54DFAE' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnCompleteAction

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Workflow Actions',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '028BBCC5-6694-4B9F-81E8-F2B99EF72FBE' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnOverdueActionID

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Workflow Actions',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '86E954FA-9304-49F6-AD53-7EA09875FD87' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnOverdueAction

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Workflow Actions',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '39770061-F6E2-4E20-9D1A-8A9343E0F041' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnRejectActionID

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Workflow Actions',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '04B4F98D-F79D-4A84-9F63-FB5FFAC014D5' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnRejectAction

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Workflow Actions',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '4485192E-6DBC-4A4E-9A65-F4BC21A91DAA' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnCancelActionID

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Workflow Actions',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'A86F3057-5E26-450F-A958-2C1F63DD2A88' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.OnCancelAction

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'Workflow Actions',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'DA3EA9E6-160B-48C7-940E-567DCBF04D7A' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.__mj_CreatedAt

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'System Metadata',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = '3B6A900C-646F-4A98-8F4B-BC7AE54A9C7A' AND "AutoUpdateCategory" = TRUE;

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.__mj_UpdatedAt

UPDATE ${mjSchema}."EntityField"
SET
   "Category" = 'System Metadata',
   "GeneratedFormSection" = 'Category',
   "ExtendedType" = NULL,
   "CodeType" = NULL
WHERE
   "ID" = 'A4CC3D1E-96AC-4EC7-98CF-F83862215617' AND "AutoUpdateCategory" = TRUE;

/* Set entity icon to fa fa-tasks */

               UPDATE ${mjSchema}."Entity"
               SET "Icon" = 'fa fa-tasks', "__mj_UpdatedAt" = NOW()
               WHERE "ID" = '1E30141A-826F-4278-BAA9-BBE14D29E606';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO ${mjSchema}."EntitySetting" ("ID", "EntityID", "Name", "Value", "__mj_CreatedAt", "__mj_UpdatedAt")
               VALUES ('bffbf6f5-c5bb-430f-be8e-fc082bfee682', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'FieldCategoryInfo', '{"Task Type Definition":{"icon":"fa fa-info-circle","description":"General configuration and identification for the task type"},"Workflow Actions":{"icon":"fa fa-bolt","description":"Configurable automated actions triggered by task lifecycle events"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', NOW(), NOW());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO ${mjSchema}."EntitySetting" ("ID", "EntityID", "Name", "Value", "__mj_CreatedAt", "__mj_UpdatedAt")
               VALUES ('8b1b7927-6d4e-4a61-8fce-b48427f7ed27', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'FieldCategoryIcons', '{"Task Type Definition":"fa fa-info-circle","Workflow Actions":"fa fa-bolt","System Metadata":"fa fa-cog"}', NOW(), NOW());


-- ===================== Other =====================

/* Set field properties for entity */

/* Set field properties for entity */

/* Set categories for 19 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Type Status.ID

/* Set categories for 28 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Tasks.ID

/* Set categories for 25 fields */

-- UPDATE Entity Field Category Info MJ_BizApps_Tasks: Task Types.ID

-- Related-entity name field maps, which the T-SQL sets through the same core procedure.
SELECT 1 FROM ${mjSchema}."spUpdateEntityFieldRelatedEntityNameFieldMap"(p_entityfieldid := '79A984FE-76F4-4C83-B03F-360369C18898', p_relatedentitynamefieldmap := 'TaskType');
SELECT 1 FROM ${mjSchema}."spUpdateEntityFieldRelatedEntityNameFieldMap"(p_entityfieldid := '555144F5-34AE-40A7-8C06-DE892DE859B7', p_relatedentitynamefieldmap := 'OnCreateAction');
SELECT 1 FROM ${mjSchema}."spUpdateEntityFieldRelatedEntityNameFieldMap"(p_entityfieldid := '70558CBD-0D69-41FB-A453-526878CD83D0', p_relatedentitynamefieldmap := 'TaskTypeStatus');
SELECT 1 FROM ${mjSchema}."spUpdateEntityFieldRelatedEntityNameFieldMap"(p_entityfieldid := '31C5FB7D-2FD4-4D32-85ED-2E3771A083E0', p_relatedentitynamefieldmap := 'OnStatusChangeAction');
SELECT 1 FROM ${mjSchema}."spUpdateEntityFieldRelatedEntityNameFieldMap"(p_entityfieldid := '910020AC-5D20-486C-97FF-846504F38E63', p_relatedentitynamefieldmap := 'OnEnterAction');
SELECT 1 FROM ${mjSchema}."spUpdateEntityFieldRelatedEntityNameFieldMap"(p_entityfieldid := '182BF4C0-6850-4641-83A9-C97B8ABD16E8', p_relatedentitynamefieldmap := 'OnExitAction');
