-- ============================================================================
-- MemberJunction PostgreSQL Migration
-- Converted from SQL Server using TypeScript conversion pipeline
-- ============================================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Schema
CREATE SCHEMA IF NOT EXISTS "__mj_BizAppsTasks";
SET search_path TO "__mj_BizAppsTasks", public;

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
-- TaskType: General, Action Item, Follow-up, Deliverable, etc.
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."TaskType" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "Name" VARCHAR(100) NOT NULL,
 "Description" TEXT,
 "IconClass" VARCHAR(100),
 "DefaultPriority" VARCHAR(20) NOT NULL DEFAULT 'Medium',
 "OnAssignActionID" UUID,
 "OnCompleteActionID" UUID,
 "OnOverdueActionID" UUID,
 "OnPercentChangeActionID" UUID,
 "IsActive" BOOLEAN NOT NULL DEFAULT TRUE,
 CONSTRAINT PK_TaskType PRIMARY KEY ("ID"),
 CONSTRAINT UQ_TaskType_Name UNIQUE ("Name"),
 CONSTRAINT CK_TaskType_DefaultPriority CHECK ("DefaultPriority" IN ('Low', 'Medium', 'High', 'Critical')),
 CONSTRAINT FK_TaskType_OnAssignAction FOREIGN KEY ("OnAssignActionID") REFERENCES ${mjSchema}."Action"("ID"),
 CONSTRAINT FK_TaskType_OnCompleteAction FOREIGN KEY ("OnCompleteActionID") REFERENCES ${mjSchema}."Action"("ID"),
 CONSTRAINT FK_TaskType_OnOverdueAction FOREIGN KEY ("OnOverdueActionID") REFERENCES ${mjSchema}."Action"("ID"),
 CONSTRAINT FK_TaskType_OnPercentChangeAction FOREIGN KEY ("OnPercentChangeActionID") REFERENCES ${mjSchema}."Action"("ID")
);

---------------------------------------------------------------------------
-- TaskCategory: hierarchical grouping (e.g. "Finance Committee", "Q1 Audit")
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."TaskCategory" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "Name" VARCHAR(255) NOT NULL,
 "Description" TEXT,
 "ParentID" UUID,
 "ColorCode" VARCHAR(20),
 "Sequence" INTEGER NOT NULL DEFAULT 100,
 "IsActive" BOOLEAN NOT NULL DEFAULT TRUE,
 CONSTRAINT PK_TaskCategory PRIMARY KEY ("ID"),
 CONSTRAINT FK_TaskCategory_Parent FOREIGN KEY ("ParentID") REFERENCES "__mj_BizAppsTasks"."TaskCategory"("ID")
);

---------------------------------------------------------------------------
-- Task: the core work item
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."Task" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "Name" VARCHAR(255) NOT NULL,
 "Description" TEXT,
 "TypeID" UUID NOT NULL,
 "CategoryID" UUID,
 "ParentID" UUID,
 "Status" VARCHAR(50) NOT NULL DEFAULT 'Open',
 "Priority" VARCHAR(20) NOT NULL DEFAULT 'Medium',
 "StartedAt" TIMESTAMPTZ,
 "DueAt" TIMESTAMPTZ,
 "CompletedAt" TIMESTAMPTZ,
 "HoursEstimated" DECIMAL(8,2),
 "HoursActual" DECIMAL(8,2),
 "PercentComplete" INTEGER NOT NULL DEFAULT 0,
 "Sequence" INTEGER NOT NULL DEFAULT 100,
 "BlockedReason" TEXT,
 "CompletionNotes" TEXT,
 "CreatedByPersonID" UUID,
 "OverdueNotifiedAt" TIMESTAMPTZ,
 CONSTRAINT PK_Task PRIMARY KEY ("ID"),
 CONSTRAINT FK_Task_Type FOREIGN KEY ("TypeID") REFERENCES "__mj_BizAppsTasks"."TaskType"("ID"),
 CONSTRAINT FK_Task_Category FOREIGN KEY ("CategoryID") REFERENCES "__mj_BizAppsTasks"."TaskCategory"("ID"),
 CONSTRAINT FK_Task_Parent FOREIGN KEY ("ParentID") REFERENCES "__mj_BizAppsTasks"."Task"("ID"),
 CONSTRAINT FK_Task_CreatedByPerson FOREIGN KEY ("CreatedByPersonID") REFERENCES "__mj_BizAppsCommon"."Person"("ID"),
 CONSTRAINT CK_Task_Status CHECK ("Status" IN ('Open', 'InProgress', 'Blocked', 'Completed', 'Cancelled')),
 CONSTRAINT CK_Task_Priority CHECK ("Priority" IN ('Low', 'Medium', 'High', 'Critical')),
 CONSTRAINT CK_Task_PercentComplete CHECK ("PercentComplete" >= 0 AND "PercentComplete" <= 100)
);

---------------------------------------------------------------------------
-- TaskRole: Primary, Reviewer, Observer, etc.
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."TaskRole" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "Name" VARCHAR(100) NOT NULL,
 "Description" TEXT,
 "Sequence" INTEGER NOT NULL DEFAULT 100,
 CONSTRAINT PK_TaskRole PRIMARY KEY ("ID"),
 CONSTRAINT UQ_TaskRole_Name UNIQUE ("Name")
);

---------------------------------------------------------------------------
-- TaskAssignment: multi-person assignment with polymorphic assignee
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."TaskAssignment" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TaskID" UUID NOT NULL,
 "AssigneeEntityID" UUID NOT NULL,
 "AssigneeRecordID" VARCHAR(450) NOT NULL,
 "RoleID" UUID,
 "RoleNotes" VARCHAR(255),
 "Status" VARCHAR(50) NOT NULL DEFAULT 'Pending',
 "AssignedByPersonID" UUID,
 "AssignedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 CONSTRAINT PK_TaskAssignment PRIMARY KEY ("ID"),
 CONSTRAINT FK_TaskAssignment_Task FOREIGN KEY ("TaskID") REFERENCES "__mj_BizAppsTasks"."Task"("ID"),
 CONSTRAINT FK_TaskAssignment_AssigneeEntity FOREIGN KEY ("AssigneeEntityID") REFERENCES ${mjSchema}."Entity"("ID"),
 CONSTRAINT FK_TaskAssignment_Role FOREIGN KEY ("RoleID") REFERENCES "__mj_BizAppsTasks"."TaskRole"("ID"),
 CONSTRAINT FK_TaskAssignment_AssignedByPerson FOREIGN KEY ("AssignedByPersonID") REFERENCES "__mj_BizAppsCommon"."Person"("ID"),
 CONSTRAINT CK_TaskAssignment_Status CHECK ("Status" IN ('Pending', 'InProgress', 'Completed')),
 CONSTRAINT UQ_TaskAssignment_Unique UNIQUE ("TaskID", "AssigneeEntityID", "AssigneeRecordID", "RoleID")
);

---------------------------------------------------------------------------
-- TaskLink: polymorphic link from tasks to any entity record
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."TaskLink" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TaskID" UUID NOT NULL,
 "EntityID" UUID NOT NULL,
 "RecordID" VARCHAR(450) NOT NULL,
 "Description" VARCHAR(500),
 CONSTRAINT PK_TaskLink PRIMARY KEY ("ID"),
 CONSTRAINT FK_TaskLink_Task FOREIGN KEY ("TaskID") REFERENCES "__mj_BizAppsTasks"."Task"("ID"),
 CONSTRAINT FK_TaskLink_Entity FOREIGN KEY ("EntityID") REFERENCES ${mjSchema}."Entity"("ID"),
 CONSTRAINT UQ_TaskLink_Unique UNIQUE ("TaskID", "EntityID", "RecordID")
);

---------------------------------------------------------------------------
-- TaskDependency: dependency graph between tasks
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."TaskDependency" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TaskID" UUID NOT NULL,
 "DependsOnTaskID" UUID NOT NULL,
 "DependencyType" VARCHAR(50) NOT NULL DEFAULT 'FinishToStart',
 CONSTRAINT PK_TaskDependency PRIMARY KEY ("ID"),
 CONSTRAINT FK_TaskDependency_Task FOREIGN KEY ("TaskID") REFERENCES "__mj_BizAppsTasks"."Task"("ID"),
 CONSTRAINT FK_TaskDependency_DependsOnTask FOREIGN KEY ("DependsOnTaskID") REFERENCES "__mj_BizAppsTasks"."Task"("ID"),
 CONSTRAINT CK_TaskDependency_Type CHECK ("DependencyType" IN ('FinishToStart', 'StartToStart', 'FinishToFinish', 'StartToFinish')),
 CONSTRAINT CK_TaskDependency_NoSelfRef CHECK ("TaskID" <> "DependsOnTaskID"),
 CONSTRAINT UQ_TaskDependency_Unique UNIQUE ("TaskID", "DependsOnTaskID")
);

---------------------------------------------------------------------------
-- TaskTag: lightweight cross-cutting labels
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."TaskTag" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "Name" VARCHAR(100) NOT NULL,
 "ColorCode" VARCHAR(20),
 "Description" TEXT,
 CONSTRAINT PK_TaskTag PRIMARY KEY ("ID"),
 CONSTRAINT UQ_TaskTag_Name UNIQUE ("Name")
);

---------------------------------------------------------------------------
-- TaskTagLink: many-to-many between Task and TaskTag
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."TaskTagLink" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TaskID" UUID NOT NULL,
 "TagID" UUID NOT NULL,
 CONSTRAINT PK_TaskTagLink PRIMARY KEY ("ID"),
 CONSTRAINT FK_TaskTagLink_Task FOREIGN KEY ("TaskID") REFERENCES "__mj_BizAppsTasks"."Task"("ID"),
 CONSTRAINT FK_TaskTagLink_Tag FOREIGN KEY ("TagID") REFERENCES "__mj_BizAppsTasks"."TaskTag"("ID"),
 CONSTRAINT UQ_TaskTagLink_Unique UNIQUE ("TaskID", "TagID")
);

---------------------------------------------------------------------------
-- TaskComment: threaded discussion on tasks
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."TaskComment" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TaskID" UUID NOT NULL,
 "ParentID" UUID,
 "PersonID" UUID NOT NULL,
 "Content" TEXT NOT NULL,
 "IsEdited" BOOLEAN NOT NULL DEFAULT FALSE,
 CONSTRAINT PK_TaskComment PRIMARY KEY ("ID"),
 CONSTRAINT FK_TaskComment_Task FOREIGN KEY ("TaskID") REFERENCES "__mj_BizAppsTasks"."Task"("ID"),
 CONSTRAINT FK_TaskComment_Parent FOREIGN KEY ("ParentID") REFERENCES "__mj_BizAppsTasks"."TaskComment"("ID"),
 CONSTRAINT FK_TaskComment_Person FOREIGN KEY ("PersonID") REFERENCES "__mj_BizAppsCommon"."Person"("ID")
);

---------------------------------------------------------------------------
-- TaskTemplate: reusable task structures (e.g. "Board Meeting Prep")
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."TaskTemplate" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "Name" VARCHAR(255) NOT NULL,
 "Description" TEXT,
 "CategoryID" UUID,
 "TypeID" UUID,
 "IsActive" BOOLEAN NOT NULL DEFAULT TRUE,
 CONSTRAINT PK_TaskTemplate PRIMARY KEY ("ID"),
 CONSTRAINT FK_TaskTemplate_Category FOREIGN KEY ("CategoryID") REFERENCES "__mj_BizAppsTasks"."TaskCategory"("ID"),
 CONSTRAINT FK_TaskTemplate_Type FOREIGN KEY ("TypeID") REFERENCES "__mj_BizAppsTasks"."TaskType"("ID")
);

---------------------------------------------------------------------------
-- TaskTemplateItem: sub-task definitions within a template
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."TaskTemplateItem" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TemplateID" UUID NOT NULL,
 "Name" VARCHAR(255) NOT NULL,
 "Description" TEXT,
 "ParentItemID" UUID,
 "Priority" VARCHAR(20) NOT NULL DEFAULT 'Medium',
 "DaysFromStart" INTEGER,
 "HoursEstimated" DECIMAL(8,2),
 "Sequence" INTEGER NOT NULL DEFAULT 100,
 CONSTRAINT PK_TaskTemplateItem PRIMARY KEY ("ID"),
 CONSTRAINT FK_TaskTemplateItem_Template FOREIGN KEY ("TemplateID") REFERENCES "__mj_BizAppsTasks"."TaskTemplate"("ID"),
 CONSTRAINT FK_TaskTemplateItem_Parent FOREIGN KEY ("ParentItemID") REFERENCES "__mj_BizAppsTasks"."TaskTemplateItem"("ID"),
 CONSTRAINT CK_TaskTemplateItem_Priority CHECK ("Priority" IN ('Low', 'Medium', 'High', 'Critical'))
);

---------------------------------------------------------------------------
-- TaskTemplateItemDependency: dependency graph within a template
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."TaskTemplateItemDependency" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "ItemID" UUID NOT NULL,
 "DependsOnItemID" UUID NOT NULL,
 "DependencyType" VARCHAR(50) NOT NULL DEFAULT 'FinishToStart',
 CONSTRAINT PK_TaskTemplateItemDependency PRIMARY KEY ("ID"),
 CONSTRAINT FK_TaskTemplateItemDep_Item FOREIGN KEY ("ItemID") REFERENCES "__mj_BizAppsTasks"."TaskTemplateItem"("ID"),
 CONSTRAINT FK_TaskTemplateItemDep_DependsOn FOREIGN KEY ("DependsOnItemID") REFERENCES "__mj_BizAppsTasks"."TaskTemplateItem"("ID"),
 CONSTRAINT CK_TaskTemplateItemDep_Type CHECK ("DependencyType" IN ('FinishToStart', 'StartToStart', 'FinishToFinish', 'StartToFinish')),
 CONSTRAINT CK_TaskTemplateItemDep_NoSelfRef CHECK ("ItemID" <> "DependsOnItemID"),
 CONSTRAINT UQ_TaskTemplateItemDep_Unique UNIQUE ("ItemID", "DependsOnItemID")
);

---------------------------------------------------------------------------
-- TaskTemplateItemRole: pre-defined assignment roles per template item
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."TaskTemplateItemRole" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "ItemID" UUID NOT NULL,
 "RoleID" UUID NOT NULL,
 CONSTRAINT PK_TaskTemplateItemRole PRIMARY KEY ("ID"),
 CONSTRAINT FK_TaskTemplateItemRole_Item FOREIGN KEY ("ItemID") REFERENCES "__mj_BizAppsTasks"."TaskTemplateItem"("ID"),
 CONSTRAINT FK_TaskTemplateItemRole_Role FOREIGN KEY ("RoleID") REFERENCES "__mj_BizAppsTasks"."TaskRole"("ID"),
 CONSTRAINT UQ_TaskTemplateItemRole_Unique UNIQUE ("ItemID", "RoleID")
);

---------------------------------------------------------------------------
-- TaskActivity: automatic audit log for task changes
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."TaskActivity" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TaskID" UUID NOT NULL,
 "PersonID" UUID,
 "ActivityType" VARCHAR(50) NOT NULL,
 "PreviousValue" VARCHAR(500),
 "NewValue" VARCHAR(500),
 "Description" TEXT,
 CONSTRAINT PK_TaskActivity PRIMARY KEY ("ID"),
 CONSTRAINT FK_TaskActivity_Task FOREIGN KEY ("TaskID") REFERENCES "__mj_BizAppsTasks"."Task"("ID"),
 CONSTRAINT FK_TaskActivity_Person FOREIGN KEY ("PersonID") REFERENCES "__mj_BizAppsCommon"."Person"("ID"),
 CONSTRAINT "CK_TaskActivity_Type" CHECK ("ActivityType" IN (
 'StatusChange', 'AssignmentAdded', 'AssignmentRemoved',
 'DueDateChanged', 'PriorityChanged', 'PercentCompleteChanged',
 'DependencyAdded', 'DependencyRemoved', 'Created', 'Completed'
 ))
);

---------------------------------------------------------------------------
-- TaskNotificationConfig: global + per-TaskType overdue notification settings
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."TaskNotificationConfig" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TaskTypeID" UUID,
 "OverdueNotificationsEnabled" BOOLEAN NOT NULL DEFAULT TRUE,
 "OverdueGracePeriodHours" INTEGER NOT NULL DEFAULT 0,
 "OverdueRepeatIntervalHours" INTEGER,
 "NotifyAssignees" BOOLEAN NOT NULL DEFAULT TRUE,
 "NotifyCreator" BOOLEAN NOT NULL DEFAULT TRUE,
 "OverdueActionID" UUID,
 CONSTRAINT PK_TaskNotificationConfig PRIMARY KEY ("ID"),
 CONSTRAINT FK_TaskNotificationConfig_TaskType FOREIGN KEY ("TaskTypeID") REFERENCES "__mj_BizAppsTasks"."TaskType"("ID"),
 CONSTRAINT FK_TaskNotificationConfig_Action FOREIGN KEY ("OverdueActionID") REFERENCES ${mjSchema}."Action"("ID"),
 CONSTRAINT UQ_TaskNotificationConfig_TaskType UNIQUE ("TaskTypeID")
);

---------------------------------------------------------------------------
-- TaskNotificationLog: audit trail of sent notifications
---------------------------------------------------------------------------
CREATE TABLE "__mj_BizAppsTasks"."TaskNotificationLog" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TaskID" UUID NOT NULL,
 "NotificationType" VARCHAR(50) NOT NULL,
 "NotifiedUserID" UUID NOT NULL,
 "NotifiedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 CONSTRAINT PK_TaskNotificationLog PRIMARY KEY ("ID"),
 CONSTRAINT FK_TaskNotificationLog_Task FOREIGN KEY ("TaskID") REFERENCES "__mj_BizAppsTasks"."Task"("ID"),
 CONSTRAINT FK_TaskNotificationLog_User FOREIGN KEY ("NotifiedUserID") REFERENCES ${mjSchema}."User"("ID"),
 CONSTRAINT CK_TaskNotificationLog_Type CHECK ("NotificationType" IN ('Overdue', 'OverdueReminder'))
);

ALTER TABLE "__mj_BizAppsTasks"."TaskLink"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskLink" */
ALTER TABLE "__mj_BizAppsTasks"."TaskLink"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItemRole" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItemRole"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItemRole" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItemRole"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskNotificationConfig" */
ALTER TABLE "__mj_BizAppsTasks"."TaskNotificationConfig"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskNotificationConfig" */
ALTER TABLE "__mj_BizAppsTasks"."TaskNotificationConfig"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskDependency" */
ALTER TABLE "__mj_BizAppsTasks"."TaskDependency"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskDependency" */
ALTER TABLE "__mj_BizAppsTasks"."TaskDependency"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTemplate" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTemplate"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTemplate" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTemplate"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskRole" */
ALTER TABLE "__mj_BizAppsTasks"."TaskRole"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskRole" */
ALTER TABLE "__mj_BizAppsTasks"."TaskRole"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskActivity" */
ALTER TABLE "__mj_BizAppsTasks"."TaskActivity"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskActivity" */
ALTER TABLE "__mj_BizAppsTasks"."TaskActivity"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTagLink" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTagLink"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTagLink" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTagLink"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItemDependency" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItemDependency"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItemDependency" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItemDependency"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskType" */
ALTER TABLE "__mj_BizAppsTasks"."TaskType"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskType" */
ALTER TABLE "__mj_BizAppsTasks"."TaskType"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItem" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItem"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItem" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItem"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskNotificationLog" */
ALTER TABLE "__mj_BizAppsTasks"."TaskNotificationLog"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskNotificationLog" */
ALTER TABLE "__mj_BizAppsTasks"."TaskNotificationLog"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskComment" */
ALTER TABLE "__mj_BizAppsTasks"."TaskComment"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskComment" */
ALTER TABLE "__mj_BizAppsTasks"."TaskComment"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTag" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTag"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTag" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTag"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskAssignment" */
ALTER TABLE "__mj_BizAppsTasks"."TaskAssignment"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskAssignment" */
ALTER TABLE "__mj_BizAppsTasks"."TaskAssignment"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskCategory" */
ALTER TABLE "__mj_BizAppsTasks"."TaskCategory"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskCategory" */
ALTER TABLE "__mj_BizAppsTasks"."TaskCategory"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."Task" */
ALTER TABLE "__mj_BizAppsTasks"."Task"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."Task" */
ALTER TABLE "__mj_BizAppsTasks"."Task"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskActivity_TaskID" ON "__mj_BizAppsTasks"."TaskActivity" ("TaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskActivity_PersonID" ON "__mj_BizAppsTasks"."TaskActivity" ("PersonID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskAssignment_TaskID" ON "__mj_BizAppsTasks"."TaskAssignment" ("TaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskAssignment_AssigneeEntityID" ON "__mj_BizAppsTasks"."TaskAssignment" ("AssigneeEntityID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskAssignment_RoleID" ON "__mj_BizAppsTasks"."TaskAssignment" ("RoleID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskAssignment_AssignedByPersonID" ON "__mj_BizAppsTasks"."TaskAssignment" ("AssignedByPersonID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskCategory_ParentID" ON "__mj_BizAppsTasks"."TaskCategory" ("ParentID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskComment_TaskID" ON "__mj_BizAppsTasks"."TaskComment" ("TaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskComment_ParentID" ON "__mj_BizAppsTasks"."TaskComment" ("ParentID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskComment_PersonID" ON "__mj_BizAppsTasks"."TaskComment" ("PersonID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskDependency_TaskID" ON "__mj_BizAppsTasks"."TaskDependency" ("TaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskDependency_DependsOnTaskID" ON "__mj_BizAppsTasks"."TaskDependency" ("DependsOnTaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskLink_TaskID" ON "__mj_BizAppsTasks"."TaskLink" ("TaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskLink_EntityID" ON "__mj_BizAppsTasks"."TaskLink" ("EntityID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskNotificationConfig_TaskTypeID" ON "__mj_BizAppsTasks"."TaskNotificationConfig" ("TaskTypeID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskNotificationConfig_OverdueActionID" ON "__mj_BizAppsTasks"."TaskNotificationConfig" ("OverdueActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskNotificationLog_TaskID" ON "__mj_BizAppsTasks"."TaskNotificationLog" ("TaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskNotificationLog_NotifiedUserID" ON "__mj_BizAppsTasks"."TaskNotificationLog" ("NotifiedUserID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTagLink_TaskID" ON "__mj_BizAppsTasks"."TaskTagLink" ("TaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTagLink_TagID" ON "__mj_BizAppsTasks"."TaskTagLink" ("TagID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTemplateItemDependency_ItemID" ON "__mj_BizAppsTasks"."TaskTemplateItemDependency" ("ItemID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTemplateItemDependency_DependsOnItemID" ON "__mj_BizAppsTasks"."TaskTemplateItemDependency" ("DependsOnItemID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTemplateItemRole_ItemID" ON "__mj_BizAppsTasks"."TaskTemplateItemRole" ("ItemID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTemplateItemRole_RoleID" ON "__mj_BizAppsTasks"."TaskTemplateItemRole" ("RoleID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTemplateItem_TemplateID" ON "__mj_BizAppsTasks"."TaskTemplateItem" ("TemplateID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTemplateItem_ParentItemID" ON "__mj_BizAppsTasks"."TaskTemplateItem" ("ParentItemID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTemplate_CategoryID" ON "__mj_BizAppsTasks"."TaskTemplate" ("CategoryID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTemplate_TypeID" ON "__mj_BizAppsTasks"."TaskTemplate" ("TypeID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnAssignActionID" ON "__mj_BizAppsTasks"."TaskType" ("OnAssignActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnCompleteActionID" ON "__mj_BizAppsTasks"."TaskType" ("OnCompleteActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnOverdueActionID" ON "__mj_BizAppsTasks"."TaskType" ("OnOverdueActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnPercentChangeActionID" ON "__mj_BizAppsTasks"."TaskType" ("OnPercentChangeActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_TypeID" ON "__mj_BizAppsTasks"."Task" ("TypeID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_CategoryID" ON "__mj_BizAppsTasks"."Task" ("CategoryID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_ParentID" ON "__mj_BizAppsTasks"."Task" ("ParentID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_CreatedByPersonID" ON "__mj_BizAppsTasks"."Task" ("CreatedByPersonID");


-- ===================== Helper Functions (fn*) =====================

CREATE OR REPLACE FUNCTION "__mj_BizAppsTasks"."fnTaskCategoryParentID_GetRootID"(
    p_RecordID UUID,
    p_ParentID UUID
) RETURNS TABLE("RootID" UUID) AS $fn$
    WITH RECURSIVE cte_root_parent AS (
        SELECT
            "ID",
            "ParentID",
            "ID" AS root_parent_id,
            0 AS depth
        FROM "__mj_BizAppsTasks"."TaskCategory"
        WHERE "ID" = COALESCE(p_ParentID, p_RecordID)

        UNION ALL

        SELECT
            c."ID",
            c."ParentID",
            c."ID" AS root_parent_id,
            p.depth + 1 AS depth
        FROM "__mj_BizAppsTasks"."TaskCategory" c
        INNER JOIN cte_root_parent p ON c."ID" = p."ParentID"
        WHERE p.depth < 100
    )
    SELECT root_parent_id AS "RootID"
    FROM cte_root_parent
    WHERE "ParentID" IS NULL
    ORDER BY root_parent_id
    LIMIT 1;
$fn$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION "__mj_BizAppsTasks"."fnTaskCommentParentID_GetRootID"(
    p_RecordID UUID,
    p_ParentID UUID
) RETURNS TABLE("RootID" UUID) AS $fn$
    WITH RECURSIVE cte_root_parent AS (
        SELECT
            "ID",
            "ParentID",
            "ID" AS root_parent_id,
            0 AS depth
        FROM "__mj_BizAppsTasks"."TaskComment"
        WHERE "ID" = COALESCE(p_ParentID, p_RecordID)

        UNION ALL

        SELECT
            c."ID",
            c."ParentID",
            c."ID" AS root_parent_id,
            p.depth + 1 AS depth
        FROM "__mj_BizAppsTasks"."TaskComment" c
        INNER JOIN cte_root_parent p ON c."ID" = p."ParentID"
        WHERE p.depth < 100
    )
    SELECT root_parent_id AS "RootID"
    FROM cte_root_parent
    WHERE "ParentID" IS NULL
    ORDER BY root_parent_id
    LIMIT 1;
$fn$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION "__mj_BizAppsTasks"."fnTaskTemplateItemParentItemID_GetRootID"(
    p_RecordID UUID,
    p_ParentID UUID
) RETURNS TABLE("RootID" UUID) AS $fn$
    WITH RECURSIVE cte_root_parent AS (
        SELECT
            "ID",
            "ParentItemID",
            "ID" AS root_parent_id,
            0 AS depth
        FROM "__mj_BizAppsTasks"."TaskTemplateItem"
        WHERE "ID" = COALESCE(p_ParentID, p_RecordID)

        UNION ALL

        SELECT
            c."ID",
            c."ParentItemID",
            c."ID" AS root_parent_id,
            p.depth + 1 AS depth
        FROM "__mj_BizAppsTasks"."TaskTemplateItem" c
        INNER JOIN cte_root_parent p ON c."ID" = p."ParentItemID"
        WHERE p.depth < 100
    )
    SELECT root_parent_id AS "RootID"
    FROM cte_root_parent
    WHERE "ParentItemID" IS NULL
    ORDER BY root_parent_id
    LIMIT 1;
$fn$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION "__mj_BizAppsTasks"."fnTaskParentID_GetRootID"(
    p_RecordID UUID,
    p_ParentID UUID
) RETURNS TABLE("RootID" UUID) AS $fn$
    WITH RECURSIVE cte_root_parent AS (
        SELECT
            "ID",
            "ParentID",
            "ID" AS root_parent_id,
            0 AS depth
        FROM "__mj_BizAppsTasks"."Task"
        WHERE "ID" = COALESCE(p_ParentID, p_RecordID)

        UNION ALL

        SELECT
            c."ID",
            c."ParentID",
            c."ID" AS root_parent_id,
            p.depth + 1 AS depth
        FROM "__mj_BizAppsTasks"."Task" c
        INNER JOIN cte_root_parent p ON c."ID" = p."ParentID"
        WHERE p.depth < 100
    )
    SELECT root_parent_id AS "RootID"
    FROM cte_root_parent
    WHERE "ParentID" IS NULL
    ORDER BY root_parent_id
    LIMIT 1;
$fn$ LANGUAGE sql STABLE;


-- ===================== Views =====================

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTaskCategories" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskCategories';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTaskCategories"
AS SELECT
    t.*,
    "mjBizAppsTasksTaskCategory_ParentID"."Name" AS "Parent",
    "root_ParentID"."RootID" AS "RootParentID"
FROM
    "__mj_BizAppsTasks"."TaskCategory" AS t
LEFT OUTER JOIN
    "__mj_BizAppsTasks"."TaskCategory" AS "mjBizAppsTasksTaskCategory_ParentID"
  ON
    t."ParentID" = "mjBizAppsTasksTaskCategory_ParentID"."ID"
LEFT JOIN LATERAL (SELECT * FROM "__mj_BizAppsTasks"."fnTaskCategoryParentID_GetRootID"(t."ID", t."ParentID")) AS "root_ParentID"
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

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTaskActivities" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskActivities';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTaskActivities"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "mjBizAppsCommonPerson_PersonID"."DisplayName" AS "Person"
FROM
    "__mj_BizAppsTasks"."TaskActivity" AS t
INNER JOIN
    "__mj_BizAppsTasks"."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
LEFT OUTER JOIN
    "${mjSchema}_BizAppsCommon"."Person" AS "mjBizAppsCommonPerson_PersonID"
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

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTaskComments" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskComments';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTaskComments"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "mjBizAppsCommonPerson_PersonID"."DisplayName" AS "Person",
    "root_ParentID"."RootID" AS "RootParentID"
FROM
    "__mj_BizAppsTasks"."TaskComment" AS t
INNER JOIN
    "__mj_BizAppsTasks"."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
INNER JOIN
    "${mjSchema}_BizAppsCommon"."Person" AS "mjBizAppsCommonPerson_PersonID"
  ON
    t."PersonID" = "mjBizAppsCommonPerson_PersonID"."ID"
LEFT JOIN LATERAL (SELECT * FROM "__mj_BizAppsTasks"."fnTaskCommentParentID_GetRootID"(t."ID", t."ParentID")) AS "root_ParentID"
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

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTaskDependencies" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskDependencies';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTaskDependencies"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "mjBizAppsTasksTask_DependsOnTaskID"."Name" AS "DependsOnTask"
FROM
    "__mj_BizAppsTasks"."TaskDependency" AS t
INNER JOIN
    "__mj_BizAppsTasks"."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
INNER JOIN
    "__mj_BizAppsTasks"."Task" AS "mjBizAppsTasksTask_DependsOnTaskID"
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

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTaskAssignments" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskAssignments';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTaskAssignments"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "MJEntity_AssigneeEntityID"."Name" AS "AssigneeEntity",
    "mjBizAppsTasksTaskRole_RoleID"."Name" AS "Role",
    "mjBizAppsCommonPerson_AssignedByPersonID"."DisplayName" AS "AssignedByPerson"
FROM
    "__mj_BizAppsTasks"."TaskAssignment" AS t
INNER JOIN
    "__mj_BizAppsTasks"."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
INNER JOIN
    "${mjSchema}"."Entity" AS "MJEntity_AssigneeEntityID"
  ON
    t."AssigneeEntityID" = "MJEntity_AssigneeEntityID"."ID"
LEFT OUTER JOIN
    "__mj_BizAppsTasks"."TaskRole" AS "mjBizAppsTasksTaskRole_RoleID"
  ON
    t."RoleID" = "mjBizAppsTasksTaskRole_RoleID"."ID"
LEFT OUTER JOIN
    "${mjSchema}_BizAppsCommon"."Person" AS "mjBizAppsCommonPerson_AssignedByPersonID"
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

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTaskRoles" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskRoles';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTaskRoles"
AS SELECT
    t.*
FROM
    "__mj_BizAppsTasks"."TaskRole" AS t$vsql$;
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

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTaskNotificationConfigs" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskNotificationConfigs';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTaskNotificationConfigs"
AS SELECT
    t.*,
    "mjBizAppsTasksTaskType_TaskTypeID"."Name" AS "TaskType",
    "MJAction_OverdueActionID"."Name" AS "OverdueAction"
FROM
    "__mj_BizAppsTasks"."TaskNotificationConfig" AS t
LEFT OUTER JOIN
    "__mj_BizAppsTasks"."TaskType" AS "mjBizAppsTasksTaskType_TaskTypeID"
  ON
    t."TaskTypeID" = "mjBizAppsTasksTaskType_TaskTypeID"."ID"
LEFT OUTER JOIN
    "${mjSchema}"."Action" AS "MJAction_OverdueActionID"
  ON
    t."OverdueActionID" = "MJAction_OverdueActionID"."ID"$vsql$;
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

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTaskNotificationLogs" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskNotificationLogs';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTaskNotificationLogs"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "MJUser_NotifiedUserID"."Name" AS "NotifiedUser"
FROM
    "__mj_BizAppsTasks"."TaskNotificationLog" AS t
INNER JOIN
    "__mj_BizAppsTasks"."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
INNER JOIN
    "${mjSchema}"."User" AS "MJUser_NotifiedUserID"
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

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTaskTagLinks" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskTagLinks';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTaskTagLinks"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "mjBizAppsTasksTaskTag_TagID"."Name" AS "Tag"
FROM
    "__mj_BizAppsTasks"."TaskTagLink" AS t
INNER JOIN
    "__mj_BizAppsTasks"."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
INNER JOIN
    "__mj_BizAppsTasks"."TaskTag" AS "mjBizAppsTasksTaskTag_TagID"
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

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTaskLinks" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskLinks';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTaskLinks"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "MJEntity_EntityID"."Name" AS "Entity"
FROM
    "__mj_BizAppsTasks"."TaskLink" AS t
INNER JOIN
    "__mj_BizAppsTasks"."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
INNER JOIN
    "${mjSchema}"."Entity" AS "MJEntity_EntityID"
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

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTaskTags" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskTags';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTaskTags"
AS SELECT
    t.*
FROM
    "__mj_BizAppsTasks"."TaskTag" AS t$vsql$;
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

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTaskTemplateItems" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskTemplateItems';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTaskTemplateItems"
AS SELECT
    t.*,
    "mjBizAppsTasksTaskTemplate_TemplateID"."Name" AS "Template",
    "mjBizAppsTasksTaskTemplateItem_ParentItemID"."Name" AS "ParentItem",
    "root_ParentItemID"."RootID" AS "RootParentItemID"
FROM
    "__mj_BizAppsTasks"."TaskTemplateItem" AS t
INNER JOIN
    "__mj_BizAppsTasks"."TaskTemplate" AS "mjBizAppsTasksTaskTemplate_TemplateID"
  ON
    t."TemplateID" = "mjBizAppsTasksTaskTemplate_TemplateID"."ID"
LEFT OUTER JOIN
    "__mj_BizAppsTasks"."TaskTemplateItem" AS "mjBizAppsTasksTaskTemplateItem_ParentItemID"
  ON
    t."ParentItemID" = "mjBizAppsTasksTaskTemplateItem_ParentItemID"."ID"
LEFT JOIN LATERAL (SELECT * FROM "__mj_BizAppsTasks"."fnTaskTemplateItemParentItemID_GetRootID"(t."ID", t."ParentItemID")) AS "root_ParentItemID"
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

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTaskTemplateItemDependencies" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskTemplateItemDependencies';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTaskTemplateItemDependencies"
AS SELECT
    t.*,
    "mjBizAppsTasksTaskTemplateItem_ItemID"."Name" AS "Item",
    "mjBizAppsTasksTaskTemplateItem_DependsOnItemID"."Name" AS "DependsOnItem"
FROM
    "__mj_BizAppsTasks"."TaskTemplateItemDependency" AS t
INNER JOIN
    "__mj_BizAppsTasks"."TaskTemplateItem" AS "mjBizAppsTasksTaskTemplateItem_ItemID"
  ON
    t."ItemID" = "mjBizAppsTasksTaskTemplateItem_ItemID"."ID"
INNER JOIN
    "__mj_BizAppsTasks"."TaskTemplateItem" AS "mjBizAppsTasksTaskTemplateItem_DependsOnItemID"
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

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTaskTemplates" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskTemplates';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTaskTemplates"
AS SELECT
    t.*,
    "mjBizAppsTasksTaskCategory_CategoryID"."Name" AS "Category",
    "mjBizAppsTasksTaskType_TypeID"."Name" AS "Type"
FROM
    "__mj_BizAppsTasks"."TaskTemplate" AS t
LEFT OUTER JOIN
    "__mj_BizAppsTasks"."TaskCategory" AS "mjBizAppsTasksTaskCategory_CategoryID"
  ON
    t."CategoryID" = "mjBizAppsTasksTaskCategory_CategoryID"."ID"
LEFT OUTER JOIN
    "__mj_BizAppsTasks"."TaskType" AS "mjBizAppsTasksTaskType_TypeID"
  ON
    t."TypeID" = "mjBizAppsTasksTaskType_TypeID"."ID"$vsql$;
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

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTaskTemplateItemRoles" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskTemplateItemRoles';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTaskTemplateItemRoles"
AS SELECT
    t.*,
    "mjBizAppsTasksTaskTemplateItem_ItemID"."Name" AS "Item",
    "mjBizAppsTasksTaskRole_RoleID"."Name" AS "Role"
FROM
    "__mj_BizAppsTasks"."TaskTemplateItemRole" AS t
INNER JOIN
    "__mj_BizAppsTasks"."TaskTemplateItem" AS "mjBizAppsTasksTaskTemplateItem_ItemID"
  ON
    t."ItemID" = "mjBizAppsTasksTaskTemplateItem_ItemID"."ID"
INNER JOIN
    "__mj_BizAppsTasks"."TaskRole" AS "mjBizAppsTasksTaskRole_RoleID"
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

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTasks" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTasks';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTasks"
AS SELECT
    t.*,
    "mjBizAppsTasksTaskType_TypeID"."Name" AS "Type",
    "mjBizAppsTasksTaskCategory_CategoryID"."Name" AS "Category",
    "mjBizAppsTasksTask_ParentID"."Name" AS "Parent",
    "mjBizAppsCommonPerson_CreatedByPersonID"."DisplayName" AS "CreatedByPerson",
    "root_ParentID"."RootID" AS "RootParentID"
FROM
    "__mj_BizAppsTasks"."Task" AS t
INNER JOIN
    "__mj_BizAppsTasks"."TaskType" AS "mjBizAppsTasksTaskType_TypeID"
  ON
    t."TypeID" = "mjBizAppsTasksTaskType_TypeID"."ID"
LEFT OUTER JOIN
    "__mj_BizAppsTasks"."TaskCategory" AS "mjBizAppsTasksTaskCategory_CategoryID"
  ON
    t."CategoryID" = "mjBizAppsTasksTaskCategory_CategoryID"."ID"
LEFT OUTER JOIN
    "__mj_BizAppsTasks"."Task" AS "mjBizAppsTasksTask_ParentID"
  ON
    t."ParentID" = "mjBizAppsTasksTask_ParentID"."ID"
LEFT OUTER JOIN
    "${mjSchema}_BizAppsCommon"."Person" AS "mjBizAppsCommonPerson_CreatedByPersonID"
  ON
    t."CreatedByPersonID" = "mjBizAppsCommonPerson_CreatedByPersonID"."ID"
LEFT JOIN LATERAL (SELECT * FROM "__mj_BizAppsTasks"."fnTaskParentID_GetRootID"(t."ID", t."ParentID")) AS "root_ParentID"
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

DROP VIEW IF EXISTS "__mj_BizAppsTasks"."vwTaskTypes" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskTypes';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW "__mj_BizAppsTasks"."vwTaskTypes"
AS SELECT
    t.*,
    "MJAction_OnAssignActionID"."Name" AS "OnAssignAction",
    "MJAction_OnCompleteActionID"."Name" AS "OnCompleteAction",
    "MJAction_OnOverdueActionID"."Name" AS "OnOverdueAction",
    "MJAction_OnPercentChangeActionID"."Name" AS "OnPercentChangeAction"
FROM
    "__mj_BizAppsTasks"."TaskType" AS t
LEFT OUTER JOIN
    "${mjSchema}"."Action" AS "MJAction_OnAssignActionID"
  ON
    t."OnAssignActionID" = "MJAction_OnAssignActionID"."ID"
LEFT OUTER JOIN
    "${mjSchema}"."Action" AS "MJAction_OnCompleteActionID"
  ON
    t."OnCompleteActionID" = "MJAction_OnCompleteActionID"."ID"
LEFT OUTER JOIN
    "${mjSchema}"."Action" AS "MJAction_OnOverdueActionID"
  ON
    t."OnOverdueActionID" = "MJAction_OnOverdueActionID"."ID"
LEFT OUTER JOIN
    "${mjSchema}"."Action" AS "MJAction_OnPercentChangeActionID"
  ON
    t."OnPercentChangeActionID" = "MJAction_OnPercentChangeActionID"."ID"$vsql$;
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
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spCreateTaskCategory"
--     @ID UUID = NULL,
--     @Name VARCHAR(255),
--     @Description_Clear bit = 0,
--     @Description TEXT = NULL,
--     @Parent...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTaskCategory"
--     @ID UUID,
--     @Name VARCHAR(255) = NULL,
--     @Description_Clear bit = 0,
--     @Description TEXT = NULL,
--     @Parent...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTaskCategory"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."TaskCategory"
--     WHERE
--         "ID" = @...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spCreateTaskActivity"
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @PersonID_Clear bit = 0,
--     @PersonID UUID = NULL,
--     @Acti...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTaskActivity"
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @PersonID_Clear bit = 0,
--     @PersonID UUID = NULL,
--     @Acti...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTaskActivity"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."TaskActivity"
--     WHERE
--         "ID" = @...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spCreateTaskComment"
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @ParentID_Clear bit = 0,
--     @ParentID UUID = NULL,
--     @Perso...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTaskComment"
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @ParentID_Clear bit = 0,
--     @ParentID UUID = NULL,
--     @Perso...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTaskComment"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."TaskComment"
--     WHERE
--         "ID" = @ID...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spCreateTaskDependency"
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @DependsOnTaskID UUID,
--     @DependencyType VARCHAR(50) = N...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTaskDependency"
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @DependsOnTaskID UUID = NULL,
--     @DependencyType TEXT(...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTaskDependency"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."TaskDependency"
--     WHERE
--         "ID"...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spCreateTaskAssignment"
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @AssigneeEntityID UUID,
--     @AssigneeRecordID VARCHAR(450)...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTaskAssignment"
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @AssigneeEntityID UUID = NULL,
--     @AssigneeRecordID nvarch...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTaskAssignment"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."TaskAssignment"
--     WHERE
--         "ID"...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spCreateTaskRole"
--     @ID UUID = NULL,
--     @Name VARCHAR(100),
--     @Description_Clear bit = 0,
--     @Description TEXT = NULL,
--     @Sequence i...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTaskRole"
--     @ID UUID,
--     @Name VARCHAR(100) = NULL,
--     @Description_Clear bit = 0,
--     @Description TEXT = NULL,
--     @Sequence i...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTaskRole"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."TaskRole"
--     WHERE
--         "ID" = @ID
-- 
-- 
--    ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spCreateTaskNotificationConfig"
--     @ID UUID = NULL,
--     @TaskTypeID_Clear bit = 0,
--     @TaskTypeID UUID = NULL,
--     @OverdueNotifications...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTaskNotificationConfig"
--     @ID UUID,
--     @TaskTypeID_Clear bit = 0,
--     @TaskTypeID UUID = NULL,
--     @OverdueNotificationsEnabled...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTaskNotificationConfig"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."TaskNotificationConfig"
--     WH...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spCreateTaskNotificationLog"
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @NotificationType VARCHAR(50),
--     @NotifiedUserID uniqueidentifi...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTaskNotificationLog"
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @NotificationType VARCHAR(50) = NULL,
--     @NotifiedUserID uniquei...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTaskNotificationLog"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."TaskNotificationLog"
--     WHERE
--   ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spCreateTaskTagLink"
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @TagID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     DECLARE @Inserted...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTaskTagLink"
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @TagID UUID = NULL
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--    ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTaskTagLink"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."TaskTagLink"
--     WHERE
--         "ID" = @ID...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spCreateTaskLink"
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @EntityID UUID,
--     @RecordID VARCHAR(450),
--     @Description_Cle...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTaskLink"
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @EntityID UUID = NULL,
--     @RecordID VARCHAR(450) = NULL,
--     @D...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTaskLink"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."TaskLink"
--     WHERE
--         "ID" = @ID
-- 
-- 
--    ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spCreateTaskTag"
--     @ID UUID = NULL,
--     @Name VARCHAR(100),
--     @ColorCode_Clear bit = 0,
--     @ColorCode VARCHAR(20) = NULL,
--     @Description_Clea...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTaskTag"
--     @ID UUID,
--     @Name VARCHAR(100) = NULL,
--     @ColorCode_Clear bit = 0,
--     @ColorCode VARCHAR(20) = NULL,
--     @Description_Clea...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTaskTag"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."TaskTag"
--     WHERE
--         "ID" = @ID
-- 
-- 
--     -...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spCreateTaskTemplateItem"
--     @ID UUID = NULL,
--     @TemplateID UUID,
--     @Name VARCHAR(255),
--     @Description_Clear bit = 0,
--     @Descrip...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTaskTemplateItem"
--     @ID UUID,
--     @TemplateID UUID = NULL,
--     @Name VARCHAR(255) = NULL,
--     @Description_Clear bit = 0,
--     @...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTaskTemplateItem"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."TaskTemplateItem"
--     WHERE
--         ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spCreateTaskTemplateItemDependency"
--     @ID UUID = NULL,
--     @ItemID UUID,
--     @DependsOnItemID UUID,
--     @DependencyType nvar...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTaskTemplateItemDependency"
--     @ID UUID,
--     @ItemID UUID = NULL,
--     @DependsOnItemID UUID = NULL,
--     @DependencyTy...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTaskTemplateItemDependency"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."TaskTemplateItemDependency...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks"."spCreateTaskTemplate"
--     @ID UUID = NULL,
--     @Name VARCHAR(255),
--     @Description_Clear bit = 0,
--     @Description TEXT = NULL,
--     @Catego...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTaskTemplate"
--     @ID UUID,
--     @Name VARCHAR(255) = NULL,
--     @Description_Clear bit = 0,
--     @Description TEXT = NULL,
--     @Catego...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTaskTemplate"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."TaskTemplate"
--     WHERE
--         "ID" = @...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spCreateTaskTemplateItemRole"
--     @ID UUID = NULL,
--     @ItemID UUID,
--     @RoleID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     DECLARE...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTaskTemplateItemRole"
--     @ID UUID,
--     @ItemID UUID = NULL,
--     @RoleID UUID = NULL
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTaskTemplateItemRole"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."TaskTemplateItemRole"
--     WHERE
-- ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spCreateTask"
--     @ID UUID = NULL,
--     @Name VARCHAR(255),
--     @Description_Clear bit = 0,
--     @Description TEXT = NULL,
--     @TypeID uniquei...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTask"
--     @ID UUID,
--     @Name VARCHAR(255) = NULL,
--     @Description_Clear bit = 0,
--     @Description TEXT = NULL,
--     @TypeID uniquei...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTask"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."Task"
--     WHERE
--         "ID" = @ID
-- 
-- 
--     -- Chec...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spCreateTaskType"
--     @ID UUID = NULL,
--     @Name VARCHAR(100),
--     @Description_Clear bit = 0,
--     @Description TEXT = NULL,
--     @IconClass_...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spUpdateTaskType"
--     @ID UUID,
--     @Name VARCHAR(100) = NULL,
--     @Description_Clear bit = 0,
--     @Description TEXT = NULL,
--     @IconClass_...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE "__mj_BizAppsTasks"."spDeleteTaskType"
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         "__mj_BizAppsTasks"."TaskType"
--     WHERE
--         "ID" = @ID
-- 
-- 
--    ...


-- ===================== Triggers =====================

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER __mj_BizAppsTasks.trgUpdateTaskCategory
-- ON "__mj_BizAppsTasks"."TaskCategory"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTasks"."TaskCategory"
--     SET
 

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER __mj_BizAppsTasks.trgUpdateTaskActivity
-- ON "__mj_BizAppsTasks"."TaskActivity"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTasks"."TaskActivity"
--     SET
 

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER __mj_BizAppsTasks.trgUpdateTaskComment
-- ON "__mj_BizAppsTasks"."TaskComment"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTasks"."TaskComment"
--     SET
    

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER __mj_BizAppsTasks.trgUpdateTaskDependency
-- ON "__mj_BizAppsTasks"."TaskDependency"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTasks"."TaskDependency"
   

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER __mj_BizAppsTasks.trgUpdateTaskAssignment
-- ON "__mj_BizAppsTasks"."TaskAssignment"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTasks"."TaskAssignment"
   

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER __mj_BizAppsTasks.trgUpdateTaskRole
-- ON "__mj_BizAppsTasks"."TaskRole"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTasks"."TaskRole"
--     SET
--         __mj_

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER __mj_BizAppsTasks.trgUpdateTaskNotificationConfig
-- ON "__mj_BizAppsTasks"."TaskNotificationConfig"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTasks"."Tas

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks".trgUpdateTaskNotificationLog
-- ON "__mj_BizAppsTasks"."TaskNotificationLog"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTasks"."TaskNotif

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks".trgUpdateTaskTagLink
-- ON "__mj_BizAppsTasks"."TaskTagLink"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTasks"."TaskTagLink"
--     SET
    

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER __mj_BizAppsTasks.trgUpdateTaskLink
-- ON "__mj_BizAppsTasks"."TaskLink"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTasks"."TaskLink"
--     SET
--         __mj_

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER __mj_BizAppsTasks.trgUpdateTaskTag
-- ON "__mj_BizAppsTasks"."TaskTag"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTasks"."TaskTag"
--     SET
--         __mj_Upd

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER __mj_BizAppsTasks.trgUpdateTaskTemplateItem
-- ON "__mj_BizAppsTasks"."TaskTemplateItem"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTasks"."TaskTemplateIte

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks".trgUpdateTaskTemplateItemDependency
-- ON "__mj_BizAppsTasks"."TaskTemplateItemDependency"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTas

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks".trgUpdateTaskTemplate
-- ON "__mj_BizAppsTasks"."TaskTemplate"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTasks"."TaskTemplate"
--     SET
 

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER __mj_BizAppsTasks.trgUpdateTaskTemplateItemRole
-- ON "__mj_BizAppsTasks"."TaskTemplateItemRole"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTasks"."TaskTem

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks".trgUpdateTask
-- ON "__mj_BizAppsTasks"."Task"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTasks"."Task"
--     SET
--         __mj_UpdatedAt = 

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER __mj_BizAppsTasks.trgUpdateTaskType
-- ON "__mj_BizAppsTasks"."TaskType"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         "__mj_BizAppsTasks"."TaskType"
--     SET
--         __mj_


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
         '559054c2-8f03-4a66-b4fd-70de5948ace2',
         'MJ_BizApps_Tasks: Task Roles',
         'Task Roles',
         NULL,
         NULL,
         'TaskRole',
         'vwTaskRoles',
         '__mj_BizAppsTasks',
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

/* SQL generated to create new application __mj_BizAppsTasks */

INSERT INTO "${mjSchema}"."Application" ("ID", "Name", "Description", "SchemaAutoAddNewEntities", "Path", "AutoUpdatePath")
                       VALUES ('22541055-8ed4-4850-8acd-e5ee1887b15b', '__mj_BizAppsTasks', 'Generated for schema', '__mj_BizAppsTasks', 'mjbizappstasks', TRUE);

/* Adding role UI to application __mj_BizAppsTasks */

INSERT INTO "${mjSchema}"."ApplicationRole"
                                 ("ApplicationID", "RoleID", "CanAccess", "CanAdmin") VALUES
                                 ('22541055-8ed4-4850-8acd-e5ee1887b15b', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE);

/* Adding role Developer to application __mj_BizAppsTasks */

INSERT INTO "${mjSchema}"."ApplicationRole"
                                 ("ApplicationID", "RoleID", "CanAccess", "CanAdmin") VALUES
                                 ('22541055-8ed4-4850-8acd-e5ee1887b15b', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE);

/* Adding role Integration to application __mj_BizAppsTasks */

INSERT INTO "${mjSchema}"."ApplicationRole"
                                 ("ApplicationID", "RoleID", "CanAccess", "CanAdmin") VALUES
                                 ('22541055-8ed4-4850-8acd-e5ee1887b15b', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE);

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Roles to application ID: '22541055-8ed4-4850-8acd-e5ee1887b15b' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ed4-4850-8acd-e5ee1887b15b', '559054c2-8f03-4a66-b4fd-70de5948ace2', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ed4-4850-8acd-e5ee1887b15b'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Roles for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('559054c2-8f03-4a66-b4fd-70de5948ace2', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Roles for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('559054c2-8f03-4a66-b4fd-70de5948ace2', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Roles for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('559054c2-8f03-4a66-b4fd-70de5948ace2', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Assignments */

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
         'df98e700-1992-442b-b93e-e47379f2ca52',
         'MJ_BizApps_Tasks: Task Assignments',
         'Task Assignments',
         NULL,
         NULL,
         'TaskAssignment',
         'vwTaskAssignments',
         '__mj_BizAppsTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Assignments to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'df98e700-1992-442b-b93e-e47379f2ca52', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Assignments for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('df98e700-1992-442b-b93e-e47379f2ca52', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Assignments for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('df98e700-1992-442b-b93e-e47379f2ca52', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Assignments for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('df98e700-1992-442b-b93e-e47379f2ca52', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Links */

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
         'b92e802c-5c1b-486d-b021-03e47069502c',
         'MJ_BizApps_Tasks: Task Links',
         'Task Links',
         NULL,
         NULL,
         'TaskLink',
         'vwTaskLinks',
         '__mj_BizAppsTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Links to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'b92e802c-5c1b-486d-b021-03e47069502c', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Links for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('b92e802c-5c1b-486d-b021-03e47069502c', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Links for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('b92e802c-5c1b-486d-b021-03e47069502c', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Links for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('b92e802c-5c1b-486d-b021-03e47069502c', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Dependencies */

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
         '0662fc0f-3f2b-49c9-9be8-5b59e036044a',
         'MJ_BizApps_Tasks: Task Dependencies',
         'Task Dependencies',
         NULL,
         NULL,
         'TaskDependency',
         'vwTaskDependencies',
         '__mj_BizAppsTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Dependencies to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '0662fc0f-3f2b-49c9-9be8-5b59e036044a', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Dependencies for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('0662fc0f-3f2b-49c9-9be8-5b59e036044a', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Dependencies for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('0662fc0f-3f2b-49c9-9be8-5b59e036044a', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Dependencies for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('0662fc0f-3f2b-49c9-9be8-5b59e036044a', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Tags */

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
         '5db17493-cd0a-4633-80d4-d4a499662c76',
         'MJ_BizApps_Tasks: Task Tags',
         'Task Tags',
         NULL,
         NULL,
         'TaskTag',
         'vwTaskTags',
         '__mj_BizAppsTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Tags to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '5db17493-cd0a-4633-80d4-d4a499662c76', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Tags for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('5db17493-cd0a-4633-80d4-d4a499662c76', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Tags for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('5db17493-cd0a-4633-80d4-d4a499662c76', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Tags for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('5db17493-cd0a-4633-80d4-d4a499662c76', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Tag Links */

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
         'ea953d6b-524e-4a09-a842-9a0b0f1f850c',
         'MJ_BizApps_Tasks: Task Tag Links',
         'Task Tag Links',
         NULL,
         NULL,
         'TaskTagLink',
         'vwTaskTagLinks',
         '__mj_BizAppsTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Tag Links to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'ea953d6b-524e-4a09-a842-9a0b0f1f850c', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Tag Links for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('ea953d6b-524e-4a09-a842-9a0b0f1f850c', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Tag Links for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('ea953d6b-524e-4a09-a842-9a0b0f1f850c', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Tag Links for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('ea953d6b-524e-4a09-a842-9a0b0f1f850c', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Comments */

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
         'b8b2c72f-44fb-4c6e-9e4f-d42aee1c1865',
         'MJ_BizApps_Tasks: Task Comments',
         'Task Comments',
         NULL,
         NULL,
         'TaskComment',
         'vwTaskComments',
         '__mj_BizAppsTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Comments to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'b8b2c72f-44fb-4c6e-9e4f-d42aee1c1865', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Comments for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('b8b2c72f-44fb-4c6e-9e4f-d42aee1c1865', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Comments for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('b8b2c72f-44fb-4c6e-9e4f-d42aee1c1865', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Comments for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('b8b2c72f-44fb-4c6e-9e4f-d42aee1c1865', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Templates */

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
         '802aef11-bfe2-4b46-98b2-5febd4e35923',
         'MJ_BizApps_Tasks: Task Templates',
         'Task Templates',
         NULL,
         NULL,
         'TaskTemplate',
         'vwTaskTemplates',
         '__mj_BizAppsTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Templates to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '802aef11-bfe2-4b46-98b2-5febd4e35923', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Templates for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('802aef11-bfe2-4b46-98b2-5febd4e35923', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Templates for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('802aef11-bfe2-4b46-98b2-5febd4e35923', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Templates for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('802aef11-bfe2-4b46-98b2-5febd4e35923', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Template Items */

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
         'a28fdd91-d380-427e-b374-bcec56ed75b7',
         'MJ_BizApps_Tasks: Task Template Items',
         'Task Template Items',
         NULL,
         NULL,
         'TaskTemplateItem',
         'vwTaskTemplateItems',
         '__mj_BizAppsTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Template Items to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'a28fdd91-d380-427e-b374-bcec56ed75b7', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Items for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('a28fdd91-d380-427e-b374-bcec56ed75b7', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Items for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('a28fdd91-d380-427e-b374-bcec56ed75b7', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Items for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('a28fdd91-d380-427e-b374-bcec56ed75b7', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Template Item Dependencies */

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
         '8a30f14c-26ff-476e-8ca1-b10ead29a428',
         'MJ_BizApps_Tasks: Task Template Item Dependencies',
         'Task Template Item Dependencies',
         NULL,
         NULL,
         'TaskTemplateItemDependency',
         'vwTaskTemplateItemDependencies',
         '__mj_BizAppsTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Template Item Dependencies to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '8a30f14c-26ff-476e-8ca1-b10ead29a428', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Item Dependencies for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('8a30f14c-26ff-476e-8ca1-b10ead29a428', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Item Dependencies for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('8a30f14c-26ff-476e-8ca1-b10ead29a428', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Item Dependencies for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('8a30f14c-26ff-476e-8ca1-b10ead29a428', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Template Item Roles */

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
         'abfcfe68-f3aa-4401-a547-0fc01f27e3f3',
         'MJ_BizApps_Tasks: Task Template Item Roles',
         'Task Template Item Roles',
         NULL,
         NULL,
         'TaskTemplateItemRole',
         'vwTaskTemplateItemRoles',
         '__mj_BizAppsTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Template Item Roles to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'abfcfe68-f3aa-4401-a547-0fc01f27e3f3', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Item Roles for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('abfcfe68-f3aa-4401-a547-0fc01f27e3f3', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Item Roles for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('abfcfe68-f3aa-4401-a547-0fc01f27e3f3', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Template Item Roles for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('abfcfe68-f3aa-4401-a547-0fc01f27e3f3', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Activities */

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
         '6615ef77-83f1-49f1-b717-80ec31f77486',
         'MJ_BizApps_Tasks: Task Activities',
         'Task Activities',
         NULL,
         NULL,
         'TaskActivity',
         'vwTaskActivities',
         '__mj_BizAppsTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Activities to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '6615ef77-83f1-49f1-b717-80ec31f77486', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Activities for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('6615ef77-83f1-49f1-b717-80ec31f77486', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Activities for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('6615ef77-83f1-49f1-b717-80ec31f77486', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Activities for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('6615ef77-83f1-49f1-b717-80ec31f77486', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Notification Configs */

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
         'a210af26-629a-4e0a-a90a-1cce33f5d095',
         'MJ_BizApps_Tasks: Task Notification Configs',
         'Task Notification Configs',
         NULL,
         NULL,
         'TaskNotificationConfig',
         'vwTaskNotificationConfigs',
         '__mj_BizAppsTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Notification Configs to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'a210af26-629a-4e0a-a90a-1cce33f5d095', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Notification Configs for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('a210af26-629a-4e0a-a90a-1cce33f5d095', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Notification Configs for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('a210af26-629a-4e0a-a90a-1cce33f5d095', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Notification Configs for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('a210af26-629a-4e0a-a90a-1cce33f5d095', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Notification Logs */

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
         'dd0c62ed-7960-4d0a-a1fc-c0e0754de1d4',
         'MJ_BizApps_Tasks: Task Notification Logs',
         'Task Notification Logs',
         NULL,
         NULL,
         'TaskNotificationLog',
         'vwTaskNotificationLogs',
         '__mj_BizAppsTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Notification Logs to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'dd0c62ed-7960-4d0a-a1fc-c0e0754de1d4', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Notification Logs for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('dd0c62ed-7960-4d0a-a1fc-c0e0754de1d4', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Notification Logs for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('dd0c62ed-7960-4d0a-a1fc-c0e0754de1d4', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Notification Logs for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('dd0c62ed-7960-4d0a-a1fc-c0e0754de1d4', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Types */

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
         '1e30141a-826f-4278-baa9-bbe14d29e606',
         'MJ_BizApps_Tasks: Task Types',
         'Task Types',
         NULL,
         NULL,
         'TaskType',
         'vwTaskTypes',
         '__mj_BizAppsTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Types to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '1e30141a-826f-4278-baa9-bbe14d29e606', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Types for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('1e30141a-826f-4278-baa9-bbe14d29e606', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Types for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('1e30141a-826f-4278-baa9-bbe14d29e606', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Types for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('1e30141a-826f-4278-baa9-bbe14d29e606', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Categories */

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
         '06303fa3-48f0-45b7-bc6a-f3ebdfee5cb6',
         'MJ_BizApps_Tasks: Task Categories',
         'Task Categories',
         NULL,
         NULL,
         'TaskCategory',
         'vwTaskCategories',
         '__mj_BizAppsTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Task Categories to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '06303fa3-48f0-45b7-bc6a-f3ebdfee5cb6', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Categories for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('06303fa3-48f0-45b7-bc6a-f3ebdfee5cb6', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Categories for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('06303fa3-48f0-45b7-bc6a-f3ebdfee5cb6', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Categories for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('06303fa3-48f0-45b7-bc6a-f3ebdfee5cb6', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to create new entity MJ_BizApps_Tasks: Tasks */

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
         'b348ffa2-b1a7-4ac2-b6fd-f4e0c0697466',
         'MJ_BizApps_Tasks: Tasks',
         'Tasks',
         NULL,
         NULL,
         'Task',
         'vwTasks',
         '__mj_BizAppsTasks',
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

/* SQL generated to add new entity MJ_BizApps_Tasks: Tasks to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO "${mjSchema}"."ApplicationEntity"
                                       ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                       ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'b348ffa2-b1a7-4ac2-b6fd-f4e0c0697466', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM "${mjSchema}"."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Tasks for role UI */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('b348ffa2-b1a7-4ac2-b6fd-f4e0c0697466', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, FALSE, FALSE, FALSE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Tasks for role Developer */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('b348ffa2-b1a7-4ac2-b6fd-f4e0c0697466', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Tasks for role Integration */

INSERT INTO "${mjSchema}"."EntityPermission"
                                                   ("EntityID", "RoleID", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                                   ('b348ffa2-b1a7-4ac2-b6fd-f4e0c0697466', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', TRUE, TRUE, TRUE, TRUE, NOW(), NOW());

/* SQL text to update existing entities from schema */

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskLink" */
UPDATE "__mj_BizAppsTasks"."TaskLink" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskLink" */
ALTER TABLE "__mj_BizAppsTasks"."TaskLink" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskLink"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskLink" */
UPDATE "__mj_BizAppsTasks"."TaskLink" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskLink" */
ALTER TABLE "__mj_BizAppsTasks"."TaskLink" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskLink"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItemRole" */
UPDATE "__mj_BizAppsTasks"."TaskTemplateItemRole" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItemRole" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItemRole" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItemRole"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItemRole" */
UPDATE "__mj_BizAppsTasks"."TaskTemplateItemRole" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItemRole" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItemRole" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItemRole"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskNotificationConfig" */
UPDATE "__mj_BizAppsTasks"."TaskNotificationConfig" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskNotificationConfig" */
ALTER TABLE "__mj_BizAppsTasks"."TaskNotificationConfig" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskNotificationConfig"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskNotificationConfig" */
UPDATE "__mj_BizAppsTasks"."TaskNotificationConfig" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskNotificationConfig" */
ALTER TABLE "__mj_BizAppsTasks"."TaskNotificationConfig" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskNotificationConfig"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskDependency" */
UPDATE "__mj_BizAppsTasks"."TaskDependency" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskDependency" */
ALTER TABLE "__mj_BizAppsTasks"."TaskDependency" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskDependency"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskDependency" */
UPDATE "__mj_BizAppsTasks"."TaskDependency" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskDependency" */
ALTER TABLE "__mj_BizAppsTasks"."TaskDependency" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskDependency"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTemplate" */
UPDATE "__mj_BizAppsTasks"."TaskTemplate" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTemplate" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTemplate" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskTemplate"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTemplate" */
UPDATE "__mj_BizAppsTasks"."TaskTemplate" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTemplate" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTemplate" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskTemplate"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskRole" */
UPDATE "__mj_BizAppsTasks"."TaskRole" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskRole" */
ALTER TABLE "__mj_BizAppsTasks"."TaskRole" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskRole"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskRole" */
UPDATE "__mj_BizAppsTasks"."TaskRole" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskRole" */
ALTER TABLE "__mj_BizAppsTasks"."TaskRole" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskRole"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskActivity" */
UPDATE "__mj_BizAppsTasks"."TaskActivity" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskActivity" */
ALTER TABLE "__mj_BizAppsTasks"."TaskActivity" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskActivity"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskActivity" */
UPDATE "__mj_BizAppsTasks"."TaskActivity" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskActivity" */
ALTER TABLE "__mj_BizAppsTasks"."TaskActivity" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskActivity"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTagLink" */
UPDATE "__mj_BizAppsTasks"."TaskTagLink" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTagLink" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTagLink" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskTagLink"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTagLink" */
UPDATE "__mj_BizAppsTasks"."TaskTagLink" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTagLink" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTagLink" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskTagLink"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItemDependency" */
UPDATE "__mj_BizAppsTasks"."TaskTemplateItemDependency" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItemDependency" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItemDependency" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItemDependency"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItemDependency" */
UPDATE "__mj_BizAppsTasks"."TaskTemplateItemDependency" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItemDependency" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItemDependency" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItemDependency"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskType" */
UPDATE "__mj_BizAppsTasks"."TaskType" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskType" */
ALTER TABLE "__mj_BizAppsTasks"."TaskType" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskType"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskType" */
UPDATE "__mj_BizAppsTasks"."TaskType" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskType" */
ALTER TABLE "__mj_BizAppsTasks"."TaskType" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskType"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItem" */
UPDATE "__mj_BizAppsTasks"."TaskTemplateItem" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItem" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItem" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItem"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItem" */
UPDATE "__mj_BizAppsTasks"."TaskTemplateItem" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTemplateItem" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItem" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskTemplateItem"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskNotificationLog" */
UPDATE "__mj_BizAppsTasks"."TaskNotificationLog" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskNotificationLog" */
ALTER TABLE "__mj_BizAppsTasks"."TaskNotificationLog" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskNotificationLog"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskNotificationLog" */
UPDATE "__mj_BizAppsTasks"."TaskNotificationLog" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskNotificationLog" */
ALTER TABLE "__mj_BizAppsTasks"."TaskNotificationLog" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskNotificationLog"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskComment" */
UPDATE "__mj_BizAppsTasks"."TaskComment" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskComment" */
ALTER TABLE "__mj_BizAppsTasks"."TaskComment" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskComment"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskComment" */
UPDATE "__mj_BizAppsTasks"."TaskComment" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskComment" */
ALTER TABLE "__mj_BizAppsTasks"."TaskComment" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskComment"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTag" */
UPDATE "__mj_BizAppsTasks"."TaskTag" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskTag" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTag" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskTag"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTag" */
UPDATE "__mj_BizAppsTasks"."TaskTag" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskTag" */
ALTER TABLE "__mj_BizAppsTasks"."TaskTag" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskTag"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskAssignment" */
UPDATE "__mj_BizAppsTasks"."TaskAssignment" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskAssignment" */
ALTER TABLE "__mj_BizAppsTasks"."TaskAssignment" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskAssignment"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskAssignment" */
UPDATE "__mj_BizAppsTasks"."TaskAssignment" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskAssignment" */
ALTER TABLE "__mj_BizAppsTasks"."TaskAssignment" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskAssignment"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskCategory" */
UPDATE "__mj_BizAppsTasks"."TaskCategory" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."TaskCategory" */
ALTER TABLE "__mj_BizAppsTasks"."TaskCategory" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskCategory"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskCategory" */
UPDATE "__mj_BizAppsTasks"."TaskCategory" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."TaskCategory" */
ALTER TABLE "__mj_BizAppsTasks"."TaskCategory" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."TaskCategory"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."Task" */
UPDATE "__mj_BizAppsTasks"."Task" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity "__mj_BizAppsTasks"."Task" */
ALTER TABLE "__mj_BizAppsTasks"."Task" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."Task"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."Task" */
UPDATE "__mj_BizAppsTasks"."Task" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity "__mj_BizAppsTasks"."Task" */
ALTER TABLE "__mj_BizAppsTasks"."Task" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE "__mj_BizAppsTasks"."Task"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '99b41590-910a-448b-ad24-1e0f5585da26' OR ("EntityID" = 'B92E802C-5C1B-486D-B021-03E47069502C' AND "Name" = 'ID')
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
        '99b41590-910a-448b-ad24-1e0f5585da26',
        'B92E802C-5C1B-486D-B021-03E47069502C', -- "Entity": "MJ_BizApps_Tasks": "Task" "Links"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'c6e39edf-d1b0-4571-9a35-22a4d7fd595e' OR ("EntityID" = 'B92E802C-5C1B-486D-B021-03E47069502C' AND "Name" = 'TaskID')
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
        'c6e39edf-d1b0-4571-9a35-22a4d7fd595e',
        'B92E802C-5C1B-486D-B021-03E47069502C', -- "Entity": "MJ_BizApps_Tasks": "Task" "Links"
        100002,
        'TaskID',
        'Task ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '2dee15ab-8820-448f-b3ce-ae79a8b82b6f' OR ("EntityID" = 'B92E802C-5C1B-486D-B021-03E47069502C' AND "Name" = 'EntityID')
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
        '2dee15ab-8820-448f-b3ce-ae79a8b82b6f',
        'B92E802C-5C1B-486D-B021-03E47069502C', -- "Entity": "MJ_BizApps_Tasks": "Task" "Links"
        100003,
        'EntityID',
        'Entity ID',
        NULL,
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
        'E0238F34-2837-EF11-86D4-6045BDEE16E6',
        'ID',
        FALSE,
        FALSE,
        TRUE,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '820857f0-cb09-4ebe-ac47-145b55f61814' OR ("EntityID" = 'B92E802C-5C1B-486D-B021-03E47069502C' AND "Name" = 'RecordID')
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
        '820857f0-cb09-4ebe-ac47-145b55f61814',
        'B92E802C-5C1B-486D-B021-03E47069502C', -- "Entity": "MJ_BizApps_Tasks": "Task" "Links"
        100004,
        'RecordID',
        'Record ID',
        NULL,
        'TEXT',
        900,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '4a24d901-943f-44f6-9476-d86bc1d65c01' OR ("EntityID" = 'B92E802C-5C1B-486D-B021-03E47069502C' AND "Name" = 'Description')
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
        '4a24d901-943f-44f6-9476-d86bc1d65c01',
        'B92E802C-5C1B-486D-B021-03E47069502C', -- "Entity": "MJ_BizApps_Tasks": "Task" "Links"
        100005,
        'Description',
        'Description',
        NULL,
        'TEXT',
        1000,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '07c7da46-0821-4bf1-a3af-007dc980c481' OR ("EntityID" = 'B92E802C-5C1B-486D-B021-03E47069502C' AND "Name" = '__mj_CreatedAt')
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
        '07c7da46-0821-4bf1-a3af-007dc980c481',
        'B92E802C-5C1B-486D-B021-03E47069502C', -- "Entity": "MJ_BizApps_Tasks": "Task" "Links"
        100006,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '98aeae08-c9ec-4136-819a-7919625f4bba' OR ("EntityID" = 'B92E802C-5C1B-486D-B021-03E47069502C' AND "Name" = '__mj_UpdatedAt')
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
        '98aeae08-c9ec-4136-819a-7919625f4bba',
        'B92E802C-5C1B-486D-B021-03E47069502C', -- "Entity": "MJ_BizApps_Tasks": "Task" "Links"
        100007,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '36aa7f8f-44bf-4d37-a1c7-e446d7e95094' OR ("EntityID" = 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3' AND "Name" = 'ID')
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
        '36aa7f8f-44bf-4d37-a1c7-e446d7e95094',
        'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Item" "Roles"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '64a2358a-484a-4c2a-989b-2687daa39fad' OR ("EntityID" = 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3' AND "Name" = 'ItemID')
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
        '64a2358a-484a-4c2a-989b-2687daa39fad',
        'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Item" "Roles"
        100002,
        'ItemID',
        'Item ID',
        NULL,
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
        'A28FDD91-D380-427E-B374-BCEC56ED75B7',
        'ID',
        FALSE,
        FALSE,
        TRUE,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'fc504621-f102-43fa-b6af-820e0fd0c366' OR ("EntityID" = 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3' AND "Name" = 'RoleID')
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
        'fc504621-f102-43fa-b6af-820e0fd0c366',
        'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Item" "Roles"
        100003,
        'RoleID',
        'Role ID',
        NULL,
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
        '559054C2-8F03-4A66-B4FD-70DE5948ACE2',
        'ID',
        FALSE,
        FALSE,
        TRUE,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'accdd736-3097-4d1b-beab-9348e293caee' OR ("EntityID" = 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3' AND "Name" = '__mj_CreatedAt')
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
        'accdd736-3097-4d1b-beab-9348e293caee',
        'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Item" "Roles"
        100004,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '997bf65f-dc1a-43a7-80c1-1dc1548e76dc' OR ("EntityID" = 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3' AND "Name" = '__mj_UpdatedAt')
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
        '997bf65f-dc1a-43a7-80c1-1dc1548e76dc',
        'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Item" "Roles"
        100005,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '9a5d15d2-bf9c-4566-9cb3-127c036a2297' OR ("EntityID" = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND "Name" = 'ID')
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
        '9a5d15d2-bf9c-4566-9cb3-127c036a2297',
        'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Configs"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '3a3dc1ee-3b5d-4ecb-9e63-fb061c37951f' OR ("EntityID" = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND "Name" = 'TaskTypeID')
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
        '3a3dc1ee-3b5d-4ecb-9e63-fb061c37951f',
        'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Configs"
        100002,
        'TaskTypeID',
        'Task Type ID',
        NULL,
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
        '1E30141A-826F-4278-BAA9-BBE14D29E606',
        'ID',
        FALSE,
        FALSE,
        TRUE,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '8e391113-9ab6-47c7-8942-29d0f50feb3b' OR ("EntityID" = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND "Name" = 'OverdueNotificationsEnabled')
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
        '8e391113-9ab6-47c7-8942-29d0f50feb3b',
        'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Configs"
        100003,
        'OverdueNotificationsEnabled',
        'Overdue Notifications Enabled',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'a2b0dc2d-3097-4e98-9aa8-6ebbedbe84c3' OR ("EntityID" = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND "Name" = 'OverdueGracePeriodHours')
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
        'a2b0dc2d-3097-4e98-9aa8-6ebbedbe84c3',
        'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Configs"
        100004,
        'OverdueGracePeriodHours',
        'Overdue Grace Period Hours',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'ac16d98b-855e-44a7-adb3-fbc3dc9e055e' OR ("EntityID" = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND "Name" = 'OverdueRepeatIntervalHours')
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
        'ac16d98b-855e-44a7-adb3-fbc3dc9e055e',
        'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Configs"
        100005,
        'OverdueRepeatIntervalHours',
        'Overdue Repeat Interval Hours',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'a48474ec-3009-4c5b-aee6-e79b58089a2a' OR ("EntityID" = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND "Name" = 'NotifyAssignees')
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
        'a48474ec-3009-4c5b-aee6-e79b58089a2a',
        'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Configs"
        100006,
        'NotifyAssignees',
        'Notify Assignees',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'fc7e46c0-0d22-4c5d-b4c3-261829abd120' OR ("EntityID" = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND "Name" = 'NotifyCreator')
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
        'fc7e46c0-0d22-4c5d-b4c3-261829abd120',
        'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Configs"
        100007,
        'NotifyCreator',
        'Notify Creator',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '62e69520-b969-41da-88e0-58ec3afa0783' OR ("EntityID" = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND "Name" = 'OverdueActionID')
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
        '62e69520-b969-41da-88e0-58ec3afa0783',
        'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Configs"
        100008,
        'OverdueActionID',
        'Overdue Action ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'dd3728e2-e5c6-42a8-92d6-e71fe878dbc0' OR ("EntityID" = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND "Name" = '__mj_CreatedAt')
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
        'dd3728e2-e5c6-42a8-92d6-e71fe878dbc0',
        'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Configs"
        100009,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'bb8f8616-03dc-46f6-adb9-7d9e7be99b16' OR ("EntityID" = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND "Name" = '__mj_UpdatedAt')
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
        'bb8f8616-03dc-46f6-adb9-7d9e7be99b16',
        'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Configs"
        100010,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '6c4a40da-0866-4ca0-9f7d-12ec6064aef1' OR ("EntityID" = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND "Name" = 'ID')
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
        '6c4a40da-0866-4ca0-9f7d-12ec6064aef1',
        '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', -- "Entity": "MJ_BizApps_Tasks": "Task" "Dependencies"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '9ccc0485-5b84-4120-9e9b-4d1a89999973' OR ("EntityID" = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND "Name" = 'TaskID')
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
        '9ccc0485-5b84-4120-9e9b-4d1a89999973',
        '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', -- "Entity": "MJ_BizApps_Tasks": "Task" "Dependencies"
        100002,
        'TaskID',
        'Task ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '0704ad59-838f-49d6-9891-c5930c890258' OR ("EntityID" = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND "Name" = 'DependsOnTaskID')
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
        '0704ad59-838f-49d6-9891-c5930c890258',
        '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', -- "Entity": "MJ_BizApps_Tasks": "Task" "Dependencies"
        100003,
        'DependsOnTaskID',
        'Depends On Task ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '2dd6db6e-82f2-439d-a15f-81bbe36286df' OR ("EntityID" = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND "Name" = 'DependencyType')
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
        '2dd6db6e-82f2-439d-a15f-81bbe36286df',
        '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', -- "Entity": "MJ_BizApps_Tasks": "Task" "Dependencies"
        100004,
        'DependencyType',
        'Dependency Type',
        NULL,
        'TEXT',
        100,
        0,
        0,
        FALSE,
        'FinishToStart',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '0ab7cb59-83f6-4fd4-a8c8-38ecac388bce' OR ("EntityID" = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND "Name" = '__mj_CreatedAt')
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
        '0ab7cb59-83f6-4fd4-a8c8-38ecac388bce',
        '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', -- "Entity": "MJ_BizApps_Tasks": "Task" "Dependencies"
        100005,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '5b121d65-da07-4ea6-a988-31b38d23b528' OR ("EntityID" = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND "Name" = '__mj_UpdatedAt')
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
        '5b121d65-da07-4ea6-a988-31b38d23b528',
        '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', -- "Entity": "MJ_BizApps_Tasks": "Task" "Dependencies"
        100006,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '94fceabf-a622-4502-820a-9e1f1533567d' OR ("EntityID" = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND "Name" = 'ID')
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
        '94fceabf-a622-4502-820a-9e1f1533567d',
        '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- "Entity": "MJ_BizApps_Tasks": "Task" "Templates"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '1b80a51f-be02-411f-b960-63ea442c9172' OR ("EntityID" = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND "Name" = 'Name')
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
        '1b80a51f-be02-411f-b960-63ea442c9172',
        '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- "Entity": "MJ_BizApps_Tasks": "Task" "Templates"
        100002,
        'Name',
        'Name',
        NULL,
        'TEXT',
        510,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '83b87f55-e9e5-4ed9-a561-5cc2a77a22ed' OR ("EntityID" = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND "Name" = 'Description')
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
        '83b87f55-e9e5-4ed9-a561-5cc2a77a22ed',
        '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- "Entity": "MJ_BizApps_Tasks": "Task" "Templates"
        100003,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '9b39d77b-acec-40f7-b933-456760238d14' OR ("EntityID" = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND "Name" = 'CategoryID')
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
        '9b39d77b-acec-40f7-b933-456760238d14',
        '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- "Entity": "MJ_BizApps_Tasks": "Task" "Templates"
        100004,
        'CategoryID',
        'Category ID',
        NULL,
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
        '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'f3908c0c-6c75-4a8d-8c7f-38c9535bffc2' OR ("EntityID" = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND "Name" = 'TypeID')
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
        'f3908c0c-6c75-4a8d-8c7f-38c9535bffc2',
        '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- "Entity": "MJ_BizApps_Tasks": "Task" "Templates"
        100005,
        'TypeID',
        'Type ID',
        NULL,
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
        '1E30141A-826F-4278-BAA9-BBE14D29E606',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'cb57cbf3-7b0e-4887-a963-a8137cde2ecc' OR ("EntityID" = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND "Name" = 'IsActive')
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
        'cb57cbf3-7b0e-4887-a963-a8137cde2ecc',
        '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- "Entity": "MJ_BizApps_Tasks": "Task" "Templates"
        100006,
        'IsActive',
        'Is Active',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'f8ec6d02-e1c2-433f-a96d-9095eaac35c3' OR ("EntityID" = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND "Name" = '__mj_CreatedAt')
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
        'f8ec6d02-e1c2-433f-a96d-9095eaac35c3',
        '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- "Entity": "MJ_BizApps_Tasks": "Task" "Templates"
        100007,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'a772e9ac-7673-49f4-99cd-38d4a5b14f30' OR ("EntityID" = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND "Name" = '__mj_UpdatedAt')
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
        'a772e9ac-7673-49f4-99cd-38d4a5b14f30',
        '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- "Entity": "MJ_BizApps_Tasks": "Task" "Templates"
        100008,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '39289af3-6bb0-4697-981b-8f39c47feed1' OR ("EntityID" = '559054C2-8F03-4A66-B4FD-70DE5948ACE2' AND "Name" = 'ID')
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
        '39289af3-6bb0-4697-981b-8f39c47feed1',
        '559054C2-8F03-4A66-B4FD-70DE5948ACE2', -- "Entity": "MJ_BizApps_Tasks": "Task" "Roles"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '23a93766-7d80-4b7c-bc0b-ef716e8e97aa' OR ("EntityID" = '559054C2-8F03-4A66-B4FD-70DE5948ACE2' AND "Name" = 'Name')
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
        '23a93766-7d80-4b7c-bc0b-ef716e8e97aa',
        '559054C2-8F03-4A66-B4FD-70DE5948ACE2', -- "Entity": "MJ_BizApps_Tasks": "Task" "Roles"
        100002,
        'Name',
        'Name',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '604eaaa7-7911-48d9-8ac4-079affa9f901' OR ("EntityID" = '559054C2-8F03-4A66-B4FD-70DE5948ACE2' AND "Name" = 'Description')
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
        '604eaaa7-7911-48d9-8ac4-079affa9f901',
        '559054C2-8F03-4A66-B4FD-70DE5948ACE2', -- "Entity": "MJ_BizApps_Tasks": "Task" "Roles"
        100003,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '896f23e5-bd84-4cd9-86ae-cf527c34e772' OR ("EntityID" = '559054C2-8F03-4A66-B4FD-70DE5948ACE2' AND "Name" = 'Sequence')
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
        '896f23e5-bd84-4cd9-86ae-cf527c34e772',
        '559054C2-8F03-4A66-B4FD-70DE5948ACE2', -- "Entity": "MJ_BizApps_Tasks": "Task" "Roles"
        100004,
        'Sequence',
        'Sequence',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'f5cbafd5-b5a2-4bc5-9f6a-a932d86a75fb' OR ("EntityID" = '559054C2-8F03-4A66-B4FD-70DE5948ACE2' AND "Name" = '__mj_CreatedAt')
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
        'f5cbafd5-b5a2-4bc5-9f6a-a932d86a75fb',
        '559054C2-8F03-4A66-B4FD-70DE5948ACE2', -- "Entity": "MJ_BizApps_Tasks": "Task" "Roles"
        100005,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '45ab032f-dbe5-4191-9635-f20bf7d9c7ef' OR ("EntityID" = '559054C2-8F03-4A66-B4FD-70DE5948ACE2' AND "Name" = '__mj_UpdatedAt')
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
        '45ab032f-dbe5-4191-9635-f20bf7d9c7ef',
        '559054C2-8F03-4A66-B4FD-70DE5948ACE2', -- "Entity": "MJ_BizApps_Tasks": "Task" "Roles"
        100006,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'e5f115d0-a541-463b-87d1-224fb396e4cf' OR ("EntityID" = '6615EF77-83F1-49F1-B717-80EC31F77486' AND "Name" = 'ID')
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
        'e5f115d0-a541-463b-87d1-224fb396e4cf',
        '6615EF77-83F1-49F1-B717-80EC31F77486', -- "Entity": "MJ_BizApps_Tasks": "Task" "Activities"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '4e49c2fd-9527-484d-97ed-2afe4ee0e3e6' OR ("EntityID" = '6615EF77-83F1-49F1-B717-80EC31F77486' AND "Name" = 'TaskID')
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
        '4e49c2fd-9527-484d-97ed-2afe4ee0e3e6',
        '6615EF77-83F1-49F1-B717-80EC31F77486', -- "Entity": "MJ_BizApps_Tasks": "Task" "Activities"
        100002,
        'TaskID',
        'Task ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'c885176b-bccd-4d0a-bdfc-b624394404b4' OR ("EntityID" = '6615EF77-83F1-49F1-B717-80EC31F77486' AND "Name" = 'PersonID')
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
        'c885176b-bccd-4d0a-bdfc-b624394404b4',
        '6615EF77-83F1-49F1-B717-80EC31F77486', -- "Entity": "MJ_BizApps_Tasks": "Task" "Activities"
        100003,
        'PersonID',
        'Person ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '7b955fc4-a91e-4cc7-8768-e6945a895df9' OR ("EntityID" = '6615EF77-83F1-49F1-B717-80EC31F77486' AND "Name" = 'ActivityType')
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
        '7b955fc4-a91e-4cc7-8768-e6945a895df9',
        '6615EF77-83F1-49F1-B717-80EC31F77486', -- "Entity": "MJ_BizApps_Tasks": "Task" "Activities"
        100004,
        'ActivityType',
        'Activity Type',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '58a3f43c-3f2c-48ee-867a-8ef9f243bb63' OR ("EntityID" = '6615EF77-83F1-49F1-B717-80EC31F77486' AND "Name" = 'PreviousValue')
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
        '58a3f43c-3f2c-48ee-867a-8ef9f243bb63',
        '6615EF77-83F1-49F1-B717-80EC31F77486', -- "Entity": "MJ_BizApps_Tasks": "Task" "Activities"
        100005,
        'PreviousValue',
        'Previous Value',
        NULL,
        'TEXT',
        1000,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'ee81848c-d188-4c1d-95cc-3b618fabf1ec' OR ("EntityID" = '6615EF77-83F1-49F1-B717-80EC31F77486' AND "Name" = 'NewValue')
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
        'ee81848c-d188-4c1d-95cc-3b618fabf1ec',
        '6615EF77-83F1-49F1-B717-80EC31F77486', -- "Entity": "MJ_BizApps_Tasks": "Task" "Activities"
        100006,
        'NewValue',
        'New Value',
        NULL,
        'TEXT',
        1000,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '8d1c4682-5e91-4512-9f3c-e6e87ef6f303' OR ("EntityID" = '6615EF77-83F1-49F1-B717-80EC31F77486' AND "Name" = 'Description')
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
        '8d1c4682-5e91-4512-9f3c-e6e87ef6f303',
        '6615EF77-83F1-49F1-B717-80EC31F77486', -- "Entity": "MJ_BizApps_Tasks": "Task" "Activities"
        100007,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'a9f7291b-c6b9-4832-8cad-154a7fc34071' OR ("EntityID" = '6615EF77-83F1-49F1-B717-80EC31F77486' AND "Name" = '__mj_CreatedAt')
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
        'a9f7291b-c6b9-4832-8cad-154a7fc34071',
        '6615EF77-83F1-49F1-B717-80EC31F77486', -- "Entity": "MJ_BizApps_Tasks": "Task" "Activities"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'e8f50401-7746-40c1-a4f9-2d21e486d611' OR ("EntityID" = '6615EF77-83F1-49F1-B717-80EC31F77486' AND "Name" = '__mj_UpdatedAt')
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
        'e8f50401-7746-40c1-a4f9-2d21e486d611',
        '6615EF77-83F1-49F1-B717-80EC31F77486', -- "Entity": "MJ_BizApps_Tasks": "Task" "Activities"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'b0210863-91b0-4b0b-a277-f5b2f85fac80' OR ("EntityID" = 'EA953D6B-524E-4A09-A842-9A0B0F1F850C' AND "Name" = 'ID')
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
        'b0210863-91b0-4b0b-a277-f5b2f85fac80',
        'EA953D6B-524E-4A09-A842-9A0B0F1F850C', -- "Entity": "MJ_BizApps_Tasks": "Task" "Tag" "Links"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '34a075ff-ea19-4045-89bb-8fe767ecdbf6' OR ("EntityID" = 'EA953D6B-524E-4A09-A842-9A0B0F1F850C' AND "Name" = 'TaskID')
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
        '34a075ff-ea19-4045-89bb-8fe767ecdbf6',
        'EA953D6B-524E-4A09-A842-9A0B0F1F850C', -- "Entity": "MJ_BizApps_Tasks": "Task" "Tag" "Links"
        100002,
        'TaskID',
        'Task ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'e2740c12-01c0-4f86-ada4-f0cea1180dac' OR ("EntityID" = 'EA953D6B-524E-4A09-A842-9A0B0F1F850C' AND "Name" = 'TagID')
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
        'e2740c12-01c0-4f86-ada4-f0cea1180dac',
        'EA953D6B-524E-4A09-A842-9A0B0F1F850C', -- "Entity": "MJ_BizApps_Tasks": "Task" "Tag" "Links"
        100003,
        'TagID',
        'Tag ID',
        NULL,
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
        '5DB17493-CD0A-4633-80D4-D4A499662C76',
        'ID',
        FALSE,
        FALSE,
        TRUE,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '7f95d5bb-dd93-4ce0-aed7-efc073c716e0' OR ("EntityID" = 'EA953D6B-524E-4A09-A842-9A0B0F1F850C' AND "Name" = '__mj_CreatedAt')
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
        '7f95d5bb-dd93-4ce0-aed7-efc073c716e0',
        'EA953D6B-524E-4A09-A842-9A0B0F1F850C', -- "Entity": "MJ_BizApps_Tasks": "Task" "Tag" "Links"
        100004,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '0a81c770-5ca1-43f2-8db0-285000a6ea96' OR ("EntityID" = 'EA953D6B-524E-4A09-A842-9A0B0F1F850C' AND "Name" = '__mj_UpdatedAt')
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
        '0a81c770-5ca1-43f2-8db0-285000a6ea96',
        'EA953D6B-524E-4A09-A842-9A0B0F1F850C', -- "Entity": "MJ_BizApps_Tasks": "Task" "Tag" "Links"
        100005,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '6fac4bfe-77ae-4f46-902b-467acffdc4f5' OR ("EntityID" = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND "Name" = 'ID')
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
        '6fac4bfe-77ae-4f46-902b-467acffdc4f5',
        '8A30F14C-26FF-476E-8CA1-B10EAD29A428', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Item" "Dependencies"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '910121c9-19bf-4a58-b76a-491cce751333' OR ("EntityID" = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND "Name" = 'ItemID')
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
        '910121c9-19bf-4a58-b76a-491cce751333',
        '8A30F14C-26FF-476E-8CA1-B10EAD29A428', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Item" "Dependencies"
        100002,
        'ItemID',
        'Item ID',
        NULL,
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
        'A28FDD91-D380-427E-B374-BCEC56ED75B7',
        'ID',
        FALSE,
        FALSE,
        TRUE,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'f3ec22f4-d9cd-4c05-a31d-84efdc3d30de' OR ("EntityID" = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND "Name" = 'DependsOnItemID')
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
        'f3ec22f4-d9cd-4c05-a31d-84efdc3d30de',
        '8A30F14C-26FF-476E-8CA1-B10EAD29A428', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Item" "Dependencies"
        100003,
        'DependsOnItemID',
        'Depends On Item ID',
        NULL,
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
        'A28FDD91-D380-427E-B374-BCEC56ED75B7',
        'ID',
        FALSE,
        FALSE,
        TRUE,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '659f9a5c-bd9c-4ef7-88be-b731541d2345' OR ("EntityID" = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND "Name" = 'DependencyType')
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
        '659f9a5c-bd9c-4ef7-88be-b731541d2345',
        '8A30F14C-26FF-476E-8CA1-B10EAD29A428', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Item" "Dependencies"
        100004,
        'DependencyType',
        'Dependency Type',
        NULL,
        'TEXT',
        100,
        0,
        0,
        FALSE,
        'FinishToStart',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '0e9937e4-7665-409f-bdb1-9d048f24f518' OR ("EntityID" = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND "Name" = '__mj_CreatedAt')
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
        '0e9937e4-7665-409f-bdb1-9d048f24f518',
        '8A30F14C-26FF-476E-8CA1-B10EAD29A428', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Item" "Dependencies"
        100005,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '9eea87de-003e-4834-ae9b-07f26f79d8a8' OR ("EntityID" = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND "Name" = '__mj_UpdatedAt')
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
        '9eea87de-003e-4834-ae9b-07f26f79d8a8',
        '8A30F14C-26FF-476E-8CA1-B10EAD29A428', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Item" "Dependencies"
        100006,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'b5d4a231-3f9f-45f8-b1e5-3b0fccabfe8b' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'ID')
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
        'b5d4a231-3f9f-45f8-b1e5-3b0fccabfe8b',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '00619351-6557-42b0-b412-1fc4283cb682' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'Name')
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
        '00619351-6557-42b0-b412-1fc4283cb682',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100002,
        'Name',
        'Name',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '231b2378-3454-4a1e-a002-412fd7c8ad75' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'Description')
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
        '231b2378-3454-4a1e-a002-412fd7c8ad75',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100003,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '756bd750-22b9-40af-b38a-c59a7b93fffe' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'IconClass')
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
        '756bd750-22b9-40af-b38a-c59a7b93fffe',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100004,
        'IconClass',
        'Icon Class',
        NULL,
        'TEXT',
        200,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '55d2a288-00c8-425f-8e69-06bced11d706' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'DefaultPriority')
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
        '55d2a288-00c8-425f-8e69-06bced11d706',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100005,
        'DefaultPriority',
        'Default Priority',
        NULL,
        'TEXT',
        40,
        0,
        0,
        FALSE,
        'Medium',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '2352e1f5-18ca-4495-85da-516fefc20463' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'OnAssignActionID')
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
        '2352e1f5-18ca-4495-85da-516fefc20463',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100006,
        'OnAssignActionID',
        'On Assign Action ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '31f3f7cc-c0d0-4dd9-84f1-255bdb54dfae' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'OnCompleteActionID')
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
        '31f3f7cc-c0d0-4dd9-84f1-255bdb54dfae',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100007,
        'OnCompleteActionID',
        'On Complete Action ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '86e954fa-9304-49f6-ad53-7ea09875fd87' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'OnOverdueActionID')
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
        '86e954fa-9304-49f6-ad53-7ea09875fd87',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100008,
        'OnOverdueActionID',
        'On Overdue Action ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'd6d015d3-c9d9-4eac-b17c-4ead902b6322' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'OnPercentChangeActionID')
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
        'd6d015d3-c9d9-4eac-b17c-4ead902b6322',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100009,
        'OnPercentChangeActionID',
        'On Percent Change Action ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '4383f518-7ae7-4c9e-b105-d9090fc545f1' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'IsActive')
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
        '4383f518-7ae7-4c9e-b105-d9090fc545f1',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100010,
        'IsActive',
        'Is Active',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '3b6a900c-646f-4a98-8f4b-bc7ae54a9c7a' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = '__mj_CreatedAt')
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
        '3b6a900c-646f-4a98-8f4b-bc7ae54a9c7a',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100011,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'a4cc3d1e-96ac-4ec7-98cf-f83862215617' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = '__mj_UpdatedAt')
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
        'a4cc3d1e-96ac-4ec7-98cf-f83862215617',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100012,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '45ca153f-265a-4ac1-82f3-2ee0f76a0c91' OR ("EntityID" = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND "Name" = 'ID')
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
        '45ca153f-265a-4ac1-82f3-2ee0f76a0c91',
        'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Items"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '2e782cec-cbdf-4ff0-ad79-254e2e2a6c62' OR ("EntityID" = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND "Name" = 'TemplateID')
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
        '2e782cec-cbdf-4ff0-ad79-254e2e2a6c62',
        'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Items"
        100002,
        'TemplateID',
        'Template ID',
        NULL,
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
        '802AEF11-BFE2-4B46-98B2-5FEBD4E35923',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'e0060603-e9ff-4829-a4a8-a9b2abdb6bfa' OR ("EntityID" = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND "Name" = 'Name')
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
        'e0060603-e9ff-4829-a4a8-a9b2abdb6bfa',
        'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Items"
        100003,
        'Name',
        'Name',
        NULL,
        'TEXT',
        510,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'fbcdc553-91ed-4844-b062-192358d1acd2' OR ("EntityID" = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND "Name" = 'Description')
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
        'fbcdc553-91ed-4844-b062-192358d1acd2',
        'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Items"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '97d8e900-6af3-4a75-92da-1eaa66984aae' OR ("EntityID" = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND "Name" = 'ParentItemID')
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
        '97d8e900-6af3-4a75-92da-1eaa66984aae',
        'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Items"
        100005,
        'ParentItemID',
        'Parent Item ID',
        NULL,
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
        'A28FDD91-D380-427E-B374-BCEC56ED75B7',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '69c1abe5-3db5-4f9c-a55a-6381d46c1cd4' OR ("EntityID" = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND "Name" = 'Priority')
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
        '69c1abe5-3db5-4f9c-a55a-6381d46c1cd4',
        'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Items"
        100006,
        'Priority',
        'Priority',
        NULL,
        'TEXT',
        40,
        0,
        0,
        FALSE,
        'Medium',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '7d855b57-90ec-47e2-85c7-0ef700036905' OR ("EntityID" = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND "Name" = 'DaysFromStart')
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
        '7d855b57-90ec-47e2-85c7-0ef700036905',
        'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Items"
        100007,
        'DaysFromStart',
        'Days From Start',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'c666f314-2fe0-4c7e-8cf0-33ff278cedf8' OR ("EntityID" = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND "Name" = 'HoursEstimated')
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
        'c666f314-2fe0-4c7e-8cf0-33ff278cedf8',
        'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Items"
        100008,
        'HoursEstimated',
        'Hours Estimated',
        NULL,
        'decimal',
        5,
        8,
        2,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'ee42dc30-d767-46e2-9921-db1c2b423734' OR ("EntityID" = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND "Name" = 'Sequence')
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
        'ee42dc30-d767-46e2-9921-db1c2b423734',
        'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Items"
        100009,
        'Sequence',
        'Sequence',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'fb020b7b-8d60-47e2-8324-240939f0c6bb' OR ("EntityID" = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND "Name" = '__mj_CreatedAt')
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
        'fb020b7b-8d60-47e2-8324-240939f0c6bb',
        'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Items"
        100010,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '5557c90b-7a7d-4fa6-910d-001917ed428c' OR ("EntityID" = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND "Name" = '__mj_UpdatedAt')
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
        '5557c90b-7a7d-4fa6-910d-001917ed428c',
        'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Items"
        100011,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'e59d0690-163e-433c-b408-df6ae4ec4747' OR ("EntityID" = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND "Name" = 'ID')
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
        'e59d0690-163e-433c-b408-df6ae4ec4747',
        'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Logs"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'e1e634a8-e437-4cf7-9c01-9272a0fd5c35' OR ("EntityID" = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND "Name" = 'TaskID')
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
        'e1e634a8-e437-4cf7-9c01-9272a0fd5c35',
        'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Logs"
        100002,
        'TaskID',
        'Task ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '9f629abd-ec18-4fa9-9bde-c8e47938903c' OR ("EntityID" = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND "Name" = 'NotificationType')
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
        '9f629abd-ec18-4fa9-9bde-c8e47938903c',
        'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Logs"
        100003,
        'NotificationType',
        'Notification Type',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '66bd853f-28ca-4592-8409-c114efb477a2' OR ("EntityID" = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND "Name" = 'NotifiedUserID')
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
        '66bd853f-28ca-4592-8409-c114efb477a2',
        'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Logs"
        100004,
        'NotifiedUserID',
        'Notified User ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'bc607c2b-d677-41b8-b2ce-4c515e49adc0' OR ("EntityID" = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND "Name" = 'NotifiedAt')
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
        'bc607c2b-d677-41b8-b2ce-4c515e49adc0',
        'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Logs"
        100005,
        'NotifiedAt',
        'Notified At',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '7ae19b3a-b0bd-4642-89bd-f1218ce0a962' OR ("EntityID" = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND "Name" = '__mj_CreatedAt')
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
        '7ae19b3a-b0bd-4642-89bd-f1218ce0a962',
        'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Logs"
        100006,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '202fc839-4893-468d-ae6b-faab8192c75c' OR ("EntityID" = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND "Name" = '__mj_UpdatedAt')
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
        '202fc839-4893-468d-ae6b-faab8192c75c',
        'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Logs"
        100007,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '1d9ba99a-0cb9-4a1b-a1a9-3d4de2324cde' OR ("EntityID" = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND "Name" = 'ID')
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
        '1d9ba99a-0cb9-4a1b-a1a9-3d4de2324cde',
        'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- "Entity": "MJ_BizApps_Tasks": "Task" "Comments"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '1b0590eb-d333-46e2-ba4c-2328430fd472' OR ("EntityID" = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND "Name" = 'TaskID')
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
        '1b0590eb-d333-46e2-ba4c-2328430fd472',
        'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- "Entity": "MJ_BizApps_Tasks": "Task" "Comments"
        100002,
        'TaskID',
        'Task ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '926de279-27ff-43d5-9f02-cb5c8cb25ed5' OR ("EntityID" = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND "Name" = 'ParentID')
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
        '926de279-27ff-43d5-9f02-cb5c8cb25ed5',
        'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- "Entity": "MJ_BizApps_Tasks": "Task" "Comments"
        100003,
        'ParentID',
        'Parent ID',
        NULL,
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
        'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'bff49ce0-1e51-4f11-9d1d-cb1c1d014ad5' OR ("EntityID" = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND "Name" = 'PersonID')
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
        'bff49ce0-1e51-4f11-9d1d-cb1c1d014ad5',
        'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- "Entity": "MJ_BizApps_Tasks": "Task" "Comments"
        100004,
        'PersonID',
        'Person ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '8e9c502b-d745-47f1-98aa-ad6ffe691d65' OR ("EntityID" = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND "Name" = 'Content')
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
        '8e9c502b-d745-47f1-98aa-ad6ffe691d65',
        'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- "Entity": "MJ_BizApps_Tasks": "Task" "Comments"
        100005,
        'Content',
        'Content',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '92aee8dc-ed9d-4785-a6e1-c5d98884ed67' OR ("EntityID" = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND "Name" = 'IsEdited')
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
        '92aee8dc-ed9d-4785-a6e1-c5d98884ed67',
        'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- "Entity": "MJ_BizApps_Tasks": "Task" "Comments"
        100006,
        'IsEdited',
        'Is Edited',
        NULL,
        'BOOLEAN',
        1,
        1,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '2436ad22-ecce-48c0-87a7-f6f7f16fd12b' OR ("EntityID" = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND "Name" = '__mj_CreatedAt')
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
        '2436ad22-ecce-48c0-87a7-f6f7f16fd12b',
        'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- "Entity": "MJ_BizApps_Tasks": "Task" "Comments"
        100007,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'fdb6e33e-431f-4097-9119-657eaca7fe5b' OR ("EntityID" = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND "Name" = '__mj_UpdatedAt')
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
        'fdb6e33e-431f-4097-9119-657eaca7fe5b',
        'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- "Entity": "MJ_BizApps_Tasks": "Task" "Comments"
        100008,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '133050ee-20cf-45b3-a567-2aa95c0019f2' OR ("EntityID" = '5DB17493-CD0A-4633-80D4-D4A499662C76' AND "Name" = 'ID')
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
        '133050ee-20cf-45b3-a567-2aa95c0019f2',
        '5DB17493-CD0A-4633-80D4-D4A499662C76', -- "Entity": "MJ_BizApps_Tasks": "Task" "Tags"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'c7699d28-7075-435b-8a6f-1912b09a3469' OR ("EntityID" = '5DB17493-CD0A-4633-80D4-D4A499662C76' AND "Name" = 'Name')
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
        'c7699d28-7075-435b-8a6f-1912b09a3469',
        '5DB17493-CD0A-4633-80D4-D4A499662C76', -- "Entity": "MJ_BizApps_Tasks": "Task" "Tags"
        100002,
        'Name',
        'Name',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '3ea0a461-dd7e-43b9-9349-702376f83663' OR ("EntityID" = '5DB17493-CD0A-4633-80D4-D4A499662C76' AND "Name" = 'ColorCode')
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
        '3ea0a461-dd7e-43b9-9349-702376f83663',
        '5DB17493-CD0A-4633-80D4-D4A499662C76', -- "Entity": "MJ_BizApps_Tasks": "Task" "Tags"
        100003,
        'ColorCode',
        'Color Code',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '73221c4b-0f32-4bb2-a075-6637905a8fab' OR ("EntityID" = '5DB17493-CD0A-4633-80D4-D4A499662C76' AND "Name" = 'Description')
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
        '73221c4b-0f32-4bb2-a075-6637905a8fab',
        '5DB17493-CD0A-4633-80D4-D4A499662C76', -- "Entity": "MJ_BizApps_Tasks": "Task" "Tags"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'f34358ef-69fa-43a8-b8df-dd57791fc52c' OR ("EntityID" = '5DB17493-CD0A-4633-80D4-D4A499662C76' AND "Name" = '__mj_CreatedAt')
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
        'f34358ef-69fa-43a8-b8df-dd57791fc52c',
        '5DB17493-CD0A-4633-80D4-D4A499662C76', -- "Entity": "MJ_BizApps_Tasks": "Task" "Tags"
        100005,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'e4a5d9df-1767-4c10-bd52-04b8a4c8bce2' OR ("EntityID" = '5DB17493-CD0A-4633-80D4-D4A499662C76' AND "Name" = '__mj_UpdatedAt')
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
        'e4a5d9df-1767-4c10-bd52-04b8a4c8bce2',
        '5DB17493-CD0A-4633-80D4-D4A499662C76', -- "Entity": "MJ_BizApps_Tasks": "Task" "Tags"
        100006,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '7ffa1073-b7a2-46df-a943-d10da3673c9b' OR ("EntityID" = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND "Name" = 'ID')
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
        '7ffa1073-b7a2-46df-a943-d10da3673c9b',
        'DF98E700-1992-442B-B93E-E47379F2CA52', -- "Entity": "MJ_BizApps_Tasks": "Task" "Assignments"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '8d982a22-f541-479b-ad71-e30667f21e32' OR ("EntityID" = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND "Name" = 'TaskID')
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
        '8d982a22-f541-479b-ad71-e30667f21e32',
        'DF98E700-1992-442B-B93E-E47379F2CA52', -- "Entity": "MJ_BizApps_Tasks": "Task" "Assignments"
        100002,
        'TaskID',
        'Task ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '01494276-140c-474d-a810-56c05f06b47e' OR ("EntityID" = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND "Name" = 'AssigneeEntityID')
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
        '01494276-140c-474d-a810-56c05f06b47e',
        'DF98E700-1992-442B-B93E-E47379F2CA52', -- "Entity": "MJ_BizApps_Tasks": "Task" "Assignments"
        100003,
        'AssigneeEntityID',
        'Assignee Entity ID',
        NULL,
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
        'E0238F34-2837-EF11-86D4-6045BDEE16E6',
        'ID',
        FALSE,
        FALSE,
        TRUE,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'a88cb22d-56cf-4506-9ac0-22dd89c7481c' OR ("EntityID" = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND "Name" = 'AssigneeRecordID')
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
        'a88cb22d-56cf-4506-9ac0-22dd89c7481c',
        'DF98E700-1992-442B-B93E-E47379F2CA52', -- "Entity": "MJ_BizApps_Tasks": "Task" "Assignments"
        100004,
        'AssigneeRecordID',
        'Assignee Record ID',
        NULL,
        'TEXT',
        900,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '0b8e91bf-8429-46c3-acae-d930b6c032e8' OR ("EntityID" = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND "Name" = 'RoleID')
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
        '0b8e91bf-8429-46c3-acae-d930b6c032e8',
        'DF98E700-1992-442B-B93E-E47379F2CA52', -- "Entity": "MJ_BizApps_Tasks": "Task" "Assignments"
        100005,
        'RoleID',
        'Role ID',
        NULL,
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
        '559054C2-8F03-4A66-B4FD-70DE5948ACE2',
        'ID',
        FALSE,
        FALSE,
        TRUE,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '79f7ae2e-7760-467f-9147-02edfcd730ca' OR ("EntityID" = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND "Name" = 'RoleNotes')
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
        '79f7ae2e-7760-467f-9147-02edfcd730ca',
        'DF98E700-1992-442B-B93E-E47379F2CA52', -- "Entity": "MJ_BizApps_Tasks": "Task" "Assignments"
        100006,
        'RoleNotes',
        'Role Notes',
        NULL,
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

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '4e823e84-05b4-43b4-a651-693798d589a8' OR ("EntityID" = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND "Name" = 'Status')
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
        '4e823e84-05b4-43b4-a651-693798d589a8',
        'DF98E700-1992-442B-B93E-E47379F2CA52', -- "Entity": "MJ_BizApps_Tasks": "Task" "Assignments"
        100007,
        'Status',
        'Status',
        NULL,
        'TEXT',
        100,
        0,
        0,
        FALSE,
        'Pending',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'd472964e-4aaf-44e6-a01a-e2a92aaa44da' OR ("EntityID" = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND "Name" = 'AssignedByPersonID')
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
        'd472964e-4aaf-44e6-a01a-e2a92aaa44da',
        'DF98E700-1992-442B-B93E-E47379F2CA52', -- "Entity": "MJ_BizApps_Tasks": "Task" "Assignments"
        100008,
        'AssignedByPersonID',
        'Assigned By Person ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '5b7c8acc-6fd6-4f9b-84b6-f76fdc4d90fc' OR ("EntityID" = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND "Name" = 'AssignedAt')
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
        '5b7c8acc-6fd6-4f9b-84b6-f76fdc4d90fc',
        'DF98E700-1992-442B-B93E-E47379F2CA52', -- "Entity": "MJ_BizApps_Tasks": "Task" "Assignments"
        100009,
        'AssignedAt',
        'Assigned At',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '27f4d591-4acd-4bfe-9ab4-c372cb0533ea' OR ("EntityID" = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND "Name" = '__mj_CreatedAt')
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
        '27f4d591-4acd-4bfe-9ab4-c372cb0533ea',
        'DF98E700-1992-442B-B93E-E47379F2CA52', -- "Entity": "MJ_BizApps_Tasks": "Task" "Assignments"
        100010,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '2f422608-152f-4983-83a5-3fd9fe5ce6fb' OR ("EntityID" = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND "Name" = '__mj_UpdatedAt')
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
        '2f422608-152f-4983-83a5-3fd9fe5ce6fb',
        'DF98E700-1992-442B-B93E-E47379F2CA52', -- "Entity": "MJ_BizApps_Tasks": "Task" "Assignments"
        100011,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'c2856d8e-31d8-4f13-a94a-2254c7427c69' OR ("EntityID" = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND "Name" = 'ID')
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
        'c2856d8e-31d8-4f13-a94a-2254c7427c69',
        '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- "Entity": "MJ_BizApps_Tasks": "Task" "Categories"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '5965f6a3-f788-40df-b248-b02a5834db01' OR ("EntityID" = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND "Name" = 'Name')
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
        '5965f6a3-f788-40df-b248-b02a5834db01',
        '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- "Entity": "MJ_BizApps_Tasks": "Task" "Categories"
        100002,
        'Name',
        'Name',
        NULL,
        'TEXT',
        510,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '7b6a7e70-677d-4e51-a845-d70bca699dc2' OR ("EntityID" = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND "Name" = 'Description')
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
        '7b6a7e70-677d-4e51-a845-d70bca699dc2',
        '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- "Entity": "MJ_BizApps_Tasks": "Task" "Categories"
        100003,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '4da0eec6-3dc7-404c-9694-a65e1b58093c' OR ("EntityID" = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND "Name" = 'ParentID')
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
        '4da0eec6-3dc7-404c-9694-a65e1b58093c',
        '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- "Entity": "MJ_BizApps_Tasks": "Task" "Categories"
        100004,
        'ParentID',
        'Parent ID',
        NULL,
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
        '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '90a50ded-1f30-4429-87f0-0e2669260594' OR ("EntityID" = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND "Name" = 'ColorCode')
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
        '90a50ded-1f30-4429-87f0-0e2669260594',
        '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- "Entity": "MJ_BizApps_Tasks": "Task" "Categories"
        100005,
        'ColorCode',
        'Color Code',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '3c853dc6-fa48-4948-96c3-1dc2aad4f43b' OR ("EntityID" = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND "Name" = 'Sequence')
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
        '3c853dc6-fa48-4948-96c3-1dc2aad4f43b',
        '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- "Entity": "MJ_BizApps_Tasks": "Task" "Categories"
        100006,
        'Sequence',
        'Sequence',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'f1e5f57f-ba65-427e-b888-eee83e1b030b' OR ("EntityID" = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND "Name" = 'IsActive')
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
        'f1e5f57f-ba65-427e-b888-eee83e1b030b',
        '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- "Entity": "MJ_BizApps_Tasks": "Task" "Categories"
        100007,
        'IsActive',
        'Is Active',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'a1b66759-19aa-4c40-9d3a-1ada99277416' OR ("EntityID" = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND "Name" = '__mj_CreatedAt')
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
        'a1b66759-19aa-4c40-9d3a-1ada99277416',
        '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- "Entity": "MJ_BizApps_Tasks": "Task" "Categories"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '87fa3f50-65d0-4b21-968d-31120657030c' OR ("EntityID" = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND "Name" = '__mj_UpdatedAt')
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
        '87fa3f50-65d0-4b21-968d-31120657030c',
        '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- "Entity": "MJ_BizApps_Tasks": "Task" "Categories"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'b8ad1f96-886c-4903-8d8d-fbebb27bb506' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'ID')
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
        'b8ad1f96-886c-4903-8d8d-fbebb27bb506',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '4c041cc2-d419-485c-9896-790003f638b9' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'Name')
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
        '4c041cc2-d419-485c-9896-790003f638b9',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100002,
        'Name',
        'Name',
        NULL,
        'TEXT',
        510,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '53f5b3e8-7220-48bd-a8e7-aea68a83cb82' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'Description')
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
        '53f5b3e8-7220-48bd-a8e7-aea68a83cb82',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100003,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '7ea597ed-da32-4cbc-a774-ad5e1986586a' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'TypeID')
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
        '7ea597ed-da32-4cbc-a774-ad5e1986586a',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100004,
        'TypeID',
        'Type ID',
        NULL,
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
        '1E30141A-826F-4278-BAA9-BBE14D29E606',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '4e328156-a0ff-4d3f-8c01-c75b89f235a6' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'CategoryID')
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
        '4e328156-a0ff-4d3f-8c01-c75b89f235a6',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100005,
        'CategoryID',
        'Category ID',
        NULL,
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
        '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'd419fc58-9802-454e-8d34-1dfaebee7df4' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'ParentID')
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
        'd419fc58-9802-454e-8d34-1dfaebee7df4',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100006,
        'ParentID',
        'Parent ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '832e90ca-b150-4b19-aace-f5385db15e64' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'Status')
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
        '832e90ca-b150-4b19-aace-f5385db15e64',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100007,
        'Status',
        'Status',
        NULL,
        'TEXT',
        100,
        0,
        0,
        FALSE,
        'Open',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'bb921c78-2bad-4b36-b7cb-e4a471372340' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'Priority')
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
        'bb921c78-2bad-4b36-b7cb-e4a471372340',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100008,
        'Priority',
        'Priority',
        NULL,
        'TEXT',
        40,
        0,
        0,
        FALSE,
        'Medium',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '3c7731ea-d59c-4db0-9a48-d2c40f7eff04' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'StartedAt')
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
        '3c7731ea-d59c-4db0-9a48-d2c40f7eff04',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100009,
        'StartedAt',
        'Started At',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'e50c83fb-bb14-4dab-b1a5-9bc108988d7b' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'DueAt')
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
        'e50c83fb-bb14-4dab-b1a5-9bc108988d7b',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100010,
        'DueAt',
        'Due At',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '3b2893b6-9e68-4563-b25b-feb90feff201' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'CompletedAt')
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
        '3b2893b6-9e68-4563-b25b-feb90feff201',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100011,
        'CompletedAt',
        'Completed At',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '0cf37cc9-7b64-4e9c-a79a-b7cf5be85244' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'HoursEstimated')
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
        '0cf37cc9-7b64-4e9c-a79a-b7cf5be85244',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100012,
        'HoursEstimated',
        'Hours Estimated',
        NULL,
        'decimal',
        5,
        8,
        2,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '7dc18266-ae9a-42f2-bf47-b406842712b8' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'HoursActual')
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
        '7dc18266-ae9a-42f2-bf47-b406842712b8',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100013,
        'HoursActual',
        'Hours Actual',
        NULL,
        'decimal',
        5,
        8,
        2,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '5812f201-256c-47ac-aeeb-3402fd1e9846' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'PercentComplete')
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
        '5812f201-256c-47ac-aeeb-3402fd1e9846',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100014,
        'PercentComplete',
        'Percent Complete',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '34c579d6-1fb8-4353-8f38-e75764139826' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'Sequence')
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
        '34c579d6-1fb8-4353-8f38-e75764139826',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100015,
        'Sequence',
        'Sequence',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '72888bfb-a442-414a-96c5-6d8b3a3aa67f' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'BlockedReason')
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
        '72888bfb-a442-414a-96c5-6d8b3a3aa67f',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100016,
        'BlockedReason',
        'Blocked Reason',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '0a2f1be2-d205-47e7-a804-679c04348efc' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'CompletionNotes')
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
        '0a2f1be2-d205-47e7-a804-679c04348efc',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100017,
        'CompletionNotes',
        'Completion Notes',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '0259c564-2dfe-480b-9075-3fd4c71fa46c' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'CreatedByPersonID')
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
        '0259c564-2dfe-480b-9075-3fd4c71fa46c',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100018,
        'CreatedByPersonID',
        'Created By Person ID',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '65cb1110-12e0-4e48-bed3-6bf1b2926807' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'OverdueNotifiedAt')
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
        '65cb1110-12e0-4e48-bed3-6bf1b2926807',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100019,
        'OverdueNotifiedAt',
        'Overdue Notified At',
        NULL,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'da16a787-212a-43bd-87e4-4d239f3eb12c' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = '__mj_CreatedAt')
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
        'da16a787-212a-43bd-87e4-4d239f3eb12c',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100020,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '8711f2ad-0bdc-4398-819f-f87f1d11f34a' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = '__mj_UpdatedAt')
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
        '8711f2ad-0bdc-4398-819f-f87f1d11f34a',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100021,
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

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('4d30381d-494d-4522-9888-c6ad0c7f6b55', 'BB921C78-2BAD-4B36-B7CB-E4A471372340', 1, 'Critical', 'Critical', NOW(), NOW());

/* SQL text to insert entity field value with ID 05d117f8-7cb2-401e-80f3-28023880e81b */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('05d117f8-7cb2-401e-80f3-28023880e81b', 'BB921C78-2BAD-4B36-B7CB-E4A471372340', 2, 'High', 'High', NOW(), NOW());

/* SQL text to insert entity field value with ID ba7566d8-67db-49aa-bf82-d68e54551d29 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('ba7566d8-67db-49aa-bf82-d68e54551d29', 'BB921C78-2BAD-4B36-B7CB-E4A471372340', 3, 'Low', 'Low', NOW(), NOW());

/* SQL text to insert entity field value with ID 5df92809-95d3-45a6-934e-730f6a38e5ff */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('5df92809-95d3-45a6-934e-730f6a38e5ff', 'BB921C78-2BAD-4B36-B7CB-E4A471372340', 4, 'Medium', 'Medium', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID BB921C78-2BAD-4B36-B7CB-E4A471372340 */

UPDATE "${mjSchema}"."EntityField" SET "ValueListType"='List' WHERE "ID"='BB921C78-2BAD-4B36-B7CB-E4A471372340';

/* SQL text to insert entity field value with ID 26d52813-85ca-44a2-a09c-ba320ee6aa40 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('26d52813-85ca-44a2-a09c-ba320ee6aa40', '4E823E84-05B4-43B4-A651-693798D589A8', 1, 'Completed', 'Completed', NOW(), NOW());

/* SQL text to insert entity field value with ID bc167d9f-e496-4fc3-bfde-13a7cfb9da2a */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('bc167d9f-e496-4fc3-bfde-13a7cfb9da2a', '4E823E84-05B4-43B4-A651-693798D589A8', 2, 'InProgress', 'InProgress', NOW(), NOW());

/* SQL text to insert entity field value with ID 653e807f-f0dd-40ee-8e35-dd04b64231dc */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('653e807f-f0dd-40ee-8e35-dd04b64231dc', '4E823E84-05B4-43B4-A651-693798D589A8', 3, 'Pending', 'Pending', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 4E823E84-05B4-43B4-A651-693798D589A8 */

UPDATE "${mjSchema}"."EntityField" SET "ValueListType"='List' WHERE "ID"='4E823E84-05B4-43B4-A651-693798D589A8';

/* SQL text to insert entity field value with ID dd2e1a2d-4eeb-4ecc-aa52-a6a79d339c88 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('dd2e1a2d-4eeb-4ecc-aa52-a6a79d339c88', '2DD6DB6E-82F2-439D-A15F-81BBE36286DF', 1, 'FinishToFinish', 'FinishToFinish', NOW(), NOW());

/* SQL text to insert entity field value with ID a325c453-d9b9-4b5f-9dbe-549e27243c40 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('a325c453-d9b9-4b5f-9dbe-549e27243c40', '2DD6DB6E-82F2-439D-A15F-81BBE36286DF', 2, 'FinishToStart', 'FinishToStart', NOW(), NOW());

/* SQL text to insert entity field value with ID 0e2761d2-ad6b-4e31-b4e8-885bf5b34b68 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('0e2761d2-ad6b-4e31-b4e8-885bf5b34b68', '2DD6DB6E-82F2-439D-A15F-81BBE36286DF', 3, 'StartToFinish', 'StartToFinish', NOW(), NOW());

/* SQL text to insert entity field value with ID dfc7a14d-da67-403e-a80d-c84390ea33bc */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('dfc7a14d-da67-403e-a80d-c84390ea33bc', '2DD6DB6E-82F2-439D-A15F-81BBE36286DF', 4, 'StartToStart', 'StartToStart', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 2DD6DB6E-82F2-439D-A15F-81BBE36286DF */

UPDATE "${mjSchema}"."EntityField" SET "ValueListType"='List' WHERE "ID"='2DD6DB6E-82F2-439D-A15F-81BBE36286DF';

/* SQL text to insert entity field value with ID cedc7f50-5cb2-4311-b0d4-737303e70a60 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('cedc7f50-5cb2-4311-b0d4-737303e70a60', '69C1ABE5-3DB5-4F9C-A55A-6381D46C1CD4', 1, 'Critical', 'Critical', NOW(), NOW());

/* SQL text to insert entity field value with ID 8aeee5ef-4a5e-418a-be44-325d7a5a68d9 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('8aeee5ef-4a5e-418a-be44-325d7a5a68d9', '69C1ABE5-3DB5-4F9C-A55A-6381D46C1CD4', 2, 'High', 'High', NOW(), NOW());

/* SQL text to insert entity field value with ID a8d56409-368d-46e1-a251-91dfcc3df4c8 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('a8d56409-368d-46e1-a251-91dfcc3df4c8', '69C1ABE5-3DB5-4F9C-A55A-6381D46C1CD4', 3, 'Low', 'Low', NOW(), NOW());

/* SQL text to insert entity field value with ID d067fab6-3c26-4846-966a-44c2f03eaf6e */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('d067fab6-3c26-4846-966a-44c2f03eaf6e', '69C1ABE5-3DB5-4F9C-A55A-6381D46C1CD4', 4, 'Medium', 'Medium', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 69C1ABE5-3DB5-4F9C-A55A-6381D46C1CD4 */

UPDATE "${mjSchema}"."EntityField" SET "ValueListType"='List' WHERE "ID"='69C1ABE5-3DB5-4F9C-A55A-6381D46C1CD4';

/* SQL text to insert entity field value with ID 641dc25e-83f6-410d-84d4-2bd3190094ff */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('641dc25e-83f6-410d-84d4-2bd3190094ff', '659F9A5C-BD9C-4EF7-88BE-B731541D2345', 1, 'FinishToFinish', 'FinishToFinish', NOW(), NOW());

/* SQL text to insert entity field value with ID 5544f182-aa03-4855-8232-a8d3c4cceca4 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('5544f182-aa03-4855-8232-a8d3c4cceca4', '659F9A5C-BD9C-4EF7-88BE-B731541D2345', 2, 'FinishToStart', 'FinishToStart', NOW(), NOW());

/* SQL text to insert entity field value with ID 047aa982-23f2-4bd6-b2ab-6c4e6b314e00 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('047aa982-23f2-4bd6-b2ab-6c4e6b314e00', '659F9A5C-BD9C-4EF7-88BE-B731541D2345', 3, 'StartToFinish', 'StartToFinish', NOW(), NOW());

/* SQL text to insert entity field value with ID fb2e3a35-bca9-40e9-8001-860be1445992 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('fb2e3a35-bca9-40e9-8001-860be1445992', '659F9A5C-BD9C-4EF7-88BE-B731541D2345', 4, 'StartToStart', 'StartToStart', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 659F9A5C-BD9C-4EF7-88BE-B731541D2345 */

UPDATE "${mjSchema}"."EntityField" SET "ValueListType"='List' WHERE "ID"='659F9A5C-BD9C-4EF7-88BE-B731541D2345';

/* SQL text to insert entity field value with ID b4fba07d-5070-427e-a751-236b0a8ffe51 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('b4fba07d-5070-427e-a751-236b0a8ffe51', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 1, 'AssignmentAdded', 'AssignmentAdded', NOW(), NOW());

/* SQL text to insert entity field value with ID 2afc33bf-fb39-445d-8610-0867d4997923 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('2afc33bf-fb39-445d-8610-0867d4997923', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 2, 'AssignmentRemoved', 'AssignmentRemoved', NOW(), NOW());

/* SQL text to insert entity field value with ID 7a9742f5-de77-4a89-9a95-413b357fc6e4 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('7a9742f5-de77-4a89-9a95-413b357fc6e4', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 3, 'Completed', 'Completed', NOW(), NOW());

/* SQL text to insert entity field value with ID 8491eccc-82e1-4449-a675-bc8036d461d1 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('8491eccc-82e1-4449-a675-bc8036d461d1', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 4, 'Created', 'Created', NOW(), NOW());

/* SQL text to insert entity field value with ID 3b04b519-5c74-45b1-ba4b-94372125b7e5 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('3b04b519-5c74-45b1-ba4b-94372125b7e5', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 5, 'DependencyAdded', 'DependencyAdded', NOW(), NOW());

/* SQL text to insert entity field value with ID f0ec7c9e-9646-491f-929e-165449d8929e */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('f0ec7c9e-9646-491f-929e-165449d8929e', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 6, 'DependencyRemoved', 'DependencyRemoved', NOW(), NOW());

/* SQL text to insert entity field value with ID f86d7d4f-2042-4a2b-a984-6c6c073d1cb1 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('f86d7d4f-2042-4a2b-a984-6c6c073d1cb1', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 7, 'DueDateChanged', 'DueDateChanged', NOW(), NOW());

/* SQL text to insert entity field value with ID 40b53f38-2ce5-41b1-8116-d2340bf0b78b */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('40b53f38-2ce5-41b1-8116-d2340bf0b78b', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 8, 'PercentCompleteChanged', 'PercentCompleteChanged', NOW(), NOW());

/* SQL text to insert entity field value with ID dd9e09d4-ff5d-44dc-8ac4-7554feee32fb */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('dd9e09d4-ff5d-44dc-8ac4-7554feee32fb', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 9, 'PriorityChanged', 'PriorityChanged', NOW(), NOW());

/* SQL text to insert entity field value with ID 20257078-873d-4c95-9dd9-078e4e856fcb */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('20257078-873d-4c95-9dd9-078e4e856fcb', '7B955FC4-A91E-4CC7-8768-E6945A895DF9', 10, 'StatusChange', 'StatusChange', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 7B955FC4-A91E-4CC7-8768-E6945A895DF9 */

UPDATE "${mjSchema}"."EntityField" SET "ValueListType"='List' WHERE "ID"='7B955FC4-A91E-4CC7-8768-E6945A895DF9';

/* SQL text to insert entity field value with ID 7826fb29-771d-46b1-96b3-05499a302d17 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('7826fb29-771d-46b1-96b3-05499a302d17', '9F629ABD-EC18-4FA9-9BDE-C8E47938903C', 1, 'Overdue', 'Overdue', NOW(), NOW());

/* SQL text to insert entity field value with ID ca573315-a0a0-471e-92df-d504d37dc9eb */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('ca573315-a0a0-471e-92df-d504d37dc9eb', '9F629ABD-EC18-4FA9-9BDE-C8E47938903C', 2, 'OverdueReminder', 'OverdueReminder', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 9F629ABD-EC18-4FA9-9BDE-C8E47938903C */

UPDATE "${mjSchema}"."EntityField" SET "ValueListType"='List' WHERE "ID"='9F629ABD-EC18-4FA9-9BDE-C8E47938903C';

/* SQL text to insert entity field value with ID a94d176f-bd81-4959-8d4d-2eedbf74dd0f */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('a94d176f-bd81-4959-8d4d-2eedbf74dd0f', '55D2A288-00C8-425F-8E69-06BCED11D706', 1, 'Critical', 'Critical', NOW(), NOW());

/* SQL text to insert entity field value with ID 5e16d4b6-4f90-46bd-bda7-0650bcadbfac */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('5e16d4b6-4f90-46bd-bda7-0650bcadbfac', '55D2A288-00C8-425F-8E69-06BCED11D706', 2, 'High', 'High', NOW(), NOW());

/* SQL text to insert entity field value with ID 33eb2fb9-cf45-4958-8c5a-7703e4c3d33b */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('33eb2fb9-cf45-4958-8c5a-7703e4c3d33b', '55D2A288-00C8-425F-8E69-06BCED11D706', 3, 'Low', 'Low', NOW(), NOW());

/* SQL text to insert entity field value with ID c101d7bc-c32d-4521-9b6a-567e5add230b */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('c101d7bc-c32d-4521-9b6a-567e5add230b', '55D2A288-00C8-425F-8E69-06BCED11D706', 4, 'Medium', 'Medium', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 55D2A288-00C8-425F-8E69-06BCED11D706 */

UPDATE "${mjSchema}"."EntityField" SET "ValueListType"='List' WHERE "ID"='55D2A288-00C8-425F-8E69-06BCED11D706';

/* SQL text to insert entity field value with ID 14f84226-72f3-48d0-b3ca-f9de97f016af */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('14f84226-72f3-48d0-b3ca-f9de97f016af', '832E90CA-B150-4B19-AACE-F5385DB15E64', 1, 'Blocked', 'Blocked', NOW(), NOW());

/* SQL text to insert entity field value with ID d250809f-e070-4321-bba9-4adad00f6766 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('d250809f-e070-4321-bba9-4adad00f6766', '832E90CA-B150-4B19-AACE-F5385DB15E64', 2, 'Cancelled', 'Cancelled', NOW(), NOW());

/* SQL text to insert entity field value with ID 19a8398a-e441-459e-9a81-f02e6eff6778 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('19a8398a-e441-459e-9a81-f02e6eff6778', '832E90CA-B150-4B19-AACE-F5385DB15E64', 3, 'Completed', 'Completed', NOW(), NOW());

/* SQL text to insert entity field value with ID 83614e4e-617c-4aac-8a72-48c8bca3e243 */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('83614e4e-617c-4aac-8a72-48c8bca3e243', '832E90CA-B150-4B19-AACE-F5385DB15E64', 4, 'InProgress', 'InProgress', NOW(), NOW());

/* SQL text to insert entity field value with ID 5409b332-98f9-404e-98fe-a3351b7c168c */

INSERT INTO "${mjSchema}"."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('5409b332-98f9-404e-98fe-a3351b7c168c', '832E90CA-B150-4B19-AACE-F5385DB15E64', 5, 'Open', 'Open', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 832E90CA-B150-4B19-AACE-F5385DB15E64 */

UPDATE "${mjSchema}"."EntityField" SET "ValueListType"='List' WHERE "ID"='832E90CA-B150-4B19-AACE-F5385DB15E64';


/* Create Entity Relationship: MJ_BizApps_Tasks: Task Templates -> MJ_BizApps_Tasks: Task Template Items (One To Many via TemplateID) */

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = 'b12474ed-dd3b-427f-82d5-be993d42ba21'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('b12474ed-dd3b-427f-82d5-be993d42ba21', '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', 'A28FDD91-D380-427E-B374-BCEC56ED75B7', 'TemplateID', 'One To Many', TRUE, TRUE, 1, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '56ec035d-e9dc-49ce-a25a-7f470bff31bd'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('56ec035d-e9dc-49ce-a25a-7f470bff31bd', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'DF98E700-1992-442B-B93E-E47379F2CA52', 'AssigneeEntityID', 'One To Many', TRUE, TRUE, 64, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '8cdcee4b-449f-480c-a36b-1ec930cd9ba6'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('8cdcee4b-449f-480c-a36b-1ec930cd9ba6', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'B92E802C-5C1B-486D-B021-03E47069502C', 'EntityID', 'One To Many', TRUE, TRUE, 65, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '12cd9353-cf0b-46df-9d50-4ce4abc2b18a'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('12cd9353-cf0b-46df-9d50-4ce4abc2b18a', 'E1238F34-2837-EF11-86D4-6045BDEE16E6', 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', 'NotifiedUserID', 'One To Many', TRUE, TRUE, 103, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = 'e4e392d9-5299-4f9b-88d9-192f37544bbb'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('e4e392d9-5299-4f9b-88d9-192f37544bbb', '38248F34-2837-EF11-86D4-6045BDEE16E6', 'A210AF26-629A-4E0A-A90A-1CCE33F5D095', 'OverdueActionID', 'One To Many', TRUE, TRUE, 13, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '243502d4-5636-4caf-af54-be18bf0aa720'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('243502d4-5636-4caf-af54-be18bf0aa720', '38248F34-2837-EF11-86D4-6045BDEE16E6', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'OnOverdueActionID', 'One To Many', TRUE, TRUE, 14, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '17f82e18-5d9f-4ff8-b129-4d95366da36c'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('17f82e18-5d9f-4ff8-b129-4d95366da36c', '38248F34-2837-EF11-86D4-6045BDEE16E6', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'OnPercentChangeActionID', 'One To Many', TRUE, TRUE, 15, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '22a88991-05f6-41f6-8172-69681019e858'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('22a88991-05f6-41f6-8172-69681019e858', '38248F34-2837-EF11-86D4-6045BDEE16E6', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'OnAssignActionID', 'One To Many', TRUE, TRUE, 16, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '2520bbdc-fd62-468d-9f5e-7a731e2cdb84'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('2520bbdc-fd62-468d-9f5e-7a731e2cdb84', '38248F34-2837-EF11-86D4-6045BDEE16E6', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'OnCompleteActionID', 'One To Many', TRUE, TRUE, 17, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = 'b625a1b5-5989-444d-aabd-0bb5dd31ad48'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('b625a1b5-5989-444d-aabd-0bb5dd31ad48', '559054C2-8F03-4A66-B4FD-70DE5948ACE2', 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', 'RoleID', 'One To Many', TRUE, TRUE, 1, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '00e5298b-bdd4-4832-9c29-12021e58d16e'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('00e5298b-bdd4-4832-9c29-12021e58d16e', '559054C2-8F03-4A66-B4FD-70DE5948ACE2', 'DF98E700-1992-442B-B93E-E47379F2CA52', 'RoleID', 'One To Many', TRUE, TRUE, 2, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '64de3230-a6bf-4d22-9c32-fe92c7c0d771'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('64de3230-a6bf-4d22-9c32-fe92c7c0d771', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'A210AF26-629A-4E0A-A90A-1CCE33F5D095', 'TaskTypeID', 'One To Many', TRUE, TRUE, 1, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = 'e75e7a70-9034-4969-b83c-23e73111259a'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('e75e7a70-9034-4969-b83c-23e73111259a', '1E30141A-826F-4278-BAA9-BBE14D29E606', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'TypeID', 'One To Many', TRUE, TRUE, 2, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '8593e41c-e3c6-486c-a41e-5f645f5c6eed'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('8593e41c-e3c6-486c-a41e-5f645f5c6eed', '1E30141A-826F-4278-BAA9-BBE14D29E606', '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', 'TypeID', 'One To Many', TRUE, TRUE, 3, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '27b4d4f2-24fb-4dfa-8c91-1698fcd76acf'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('27b4d4f2-24fb-4dfa-8c91-1698fcd76acf', 'A28FDD91-D380-427E-B374-BCEC56ED75B7', 'A28FDD91-D380-427E-B374-BCEC56ED75B7', 'ParentItemID', 'One To Many', TRUE, TRUE, 1, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = 'abc1839c-6bdb-402e-9cfc-b2c2c46a62b8'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('abc1839c-6bdb-402e-9cfc-b2c2c46a62b8', 'A28FDD91-D380-427E-B374-BCEC56ED75B7', 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', 'ItemID', 'One To Many', TRUE, TRUE, 2, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '1f8ce426-dba4-4370-872f-6c53af4438d0'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('1f8ce426-dba4-4370-872f-6c53af4438d0', 'A28FDD91-D380-427E-B374-BCEC56ED75B7', '8A30F14C-26FF-476E-8CA1-B10EAD29A428', 'DependsOnItemID', 'One To Many', TRUE, TRUE, 3, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = 'bc838a5c-de5f-4ace-b32d-7b6955d654ea'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('bc838a5c-de5f-4ace-b32d-7b6955d654ea', 'A28FDD91-D380-427E-B374-BCEC56ED75B7', '8A30F14C-26FF-476E-8CA1-B10EAD29A428', 'ItemID', 'One To Many', TRUE, TRUE, 4, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '2c314e79-a643-443d-bb0c-1c74d4f9c9ac'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('2c314e79-a643-443d-bb0c-1c74d4f9c9ac', 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', 'ParentID', 'One To Many', TRUE, TRUE, 1, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '91de82af-9114-4e3a-9d3a-2a669e3d1a56'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('91de82af-9114-4e3a-9d3a-2a669e3d1a56', '5DB17493-CD0A-4633-80D4-D4A499662C76', 'EA953D6B-524E-4A09-A842-9A0B0F1F850C', 'TagID', 'One To Many', TRUE, TRUE, 1, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '8d492c02-54cf-44d6-b540-9a37ea146459'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('8d492c02-54cf-44d6-b540-9a37ea146459', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', 'PersonID', 'One To Many', TRUE, TRUE, 4, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '4e9fcaa1-19e6-437d-a968-bfee4587e482'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('4e9fcaa1-19e6-437d-a968-bfee4587e482', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'DF98E700-1992-442B-B93E-E47379F2CA52', 'AssignedByPersonID', 'One To Many', TRUE, TRUE, 5, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = 'a2985da3-5b3b-4d9c-b89a-514ae8c0bd17'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('a2985da3-5b3b-4d9c-b89a-514ae8c0bd17', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '6615EF77-83F1-49F1-B717-80EC31F77486', 'PersonID', 'One To Many', TRUE, TRUE, 6, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '8c5a53ec-ca02-4b51-b8c1-9ba625af6044'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('8c5a53ec-ca02-4b51-b8c1-9ba625af6044', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'CreatedByPersonID', 'One To Many', TRUE, TRUE, 7, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '13e6795f-ed8e-4864-bbd6-0014fc2a40df'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('13e6795f-ed8e-4864-bbd6-0014fc2a40df', '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', 'CategoryID', 'One To Many', TRUE, TRUE, 1, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = 'db864c7c-8f44-4ff7-85d0-ee414a46cafd'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('db864c7c-8f44-4ff7-85d0-ee414a46cafd', '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', 'ParentID', 'One To Many', TRUE, TRUE, 2, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '8bc71ac8-d006-4c28-b5a7-269c53c64a0e'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('8bc71ac8-d006-4c28-b5a7-269c53c64a0e', '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'CategoryID', 'One To Many', TRUE, TRUE, 3, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = 'c8e7abbb-8c96-4f7b-b5da-9cf872a26f61'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('c8e7abbb-8c96-4f7b-b5da-9cf872a26f61', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', 'DependsOnTaskID', 'One To Many', TRUE, TRUE, 1, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = 'b41f9981-030b-4eff-92c2-9ff0460efcfa'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('b41f9981-030b-4eff-92c2-9ff0460efcfa', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', 'TaskID', 'One To Many', TRUE, TRUE, 2, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = 'd792c155-f9e6-4583-af2e-2c58286b4d16'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('d792c155-f9e6-4583-af2e-2c58286b4d16', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'ParentID', 'One To Many', TRUE, TRUE, 3, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = 'b62e328d-a310-4d6f-8480-ac997074b4a3'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('b62e328d-a310-4d6f-8480-ac997074b4a3', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'DF98E700-1992-442B-B93E-E47379F2CA52', 'TaskID', 'One To Many', TRUE, TRUE, 4, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = 'bc39430a-8236-4d71-9ca8-bf48f5f5b3c8'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('bc39430a-8236-4d71-9ca8-bf48f5f5b3c8', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'B92E802C-5C1B-486D-B021-03E47069502C', 'TaskID', 'One To Many', TRUE, TRUE, 5, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '1c165e6f-0ddf-441b-83b5-63f37c308558'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('1c165e6f-0ddf-441b-83b5-63f37c308558', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', 'TaskID', 'One To Many', TRUE, TRUE, 6, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = 'f8c5be61-c2db-4cd3-ab00-e9ef094c0a94'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('f8c5be61-c2db-4cd3-ab00-e9ef094c0a94', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '6615EF77-83F1-49F1-B717-80EC31F77486', 'TaskID', 'One To Many', TRUE, TRUE, 7, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '7b5c6c40-ee9b-41fe-9b56-f641b5ed2704'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('7b5c6c40-ee9b-41fe-9b56-f641b5ed2704', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'EA953D6B-524E-4A09-A842-9A0B0F1F850C', 'TaskID', 'One To Many', TRUE, TRUE, 8, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityRelationship" WHERE "ID" = '40fd17ae-a6d3-49ec-acad-58a68f6cb2f6'
    ) THEN
        INSERT INTO "${mjSchema}"."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('40fd17ae-a6d3-49ec-acad-58a68f6cb2f6', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', 'TaskID', 'One To Many', TRUE, TRUE, 9, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'b705b24c-14e9-44df-ad99-5aded1b3d054' OR ("EntityID" = 'B92E802C-5C1B-486D-B021-03E47069502C' AND "Name" = 'Task')
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
        'b705b24c-14e9-44df-ad99-5aded1b3d054',
        'B92E802C-5C1B-486D-B021-03E47069502C', -- "Entity": "MJ_BizApps_Tasks": "Task" "Links"
        100015,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '0f4c45b2-8d5e-40ca-8ee1-7915db3f885e' OR ("EntityID" = 'B92E802C-5C1B-486D-B021-03E47069502C' AND "Name" = 'Entity')
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
        '0f4c45b2-8d5e-40ca-8ee1-7915db3f885e',
        'B92E802C-5C1B-486D-B021-03E47069502C', -- "Entity": "MJ_BizApps_Tasks": "Task" "Links"
        100016,
        'Entity',
        'Entity',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '65dd9bd7-ac80-4b9a-8e08-b92bc37a8d37' OR ("EntityID" = 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3' AND "Name" = 'Item')
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
        '65dd9bd7-ac80-4b9a-8e08-b92bc37a8d37',
        'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Item" "Roles"
        100011,
        'Item',
        'Item',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '258256a5-3b70-4392-b4fc-f13e1892b4ca' OR ("EntityID" = 'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3' AND "Name" = 'Role')
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
        '258256a5-3b70-4392-b4fc-f13e1892b4ca',
        'ABFCFE68-F3AA-4401-A547-0FC01F27E3F3', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Item" "Roles"
        100012,
        'Role',
        'Role',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '1e0b0b58-eeb0-483f-baa9-2c84b701562b' OR ("EntityID" = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND "Name" = 'TaskType')
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
        '1e0b0b58-eeb0-483f-baa9-2c84b701562b',
        'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Configs"
        100021,
        'TaskType',
        'Task Type',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'c2e46071-908d-4452-9f75-d659d0ee9f21' OR ("EntityID" = 'A210AF26-629A-4E0A-A90A-1CCE33F5D095' AND "Name" = 'OverdueAction')
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
        'c2e46071-908d-4452-9f75-d659d0ee9f21',
        'A210AF26-629A-4E0A-A90A-1CCE33F5D095', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Configs"
        100022,
        'OverdueAction',
        'Overdue Action',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '1c054f41-3fd6-44ae-abde-0ae1ffb7407f' OR ("EntityID" = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND "Name" = 'Task')
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
        '1c054f41-3fd6-44ae-abde-0ae1ffb7407f',
        '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', -- "Entity": "MJ_BizApps_Tasks": "Task" "Dependencies"
        100013,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'f25c9bb2-2bc9-4893-aee3-665b2dce198c' OR ("EntityID" = '0662FC0F-3F2B-49C9-9BE8-5B59E036044A' AND "Name" = 'DependsOnTask')
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
        'f25c9bb2-2bc9-4893-aee3-665b2dce198c',
        '0662FC0F-3F2B-49C9-9BE8-5B59E036044A', -- "Entity": "MJ_BizApps_Tasks": "Task" "Dependencies"
        100014,
        'DependsOnTask',
        'Depends On Task',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '39e1d13f-7f84-402d-a9e1-ec03dd2d2fd0' OR ("EntityID" = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND "Name" = 'Category')
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
        '39e1d13f-7f84-402d-a9e1-ec03dd2d2fd0',
        '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- "Entity": "MJ_BizApps_Tasks": "Task" "Templates"
        100017,
        'Category',
        'Category',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '4a27ab78-cb50-4895-a3c1-c04293754fe0' OR ("EntityID" = '802AEF11-BFE2-4B46-98B2-5FEBD4E35923' AND "Name" = 'Type')
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
        '4a27ab78-cb50-4895-a3c1-c04293754fe0',
        '802AEF11-BFE2-4B46-98B2-5FEBD4E35923', -- "Entity": "MJ_BizApps_Tasks": "Task" "Templates"
        100018,
        'Type',
        'Type',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '430ede8e-381e-41b8-a306-2fad2b44a526' OR ("EntityID" = '6615EF77-83F1-49F1-B717-80EC31F77486' AND "Name" = 'Task')
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
        '430ede8e-381e-41b8-a306-2fad2b44a526',
        '6615EF77-83F1-49F1-B717-80EC31F77486', -- "Entity": "MJ_BizApps_Tasks": "Task" "Activities"
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'fca512c5-ab75-4fbb-bbc2-4499a4439826' OR ("EntityID" = '6615EF77-83F1-49F1-B717-80EC31F77486' AND "Name" = 'Person')
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
        'fca512c5-ab75-4fbb-bbc2-4499a4439826',
        '6615EF77-83F1-49F1-B717-80EC31F77486', -- "Entity": "MJ_BizApps_Tasks": "Task" "Activities"
        100020,
        'Person',
        'Person',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '2ee80d0d-703c-44c0-843b-54a5cef8e9dd' OR ("EntityID" = 'EA953D6B-524E-4A09-A842-9A0B0F1F850C' AND "Name" = 'Task')
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
        '2ee80d0d-703c-44c0-843b-54a5cef8e9dd',
        'EA953D6B-524E-4A09-A842-9A0B0F1F850C', -- "Entity": "MJ_BizApps_Tasks": "Task" "Tag" "Links"
        100011,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'c2df8047-dca7-4404-a067-f679862af2d1' OR ("EntityID" = 'EA953D6B-524E-4A09-A842-9A0B0F1F850C' AND "Name" = 'Tag')
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
        'c2df8047-dca7-4404-a067-f679862af2d1',
        'EA953D6B-524E-4A09-A842-9A0B0F1F850C', -- "Entity": "MJ_BizApps_Tasks": "Task" "Tag" "Links"
        100012,
        'Tag',
        'Tag',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'cf0321d6-9218-4f3e-8f19-359cde794bc9' OR ("EntityID" = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND "Name" = 'Item')
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
        'cf0321d6-9218-4f3e-8f19-359cde794bc9',
        '8A30F14C-26FF-476E-8CA1-B10EAD29A428', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Item" "Dependencies"
        100013,
        'Item',
        'Item',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'b3b55837-7701-424a-b681-535aac28dfdb' OR ("EntityID" = '8A30F14C-26FF-476E-8CA1-B10EAD29A428' AND "Name" = 'DependsOnItem')
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
        'b3b55837-7701-424a-b681-535aac28dfdb',
        '8A30F14C-26FF-476E-8CA1-B10EAD29A428', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Item" "Dependencies"
        100014,
        'DependsOnItem',
        'Depends On Item',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '4391ece2-8780-413a-8605-4569f84cff03' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'OnAssignAction')
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
        '4391ece2-8780-413a-8605-4569f84cff03',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100025,
        'OnAssignAction',
        'On Assign Action',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '028bbcc5-6694-4b9f-81e8-f2b99ef72fbe' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'OnCompleteAction')
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
        '028bbcc5-6694-4b9f-81e8-f2b99ef72fbe',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100026,
        'OnCompleteAction',
        'On Complete Action',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '39770061-f6e2-4e20-9d1a-8a9343e0f041' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'OnOverdueAction')
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
        '39770061-f6e2-4e20-9d1a-8a9343e0f041',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100027,
        'OnOverdueAction',
        'On Overdue Action',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'f91576c2-90c5-407d-820f-7faeb246cfbd' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'OnPercentChangeAction')
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
        'f91576c2-90c5-407d-820f-7faeb246cfbd',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        100028,
        'OnPercentChangeAction',
        'On Percent Change Action',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '1b04cbb9-c18a-4bb2-956c-16f26aa85d48' OR ("EntityID" = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND "Name" = 'Template')
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
        '1b04cbb9-c18a-4bb2-956c-16f26aa85d48',
        'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Items"
        100023,
        'Template',
        'Template',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '158e5bd6-2fcf-4863-a09b-65f796dd26a5' OR ("EntityID" = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND "Name" = 'ParentItem')
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
        '158e5bd6-2fcf-4863-a09b-65f796dd26a5',
        'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Items"
        100024,
        'ParentItem',
        'Parent Item',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '19fcbb42-f0c7-4b08-87f0-0a2127e0f665' OR ("EntityID" = 'A28FDD91-D380-427E-B374-BCEC56ED75B7' AND "Name" = 'RootParentItemID')
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
        '19fcbb42-f0c7-4b08-87f0-0a2127e0f665',
        'A28FDD91-D380-427E-B374-BCEC56ED75B7', -- "Entity": "MJ_BizApps_Tasks": "Task" "Template" "Items"
        100025,
        'RootParentItemID',
        'Root Parent Item ID',
        NULL,
        'UUID',
        16,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '95d43787-3e4a-4626-be10-1fc07ad2d772' OR ("EntityID" = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND "Name" = 'Task')
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
        '95d43787-3e4a-4626-be10-1fc07ad2d772',
        'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Logs"
        100015,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '333468ec-8d96-490f-80dd-c90f9aa4025c' OR ("EntityID" = 'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4' AND "Name" = 'NotifiedUser')
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
        '333468ec-8d96-490f-80dd-c90f9aa4025c',
        'DD0C62ED-7960-4D0A-A1FC-C0E0754DE1D4', -- "Entity": "MJ_BizApps_Tasks": "Task" "Notification" "Logs"
        100016,
        'NotifiedUser',
        'Notified User',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '9adda9ab-8118-4897-95f2-c42a767f5b60' OR ("EntityID" = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND "Name" = 'Task')
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
        '9adda9ab-8118-4897-95f2-c42a767f5b60',
        'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- "Entity": "MJ_BizApps_Tasks": "Task" "Comments"
        100017,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '2f6fc89c-bb94-4778-83be-d232731db780' OR ("EntityID" = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND "Name" = 'Person')
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
        '2f6fc89c-bb94-4778-83be-d232731db780',
        'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- "Entity": "MJ_BizApps_Tasks": "Task" "Comments"
        100018,
        'Person',
        'Person',
        NULL,
        'TEXT',
        402,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'e7a58455-30f8-4ac9-8d33-3abd1b91cbdc' OR ("EntityID" = 'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865' AND "Name" = 'RootParentID')
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
        'e7a58455-30f8-4ac9-8d33-3abd1b91cbdc',
        'B8B2C72F-44FB-4C6E-9E4F-D42AEE1C1865', -- "Entity": "MJ_BizApps_Tasks": "Task" "Comments"
        100019,
        'RootParentID',
        'Root Parent ID',
        NULL,
        'UUID',
        16,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'fd3035a9-13ab-40d2-941a-8e1178b4a797' OR ("EntityID" = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND "Name" = 'Task')
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
        'fd3035a9-13ab-40d2-941a-8e1178b4a797',
        'DF98E700-1992-442B-B93E-E47379F2CA52', -- "Entity": "MJ_BizApps_Tasks": "Task" "Assignments"
        100023,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '3edfbafc-eada-4557-bb45-81127ea36254' OR ("EntityID" = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND "Name" = 'AssigneeEntity')
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
        '3edfbafc-eada-4557-bb45-81127ea36254',
        'DF98E700-1992-442B-B93E-E47379F2CA52', -- "Entity": "MJ_BizApps_Tasks": "Task" "Assignments"
        100024,
        'AssigneeEntity',
        'Assignee Entity',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '64c83f45-894f-43a0-aab1-5aa13f615813' OR ("EntityID" = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND "Name" = 'Role')
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
        '64c83f45-894f-43a0-aab1-5aa13f615813',
        'DF98E700-1992-442B-B93E-E47379F2CA52', -- "Entity": "MJ_BizApps_Tasks": "Task" "Assignments"
        100025,
        'Role',
        'Role',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '1fd8bfab-20de-4ef1-8743-fca5eb95e28e' OR ("EntityID" = 'DF98E700-1992-442B-B93E-E47379F2CA52' AND "Name" = 'AssignedByPerson')
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
        '1fd8bfab-20de-4ef1-8743-fca5eb95e28e',
        'DF98E700-1992-442B-B93E-E47379F2CA52', -- "Entity": "MJ_BizApps_Tasks": "Task" "Assignments"
        100026,
        'AssignedByPerson',
        'Assigned By Person',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = 'a058e354-34aa-40ac-938f-80350d35bd96' OR ("EntityID" = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND "Name" = 'Parent')
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
        'a058e354-34aa-40ac-938f-80350d35bd96',
        '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- "Entity": "MJ_BizApps_Tasks": "Task" "Categories"
        100019,
        'Parent',
        'Parent',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '75a44757-69a9-4333-8e3e-5f4708bb0ce8' OR ("EntityID" = '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6' AND "Name" = 'RootParentID')
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
        '75a44757-69a9-4333-8e3e-5f4708bb0ce8',
        '06303FA3-48F0-45B7-BC6A-F3EBDFEE5CB6', -- "Entity": "MJ_BizApps_Tasks": "Task" "Categories"
        100020,
        'RootParentID',
        'Root Parent ID',
        NULL,
        'UUID',
        16,
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '5e003cc8-55fc-4401-a7d9-7687be6bd753' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'Type')
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
        '5e003cc8-55fc-4401-a7d9-7687be6bd753',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100043,
        'Type',
        'Type',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '411b26c4-2aec-41eb-96c1-897c92770598' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'Category')
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
        '411b26c4-2aec-41eb-96c1-897c92770598',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100044,
        'Category',
        'Category',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '16bea5bd-358f-4e40-ab62-09be3478345f' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'Parent')
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
        '16bea5bd-358f-4e40-ab62-09be3478345f',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100045,
        'Parent',
        'Parent',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '4ee84219-d7cb-408f-8ead-410973b487af' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'CreatedByPerson')
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
        '4ee84219-d7cb-408f-8ead-410973b487af',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100046,
        'CreatedByPerson',
        'Created By Person',
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
        SELECT 1 FROM "${mjSchema}"."EntityField" WHERE "ID" = '3205c212-1737-4748-b232-3a64abd3c93c' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'RootParentID')
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
        '3205c212-1737-4748-b232-3a64abd3c93c',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        100047,
        'RootParentID',
        'Root Parent ID',
        NULL,
        'UUID',
        16,
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


-- ===================== Grants =====================

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskCategories" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Categories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Categories
-- Item: Permissions for vwTaskCategories
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskCategories" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Categories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Categories
-- Item: spCreateTaskCategory
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskCategory
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskCategory" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Categories */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskCategory" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Categories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Categories
-- Item: spUpdateTaskCategory
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskCategory
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskCategory" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskCategory" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Categories */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Categories
-- Item: spDeleteTaskCategory
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskCategory
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskCategory" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Categories */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskCategory" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* SQL text to update entity field related entity name field map for entity field ID C885176B-BCCD-4D0A-BDFC-B624394404B4 */

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskActivities" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Activities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Activities
-- Item: Permissions for vwTaskActivities
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskActivities" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskActivity" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Activities */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskActivity" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskActivity" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskActivity" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskActivity" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Activities */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskActivity" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* SQL text to update entity field related entity name field map for entity field ID BFF49CE0-1E51-4F11-9D1D-CB1C1D014AD5 */

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskComments" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Comments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Comments
-- Item: Permissions for vwTaskComments
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskComments" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskComment" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Comments */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskComment" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskComment" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskComment" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskComment" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Comments */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskComment" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskDependencies" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Dependencies
-- Item: Permissions for vwTaskDependencies
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskDependencies" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Dependencies */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Dependencies */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* SQL text to update entity field related entity name field map for entity field ID D472964E-4AAF-44E6-A01A-E2A92AAA44DA */

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskAssignments" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Assignments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Assignments
-- Item: Permissions for vwTaskAssignments
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskAssignments" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskAssignment" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Assignments */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskAssignment" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskAssignment" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskAssignment" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskAssignment" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Assignments */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskAssignment" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Index for Foreign Keys for TaskLink */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Links
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskID in table TaskLink;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskRoles" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Roles
-- Item: Permissions for vwTaskRoles
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskRoles" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Roles
-- Item: spCreateTaskRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskRole
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Roles */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Roles
-- Item: spUpdateTaskRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskRole
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Roles
-- Item: spDeleteTaskRole
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskRole
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Roles */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* SQL text to update entity field related entity name field map for entity field ID 66BD853F-28CA-4592-8409-C114EFB477A2 */

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskNotificationConfigs" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Notification Configs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Configs
-- Item: Permissions for vwTaskNotificationConfigs
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskNotificationConfigs" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Notification Configs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Configs
-- Item: spCreateTaskNotificationConfig
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskNotificationConfig
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskNotificationConfig" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Notification Configs */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskNotificationConfig" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Notification Configs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Configs
-- Item: spUpdateTaskNotificationConfig
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskNotificationConfig
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskNotificationConfig" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskNotificationConfig" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Notification Configs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Configs
-- Item: spDeleteTaskNotificationConfig
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskNotificationConfig
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskNotificationConfig" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Notification Configs */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskNotificationConfig" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskNotificationLogs" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Notification Logs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Notification Logs
-- Item: Permissions for vwTaskNotificationLogs
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskNotificationLogs" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskNotificationLog" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Notification Logs */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskNotificationLog" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskNotificationLog" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskNotificationLog" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskNotificationLog" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Notification Logs */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskNotificationLog" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskTagLinks" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Tag Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tag Links
-- Item: Permissions for vwTaskTagLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskTagLinks" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskTagLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Tag Links */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskTagLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskTagLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskTagLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskTagLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Tag Links */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskTagLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskLinks" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Links
-- Item: Permissions for vwTaskLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskLinks" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Links */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Links */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Index for Foreign Keys for TaskTag */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tags
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

/* Index for Foreign Keys for TaskTemplateItemDependency */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key ItemID in table TaskTemplateItemDependency;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskTags" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Tags */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tags
-- Item: Permissions for vwTaskTags
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskTags" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Tags */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tags
-- Item: spCreateTaskTag
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTag
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskTag" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Tags */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskTag" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Tags */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tags
-- Item: spUpdateTaskTag
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTag
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskTag" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskTag" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Tags */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Tags
-- Item: spDeleteTaskTag
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTag
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskTag" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Tags */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskTag" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* SQL text to update entity field related entity name field map for entity field ID 97D8E900-6AF3-4A75-92DA-1EAA66984AAE */

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskTemplateItems" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Template Items */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Items
-- Item: Permissions for vwTaskTemplateItems
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskTemplateItems" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskTemplateItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Template Items */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskTemplateItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskTemplateItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskTemplateItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskTemplateItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Template Items */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskTemplateItem" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskTemplateItemDependencies" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Template Item Dependencies */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Dependencies
-- Item: Permissions for vwTaskTemplateItemDependencies
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskTemplateItemDependencies" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskTemplateItemDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Template Item Dependencies */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskTemplateItemDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskTemplateItemDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskTemplateItemDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskTemplateItemDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Template Item Dependencies */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskTemplateItemDependency" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View SQL for MJ_BizApps_Tasks: Task Templates */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Templates
-- Item: vwTaskTemplates
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Templates
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  TaskTemplate
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskTemplates" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Templates */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Templates
-- Item: Permissions for vwTaskTemplates
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskTemplates" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Templates */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Templates
-- Item: spCreateTaskTemplate
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTemplate
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskTemplate" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Templates */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskTemplate" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Templates */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Templates
-- Item: spUpdateTaskTemplate
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTemplate
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskTemplate" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskTemplate" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Templates */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Templates
-- Item: spDeleteTaskTemplate
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTemplate
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskTemplate" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Templates */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskTemplate" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskTemplateItemRoles" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Template Item Roles */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Template Item Roles
-- Item: Permissions for vwTaskTemplateItemRoles
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskTemplateItemRoles" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskTemplateItemRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Template Item Roles */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskTemplateItemRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskTemplateItemRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskTemplateItemRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskTemplateItemRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Template Item Roles */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskTemplateItemRole" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTasks" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: Permissions for vwTasks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTasks" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: spCreateTask
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR Task
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTask" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Tasks */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTask" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTask" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTask" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTask" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Tasks */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTask" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View SQL for MJ_BizApps_Tasks: Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Types
-- Item: vwTaskTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Types
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  TaskType
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskTypes" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Types
-- Item: Permissions for vwTaskTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON "__mj_BizAppsTasks"."vwTaskTypes" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Types */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spCreateTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spUpdateTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Types */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION "__mj_BizAppsTasks"."spDeleteTaskType" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* SQL text to delete unneeded entity fields (17 scoped entities) */


-- ===================== Other =====================

-- BizAppsTasks Schema and Tables
-- Reusable task management for MemberJunction business applications:
-- Tasks, assignments, dependencies, categories, tags, comments,
-- templates, and activity tracking.

/*----------------------------CODEGEN-----------------------------*/
/* SQL generated to create new entity MJ_BizApps_Tasks: Task Roles */

/* SQL text to insert new entity field */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Categories */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Activities */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Comments */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Dependencies */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Assignments */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Roles */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Notification Configs */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Notification Logs */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Tag Links */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Links */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Tags */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Template Items */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Template Item Dependencies */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Templates */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Template Item Roles */

/* spUpdate Permissions for MJ_BizApps_Tasks: Tasks */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Types */
