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
-- BizApps Tasks v1.11.0 — Time Tracking, Agent Effort, and Timesheets
-- =============================================================================
-- Adds:
-- 1. TaskTimeEntry — human & agent time entries logged against tasks
-- 2. TaskTimer — at most one running stopwatch per person
-- 3. TaskAgentRun — links Tasks to MJ: AI Agent Runs
-- 4. Timesheet — period header per person + TaskTimeEntry.TimesheetID FK
-- 5. TimesheetApproval — per-project approval parts backed by Tasks
-- 6. TimeApprover — configurable time approver directory
-- 7. TimesheetLink — polymorphic links from Timesheet to external records
-- 8. TaskTimeEntryLink — polymorphic links from TaskTimeEntry to external records
-- 9. TimesheetSchedule — effective-dated cadence history
-- 10. TaskType.RequiresAssigneeDecision — decision authority column on TaskType
-- 11. vwTaskRootAgentEffort & rebuilt vwTasks with LoggedMinutes, AgentRunCount,
-- AgentCost, and AgentTokens virtual columns
-- =============================================================================

---------------------------------------------------------------------------
-- 1. TaskTimeEntry
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks."TaskTimeEntry" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TaskID" UUID NOT NULL,
 "PersonID" UUID NOT NULL,
 "WorkDate" DATE NOT NULL,
 "Minutes" INTEGER NOT NULL,
 "StartedAt" TIMESTAMPTZ NULL,
 "EndedAt" TIMESTAMPTZ NULL,
 "Notes" TEXT NULL,
 "Source" VARCHAR(20) NOT NULL DEFAULT 'Manual',
 "IsBillable" BOOLEAN NOT NULL DEFAULT FALSE,

 CONSTRAINT "PK_TaskTimeEntry" PRIMARY KEY ("ID"),
 CONSTRAINT "FK_TaskTimeEntry_Task"
 FOREIGN KEY ("TaskID") REFERENCES __mj_BizAppsTasks."Task"("ID"),
 CONSTRAINT "FK_TaskTimeEntry_Person"
 FOREIGN KEY ("PersonID") REFERENCES __mj_BizAppsCommon."Person"("ID"),
 CONSTRAINT "CK_TaskTimeEntry_Minutes"
 CHECK ("Minutes" > 0 AND "Minutes" <= 1440),
 CONSTRAINT "CK_TaskTimeEntry_Source"
 CHECK ("Source" IN ('Manual', 'Timer', 'Imported', 'Agent')),
 CONSTRAINT "CK_TaskTimeEntry_TimeRange"
 CHECK ("StartedAt" IS NULL OR "EndedAt" IS NULL OR "EndedAt" >= "StartedAt")
);

CREATE INDEX IF NOT EXISTS "IDX_TaskTimeEntry_Task_WorkDate"
    ON __mj_BizAppsTasks."TaskTimeEntry" ("TaskID", "WorkDate" DESC);

CREATE INDEX IF NOT EXISTS "IDX_TaskTimeEntry_Person_WorkDate"
    ON __mj_BizAppsTasks."TaskTimeEntry" ("PersonID", "WorkDate" DESC);

---------------------------------------------------------------------------
-- 2. TaskTimer
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks."TaskTimer" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TaskID" UUID NOT NULL,
 "PersonID" UUID NOT NULL,
 "StartedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 "Notes" TEXT NULL,
 "IsBillable" BOOLEAN NOT NULL DEFAULT FALSE,

 CONSTRAINT "PK_TaskTimer" PRIMARY KEY ("ID"),
 CONSTRAINT "FK_TaskTimer_Task"
 FOREIGN KEY ("TaskID") REFERENCES __mj_BizAppsTasks."Task"("ID"),
 CONSTRAINT "FK_TaskTimer_Person"
 FOREIGN KEY ("PersonID") REFERENCES __mj_BizAppsCommon."Person"("ID"),
 CONSTRAINT "UQ_TaskTimer_Person" UNIQUE ("PersonID")
);

CREATE INDEX IF NOT EXISTS "IDX_TaskTimer_Task"
    ON __mj_BizAppsTasks."TaskTimer" ("TaskID");

---------------------------------------------------------------------------
-- 3. TaskAgentRun
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks."TaskAgentRun" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TaskID" UUID NOT NULL,
 "AIAgentRunID" UUID NOT NULL,
 "Role" VARCHAR(30) NOT NULL DEFAULT 'Executed',
 "Notes" TEXT NULL,

 CONSTRAINT "PK_TaskAgentRun" PRIMARY KEY ("ID"),
 CONSTRAINT "FK_TaskAgentRun_Task"
 FOREIGN KEY ("TaskID") REFERENCES __mj_BizAppsTasks."Task"("ID"),
 CONSTRAINT "FK_TaskAgentRun_AIAgentRun"
 FOREIGN KEY ("AIAgentRunID") REFERENCES __mj."AIAgentRun"("ID"),
 CONSTRAINT "UQ_TaskAgentRun_Task_Run" UNIQUE ("TaskID", "AIAgentRunID"),
 CONSTRAINT "CK_TaskAgentRun_Role"
 CHECK ("Role" IN ('Executed', 'Assisted', 'Reviewed', 'Planned', 'Triaged'))
);

CREATE INDEX IF NOT EXISTS "IDX_TaskAgentRun_AIAgentRun"
    ON __mj_BizAppsTasks."TaskAgentRun" ("AIAgentRunID");

---------------------------------------------------------------------------
-- 4. Timesheet & TaskTimeEntry.TimesheetID FK
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks."Timesheet" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "PersonID" UUID NOT NULL,
 "PeriodStart" DATE NOT NULL,
 "PeriodEnd" DATE NOT NULL,
 "Status" VARCHAR(20) NOT NULL DEFAULT 'Draft',
 "SubmittedAt" TIMESTAMPTZ NULL,
 "SubmittedByUserID" UUID NULL,
 "TotalMinutes" INTEGER NOT NULL DEFAULT 0,
 "BillableMinutes" INTEGER NOT NULL DEFAULT 0,
 "Notes" TEXT NULL,

 CONSTRAINT "PK_Timesheet" PRIMARY KEY ("ID"),
 CONSTRAINT "FK_Timesheet_Person"
 FOREIGN KEY ("PersonID") REFERENCES __mj_BizAppsCommon."Person"("ID"),
 CONSTRAINT "FK_Timesheet_SubmittedByUser"
 FOREIGN KEY ("SubmittedByUserID") REFERENCES __mj."User"("ID"),
 CONSTRAINT "UQ_Timesheet_Person_Period"
 UNIQUE ("PersonID", "PeriodStart", "PeriodEnd"),
 CONSTRAINT "CK_Timesheet_Period"
 CHECK ("PeriodEnd" >= "PeriodStart"),
 CONSTRAINT "CK_Timesheet_Status"
 CHECK ("Status" IN ('Draft', 'Submitted', 'Approved', 'Rejected')),
 CONSTRAINT "CK_Timesheet_Totals"
 CHECK ("TotalMinutes" >= 0 AND "BillableMinutes" >= 0 AND "BillableMinutes" <= "TotalMinutes")
);

CREATE INDEX IF NOT EXISTS "IDX_Timesheet_Status_Period"
    ON __mj_BizAppsTasks."Timesheet" ("Status", "PeriodStart" DESC);

ALTER TABLE __mj_BizAppsTasks."TaskTimeEntry"
 ADD COLUMN IF NOT EXISTS "TimesheetID" UUID NULL
        CONSTRAINT "FK_TaskTimeEntry_Timesheet"
        REFERENCES __mj_BizAppsTasks."Timesheet"("ID");

CREATE INDEX IF NOT EXISTS "IDX_TaskTimeEntry_Timesheet"
    ON __mj_BizAppsTasks."TaskTimeEntry" ("TimesheetID")
    WHERE "TimesheetID" IS NOT NULL;

---------------------------------------------------------------------------
-- 5. TimesheetApproval
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks."TimesheetApproval" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TimesheetID" UUID NOT NULL,
 "SubmissionRound" INTEGER NOT NULL DEFAULT 1,
 "ScopeTaskID" UUID NULL,
 "ApprovalTaskID" UUID NOT NULL,
 "Minutes" INTEGER NOT NULL DEFAULT 0,
 "BillableMinutes" INTEGER NOT NULL DEFAULT 0,
 "EntryCount" INTEGER NOT NULL DEFAULT 0,
 "SnapshotHash" VARCHAR(64) NOT NULL,
 "Status" VARCHAR(20) NOT NULL DEFAULT 'Pending',
 "DecidedByPersonID" UUID NULL,
 "DecidedAt" TIMESTAMPTZ NULL,
 "DecisionNotes" TEXT NULL,

 CONSTRAINT "PK_TimesheetApproval" PRIMARY KEY ("ID"),
 CONSTRAINT "FK_TimesheetApproval_Timesheet"
 FOREIGN KEY ("TimesheetID") REFERENCES __mj_BizAppsTasks."Timesheet"("ID"),
 CONSTRAINT "FK_TimesheetApproval_ScopeTask"
 FOREIGN KEY ("ScopeTaskID") REFERENCES __mj_BizAppsTasks."Task"("ID"),
 CONSTRAINT "FK_TimesheetApproval_ApprovalTask"
 FOREIGN KEY ("ApprovalTaskID") REFERENCES __mj_BizAppsTasks."Task"("ID"),
 CONSTRAINT "FK_TimesheetApproval_Decider"
 FOREIGN KEY ("DecidedByPersonID") REFERENCES __mj_BizAppsCommon."Person"("ID"),
 CONSTRAINT "UQ_TimesheetApproval_ApprovalTask"
 UNIQUE ("ApprovalTaskID"),
 CONSTRAINT "CK_TimesheetApproval_Round"
 CHECK ("SubmissionRound" >= 1),
 CONSTRAINT "CK_TimesheetApproval_Status"
 CHECK ("Status" IN ('Pending', 'Approved', 'Rejected', 'Canceled')),
 CONSTRAINT "CK_TimesheetApproval_Totals"
 CHECK ("Minutes" >= 0 AND "BillableMinutes" >= 0 AND "BillableMinutes" <= "Minutes" AND "EntryCount" >= 0)
);

CREATE UNIQUE INDEX IF NOT EXISTS "UQ_TimesheetApproval_Part_Round"
    ON __mj_BizAppsTasks."TimesheetApproval" ("TimesheetID", "SubmissionRound", "ScopeTaskID");

CREATE INDEX IF NOT EXISTS "IDX_TimesheetApproval_Timesheet"
    ON __mj_BizAppsTasks."TimesheetApproval" ("TimesheetID", "SubmissionRound" DESC);

---------------------------------------------------------------------------
-- 6. TimeApprover
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks."TimeApprover" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "ApproverPersonID" UUID NOT NULL,
 "WorkerPersonID" UUID NULL,
 "ScopeTaskID" UUID NULL,
 "IncludeDescendants" BOOLEAN NOT NULL DEFAULT TRUE,
 "ScopeEntityID" UUID NULL,
 "ScopeRecordID" VARCHAR(450) NULL,
 "EffectiveFrom" DATE NULL,
 "EffectiveTo" DATE NULL,
 "IsActive" BOOLEAN NOT NULL DEFAULT TRUE,
 "Notes" TEXT NULL,

 CONSTRAINT "PK_TimeApprover" PRIMARY KEY ("ID"),
 CONSTRAINT "FK_TimeApprover_Approver"
 FOREIGN KEY ("ApproverPersonID") REFERENCES __mj_BizAppsCommon."Person"("ID"),
 CONSTRAINT "FK_TimeApprover_Worker"
 FOREIGN KEY ("WorkerPersonID") REFERENCES __mj_BizAppsCommon."Person"("ID"),
 CONSTRAINT "FK_TimeApprover_ScopeTask"
 FOREIGN KEY ("ScopeTaskID") REFERENCES __mj_BizAppsTasks."Task"("ID"),
 CONSTRAINT "FK_TimeApprover_ScopeEntity"
 FOREIGN KEY ("ScopeEntityID") REFERENCES __mj."Entity"("ID"),
 CONSTRAINT "CK_TimeApprover_NotSelf"
 CHECK ("WorkerPersonID" IS NULL OR "WorkerPersonID" <> "ApproverPersonID"),
 CONSTRAINT "CK_TimeApprover_EntityPair"
 CHECK (("ScopeEntityID" IS NULL AND "ScopeRecordID" IS NULL)
 OR ("ScopeEntityID" IS NOT NULL AND "ScopeRecordID" IS NOT NULL)),
 CONSTRAINT "CK_TimeApprover_Dates"
 CHECK ("EffectiveFrom" IS NULL OR "EffectiveTo" IS NULL OR "EffectiveTo" >= "EffectiveFrom")
);

CREATE INDEX IF NOT EXISTS "IDX_TimeApprover_Worker"
    ON __mj_BizAppsTasks."TimeApprover" ("WorkerPersonID", "IsActive");

CREATE INDEX IF NOT EXISTS "IDX_TimeApprover_ScopeTask"
    ON __mj_BizAppsTasks."TimeApprover" ("ScopeTaskID", "IsActive")
    WHERE "ScopeTaskID" IS NOT NULL;

CREATE INDEX IF NOT EXISTS "IDX_TimeApprover_ScopeRecord"
    ON __mj_BizAppsTasks."TimeApprover" ("ScopeEntityID", "ScopeRecordID", "IsActive")
    WHERE "ScopeEntityID" IS NOT NULL;

---------------------------------------------------------------------------
-- 7. TimesheetLink & TaskTimeEntryLink
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks."TimesheetLink" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TimesheetID" UUID NOT NULL,
 "EntityID" UUID NOT NULL,
 "RecordID" VARCHAR(450) NOT NULL,
 "Relationship" VARCHAR(30) NOT NULL DEFAULT 'Related',

 CONSTRAINT "PK_TimesheetLink" PRIMARY KEY ("ID"),
 CONSTRAINT "FK_TimesheetLink_Timesheet"
 FOREIGN KEY ("TimesheetID") REFERENCES __mj_BizAppsTasks."Timesheet"("ID"),
 CONSTRAINT "FK_TimesheetLink_Entity"
 FOREIGN KEY ("EntityID") REFERENCES __mj."Entity"("ID"),
 CONSTRAINT "UQ_TimesheetLink_Target"
 UNIQUE ("TimesheetID", "EntityID", "RecordID", "Relationship"),
 CONSTRAINT "CK_TimesheetLink_Rel"
 CHECK ("Relationship" IN ('PayrollBatch', 'Invoice', 'ExpenseReport', 'Related'))
);

CREATE INDEX IF NOT EXISTS "IDX_TimesheetLink_Entity_Record"
    ON __mj_BizAppsTasks."TimesheetLink" ("EntityID", "RecordID");

CREATE TABLE __mj_BizAppsTasks."TaskTimeEntryLink" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "TaskTimeEntryID" UUID NOT NULL,
 "EntityID" UUID NOT NULL,
 "RecordID" VARCHAR(450) NOT NULL,
 "Relationship" VARCHAR(30) NOT NULL DEFAULT 'Related',

 CONSTRAINT "PK_TaskTimeEntryLink" PRIMARY KEY ("ID"),
 CONSTRAINT "FK_TaskTimeEntryLink_Entry"
 FOREIGN KEY ("TaskTimeEntryID") REFERENCES __mj_BizAppsTasks."TaskTimeEntry"("ID"),
 CONSTRAINT "FK_TaskTimeEntryLink_Entity"
 FOREIGN KEY ("EntityID") REFERENCES __mj."Entity"("ID"),
 CONSTRAINT "UQ_TaskTimeEntryLink_Target"
 UNIQUE ("TaskTimeEntryID", "EntityID", "RecordID", "Relationship"),
 CONSTRAINT "CK_TaskTimeEntryLink_Rel"
 CHECK ("Relationship" IN ('InvoiceLine', 'JournalEntryLine', 'Commit', 'PullRequest', 'Related'))
);

CREATE INDEX IF NOT EXISTS "IDX_TaskTimeEntryLink_Entity_Record"
    ON __mj_BizAppsTasks."TaskTimeEntryLink" ("EntityID", "RecordID");

---------------------------------------------------------------------------
-- 8. TimesheetSchedule
---------------------------------------------------------------------------
CREATE TABLE __mj_BizAppsTasks."TimesheetSchedule" (
 "ID" UUID NOT NULL DEFAULT gen_random_uuid(),
 "PersonID" UUID NULL,
 "ScopeEntityID" UUID NULL,
 "ScopeRecordID" VARCHAR(450) NULL,
 "Cadence" VARCHAR(20) NOT NULL,
 "WeekStartDay" VARCHAR(10) NOT NULL DEFAULT 'Monday',
 "BiWeeklyAnchorDate" DATE NOT NULL DEFAULT '2026-01-05',
 "EffectiveFrom" DATE NOT NULL,
 "EffectiveTo" DATE NULL,
 "Notes" TEXT NULL,

 CONSTRAINT "PK_TimesheetSchedule" PRIMARY KEY ("ID"),
 CONSTRAINT "FK_TimesheetSchedule_Person"
 FOREIGN KEY ("PersonID") REFERENCES __mj_BizAppsCommon."Person"("ID"),
 CONSTRAINT "FK_TimesheetSchedule_Entity"
 FOREIGN KEY ("ScopeEntityID") REFERENCES __mj."Entity"("ID"),
 CONSTRAINT "CK_TimesheetSchedule_Cadence"
 CHECK ("Cadence" IN ('Weekly', 'BiWeekly', 'SemiMonthly', 'Monthly')),
 CONSTRAINT "CK_TimesheetSchedule_WeekStart"
 CHECK ("WeekStartDay" IN ('Monday', 'Sunday', 'Saturday')),
 CONSTRAINT "CK_TimesheetSchedule_EntityPair"
 CHECK (("ScopeEntityID" IS NULL AND "ScopeRecordID" IS NULL)
 OR ("ScopeEntityID" IS NOT NULL AND "ScopeRecordID" IS NOT NULL)),
 CONSTRAINT "CK_TimesheetSchedule_SingleTarget"
 CHECK ("PersonID" IS NULL OR "ScopeEntityID" IS NULL),
 CONSTRAINT "CK_TimesheetSchedule_Dates"
 CHECK ("EffectiveTo" IS NULL OR "EffectiveTo" >= "EffectiveFrom")
);

CREATE INDEX IF NOT EXISTS "IDX_TimesheetSchedule_Lookup"
    ON __mj_BizAppsTasks."TimesheetSchedule" ("PersonID", "ScopeEntityID", "ScopeRecordID", "EffectiveFrom" DESC);

---------------------------------------------------------------------------
-- 9. TaskType.RequiresAssigneeDecision
---------------------------------------------------------------------------
ALTER TABLE __mj_BizAppsTasks."TaskType"
 ADD COLUMN IF NOT EXISTS "RequiresAssigneeDecision" BOOLEAN NOT NULL
        CONSTRAINT "DF_TaskType_RequiresAssigneeDecision" DEFAULT (FALSE);

ALTER TABLE __mj_BizAppsTasks."TaskAgentRun"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TaskAgentRun */
ALTER TABLE __mj_BizAppsTasks."TaskAgentRun"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.TimesheetLink */
ALTER TABLE __mj_BizAppsTasks."TimesheetLink"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TimesheetLink */
ALTER TABLE __mj_BizAppsTasks."TimesheetLink"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.TaskTimer */
ALTER TABLE __mj_BizAppsTasks."TaskTimer"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TaskTimer */
ALTER TABLE __mj_BizAppsTasks."TaskTimer"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.TimesheetApproval */
ALTER TABLE __mj_BizAppsTasks."TimesheetApproval"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TimesheetApproval */
ALTER TABLE __mj_BizAppsTasks."TimesheetApproval"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.Timesheet */
ALTER TABLE __mj_BizAppsTasks."Timesheet"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.Timesheet */
ALTER TABLE __mj_BizAppsTasks."Timesheet"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.TaskTimeEntryLink */
ALTER TABLE __mj_BizAppsTasks."TaskTimeEntryLink"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TaskTimeEntryLink */
ALTER TABLE __mj_BizAppsTasks."TaskTimeEntryLink"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.TimesheetSchedule */
ALTER TABLE __mj_BizAppsTasks."TimesheetSchedule"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TimesheetSchedule */
ALTER TABLE __mj_BizAppsTasks."TimesheetSchedule"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.TaskTimeEntry */
ALTER TABLE __mj_BizAppsTasks."TaskTimeEntry"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TaskTimeEntry */
ALTER TABLE __mj_BizAppsTasks."TaskTimeEntry"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.TimeApprover */
ALTER TABLE __mj_BizAppsTasks."TimeApprover"
 ADD COLUMN IF NOT EXISTS "__mj_CreatedAt" TIMESTAMPTZ NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TimeApprover */
ALTER TABLE __mj_BizAppsTasks."TimeApprover"
 ADD COLUMN IF NOT EXISTS "__mj_UpdatedAt" TIMESTAMPTZ NULL;

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskAgentRun_TaskID" ON __mj_BizAppsTasks."TaskAgentRun" ("TaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskAgentRun_AIAgentRunID" ON __mj_BizAppsTasks."TaskAgentRun" ("AIAgentRunID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTimeEntry_TaskID" ON __mj_BizAppsTasks."TaskTimeEntry" ("TaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTimeEntry_PersonID" ON __mj_BizAppsTasks."TaskTimeEntry" ("PersonID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTimeEntry_TimesheetID" ON __mj_BizAppsTasks."TaskTimeEntry" ("TimesheetID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTimeEntryLink_TaskTimeEntryID" ON __mj_BizAppsTasks."TaskTimeEntryLink" ("TaskTimeEntryID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTimeEntryLink_EntityID" ON __mj_BizAppsTasks."TaskTimeEntryLink" ("EntityID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTimer_TaskID" ON __mj_BizAppsTasks."TaskTimer" ("TaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskTimer_PersonID" ON __mj_BizAppsTasks."TaskTimer" ("PersonID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnAssignActionID" ON __mj_BizAppsTasks."TaskType" ("OnAssignActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnCompleteActionID" ON __mj_BizAppsTasks."TaskType" ("OnCompleteActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnOverdueActionID" ON __mj_BizAppsTasks."TaskType" ("OnOverdueActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnPercentChangeActionID" ON __mj_BizAppsTasks."TaskType" ("OnPercentChangeActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnRejectActionID" ON __mj_BizAppsTasks."TaskType" ("OnRejectActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnCancelActionID" ON __mj_BizAppsTasks."TaskType" ("OnCancelActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnCreateActionID" ON __mj_BizAppsTasks."TaskType" ("OnCreateActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TaskType_OnStatusChangeActionID" ON __mj_BizAppsTasks."TaskType" ("OnStatusChangeActionID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_TypeID" ON __mj_BizAppsTasks."Task" ("TypeID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_CategoryID" ON __mj_BizAppsTasks."Task" ("CategoryID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_ParentID" ON __mj_BizAppsTasks."Task" ("ParentID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_CreatedByPersonID" ON __mj_BizAppsTasks."Task" ("CreatedByPersonID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Task_TaskTypeStatusID" ON __mj_BizAppsTasks."Task" ("TaskTypeStatusID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TimeApprover_ApproverPersonID" ON __mj_BizAppsTasks."TimeApprover" ("ApproverPersonID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TimeApprover_WorkerPersonID" ON __mj_BizAppsTasks."TimeApprover" ("WorkerPersonID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TimeApprover_ScopeTaskID" ON __mj_BizAppsTasks."TimeApprover" ("ScopeTaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TimeApprover_ScopeEntityID" ON __mj_BizAppsTasks."TimeApprover" ("ScopeEntityID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TimesheetApproval_TimesheetID" ON __mj_BizAppsTasks."TimesheetApproval" ("TimesheetID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TimesheetApproval_ScopeTaskID" ON __mj_BizAppsTasks."TimesheetApproval" ("ScopeTaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TimesheetApproval_ApprovalTaskID" ON __mj_BizAppsTasks."TimesheetApproval" ("ApprovalTaskID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TimesheetApproval_DecidedByPersonID" ON __mj_BizAppsTasks."TimesheetApproval" ("DecidedByPersonID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TimesheetLink_TimesheetID" ON __mj_BizAppsTasks."TimesheetLink" ("TimesheetID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TimesheetLink_EntityID" ON __mj_BizAppsTasks."TimesheetLink" ("EntityID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TimesheetSchedule_PersonID" ON __mj_BizAppsTasks."TimesheetSchedule" ("PersonID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_TimesheetSchedule_ScopeEntityID" ON __mj_BizAppsTasks."TimesheetSchedule" ("ScopeEntityID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Timesheet_PersonID" ON __mj_BizAppsTasks."Timesheet" ("PersonID");

CREATE INDEX IF NOT EXISTS "IDX_AUTO_MJ_FKEY_Timesheet_SubmittedByUserID" ON __mj_BizAppsTasks."Timesheet" ("SubmittedByUserID");


-- ===================== Views =====================

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskRootAgentEffort" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskRootAgentEffort';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskRootAgentEffort"
AS SELECT
    tar."TaskID",
    COUNT(*)                                                                  AS "AgentRunCount",
    SUM(COALESCE(r."TotalCostRollup",       r."TotalCost",       0))          AS "AgentCost",
    SUM(COALESCE(r."TotalTokensUsedRollup", r."TotalTokensUsed", 0))          AS "AgentTokens"
FROM __mj_BizAppsTasks."TaskAgentRun" tar
INNER JOIN __mj."vwAIAgentRuns" r ON r."ID" = tar."AIAgentRunID"
WHERE NOT EXISTS (
    SELECT 1
    FROM __mj_BizAppsTasks."TaskAgentRun" tar2
    WHERE tar2."TaskID"       = tar."TaskID"
      AND tar2."AIAgentRunID" <> tar."AIAgentRunID"
      AND r."ParentRunIDPath" LIKE '%/' || CAST(tar2."AIAgentRunID" AS VARCHAR(36)) || '/%'
)
GROUP BY "tar"."TaskID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskAgentRuns" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskAgentRuns';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskAgentRuns"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "MJAIAgentRun_AIAgentRunID"."RunName" AS "AIAgentRun"
FROM
    __mj_BizAppsTasks."TaskAgentRun" AS t
INNER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
INNER JOIN
    ${mjSchema}."AIAgentRun" AS "MJAIAgentRun_AIAgentRunID"
  ON
    t."AIAgentRunID" = "MJAIAgentRun_AIAgentRunID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskTimeEntryLinks" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskTimeEntryLinks';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskTimeEntryLinks"
AS SELECT
    t.*,
    "MJEntity_EntityID"."Name" AS "Entity"
FROM
    __mj_BizAppsTasks."TaskTimeEntryLink" AS t
INNER JOIN
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskTimers" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskTimers';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskTimers"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "mjBizAppsCommonPerson_PersonID"."DisplayName" AS "Person"
FROM
    __mj_BizAppsTasks."TaskTimer" AS t
INNER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
INNER JOIN
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTaskTimeEntries" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTaskTimeEntries';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTaskTimeEntries"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_TaskID"."Name" AS "Task",
    "mjBizAppsCommonPerson_PersonID"."DisplayName" AS "Person"
FROM
    __mj_BizAppsTasks."TaskTimeEntry" AS t
INNER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_TaskID"
  ON
    t."TaskID" = "mjBizAppsTasksTask_TaskID"."ID"
INNER JOIN
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTimesheetLinks" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTimesheetLinks';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTimesheetLinks"
AS SELECT
    t.*,
    "MJEntity_EntityID"."Name" AS "Entity"
FROM
    __mj_BizAppsTasks."TimesheetLink" AS t
INNER JOIN
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTimesheetSchedules" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTimesheetSchedules';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTimesheetSchedules"
AS SELECT
    t.*,
    "mjBizAppsCommonPerson_PersonID"."DisplayName" AS "Person",
    "MJEntity_ScopeEntityID"."Name" AS "ScopeEntity"
FROM
    __mj_BizAppsTasks."TimesheetSchedule" AS t
LEFT OUTER JOIN
    __mj_BizAppsCommon."Person" AS "mjBizAppsCommonPerson_PersonID"
  ON
    t."PersonID" = "mjBizAppsCommonPerson_PersonID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."Entity" AS "MJEntity_ScopeEntityID"
  ON
    t."ScopeEntityID" = "MJEntity_ScopeEntityID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTimesheets" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTimesheets';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTimesheets"
AS SELECT
    t.*,
    "mjBizAppsCommonPerson_PersonID"."DisplayName" AS "Person",
    "MJUser_SubmittedByUserID"."Name" AS "SubmittedByUser"
FROM
    __mj_BizAppsTasks."Timesheet" AS t
INNER JOIN
    __mj_BizAppsCommon."Person" AS "mjBizAppsCommonPerson_PersonID"
  ON
    t."PersonID" = "mjBizAppsCommonPerson_PersonID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."User" AS "MJUser_SubmittedByUserID"
  ON
    t."SubmittedByUserID" = "MJUser_SubmittedByUserID"."ID"$vsql$;
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTimesheetApprovals" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTimesheetApprovals';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTimesheetApprovals"
AS SELECT
    t.*,
    "mjBizAppsTasksTask_ScopeTaskID"."Name" AS "ScopeTask",
    "mjBizAppsTasksTask_ApprovalTaskID"."Name" AS "ApprovalTask",
    "mjBizAppsCommonPerson_DecidedByPersonID"."DisplayName" AS "DecidedByPerson"
FROM
    __mj_BizAppsTasks."TimesheetApproval" AS t
LEFT OUTER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_ScopeTaskID"
  ON
    t."ScopeTaskID" = "mjBizAppsTasksTask_ScopeTaskID"."ID"
INNER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_ApprovalTaskID"
  ON
    t."ApprovalTaskID" = "mjBizAppsTasksTask_ApprovalTaskID"."ID"
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

DROP VIEW IF EXISTS __mj_BizAppsTasks."vwTimeApprovers" CASCADE;
DO $do$
DECLARE
  v_target_schema CONSTANT TEXT := '__mj_BizAppsTasks';
  v_target_name CONSTANT TEXT := 'vwTimeApprovers';
  vsql CONSTANT TEXT := $vsql$CREATE OR REPLACE VIEW __mj_BizAppsTasks."vwTimeApprovers"
AS SELECT
    t.*,
    "mjBizAppsCommonPerson_ApproverPersonID"."DisplayName" AS "ApproverPerson",
    "mjBizAppsCommonPerson_WorkerPersonID"."DisplayName" AS "WorkerPerson",
    "mjBizAppsTasksTask_ScopeTaskID"."Name" AS "ScopeTask",
    "MJEntity_ScopeEntityID"."Name" AS "ScopeEntity"
FROM
    __mj_BizAppsTasks."TimeApprover" AS t
INNER JOIN
    __mj_BizAppsCommon."Person" AS "mjBizAppsCommonPerson_ApproverPersonID"
  ON
    t."ApproverPersonID" = "mjBizAppsCommonPerson_ApproverPersonID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsCommon."Person" AS "mjBizAppsCommonPerson_WorkerPersonID"
  ON
    t."WorkerPersonID" = "mjBizAppsCommonPerson_WorkerPersonID"."ID"
LEFT OUTER JOIN
    __mj_BizAppsTasks."Task" AS "mjBizAppsTasksTask_ScopeTaskID"
  ON
    t."ScopeTaskID" = "mjBizAppsTasksTask_ScopeTaskID"."ID"
LEFT OUTER JOIN
    ${mjSchema}."Entity" AS "MJEntity_ScopeEntityID"
  ON
    t."ScopeEntityID" = "MJEntity_ScopeEntityID"."ID"$vsql$;
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
    COALESCE(a."AssignmentsCount", 0)                   AS "AssignmentsCount",
    COALESCE(c."CommentsCount", 0)                      AS "CommentsCount",
    COALESCE(te."LoggedMinutes", 0)                     AS "LoggedMinutes",
    COALESCE(ae."AgentRunCount", 0)                     AS "AgentRunCount",
    COALESCE(ae."AgentCost", CAST(0 AS DECIMAL(19, 8))) AS "AgentCost",
    COALESCE(ae."AgentTokens", 0)                       AS "AgentTokens"
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
) AS c ON c."TaskID" = g."ID"
LEFT OUTER JOIN (
    SELECT "TaskID", SUM("Minutes") AS "LoggedMinutes"
    FROM __mj_BizAppsTasks."TaskTimeEntry"
    GROUP BY "TaskID"
) AS "te" ON te."TaskID" = g."ID"
LEFT OUTER JOIN
    __mj_BizAppsTasks."vwTaskRootAgentEffort" AS "ae"
    ON ae."TaskID" = g."ID"$vsql$;
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
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskAgentRun]
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @AIAgentRunID UUID,
--     @Role VARCHAR(30) = NULL,
--     @Notes...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskAgentRun]
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @AIAgentRunID UUID = NULL,
--     @Role VARCHAR(30) = NULL,
--    ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskAgentRun]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskAgentRun]
--     WHERE
--         [ID] = @...

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
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskTimeEntryLink]
--     @ID UUID = NULL,
--     @TaskTimeEntryID UUID,
--     @EntityID UUID,
--     @RecordID VARCHAR(450),
--   ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskTimeEntryLink]
--     @ID UUID,
--     @TaskTimeEntryID UUID = NULL,
--     @EntityID UUID = NULL,
--     @RecordID TEXT(4...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskTimeEntryLink]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskTimeEntryLink]
--     WHERE
--       ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskTimer]
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @PersonID UUID,
--     @StartedAt datetimeoffset = NULL,
--     @Notes...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskTimer]
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @PersonID UUID = NULL,
--     @StartedAt datetimeoffset = NULL,
--    ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskTimer]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskTimer]
--     WHERE
--         [ID] = @ID
-- 
-- 
--  ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTaskTimeEntry]
--     @ID UUID = NULL,
--     @TaskID UUID,
--     @PersonID UUID,
--     @WorkDate date,
--     @Minutes INTEGER,
--     @S...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTaskTimeEntry]
--     @ID UUID,
--     @TaskID UUID = NULL,
--     @PersonID UUID = NULL,
--     @WorkDate date = NULL,
--     @Minut...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTaskTimeEntry]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TaskTimeEntry]
--     WHERE
--         [ID] =...

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
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTimesheetLink]
--     @ID UUID = NULL,
--     @TimesheetID UUID,
--     @EntityID UUID,
--     @RecordID VARCHAR(450),
--     @Relat...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTimesheetLink]
--     @ID UUID,
--     @TimesheetID UUID = NULL,
--     @EntityID UUID = NULL,
--     @RecordID VARCHAR(450) = NU...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTimesheetLink]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TimesheetLink]
--     WHERE
--         [ID] =...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTimesheetSchedule]
--     @ID UUID = NULL,
--     @PersonID_Clear bit = 0,
--     @PersonID UUID = NULL,
--     @ScopeEntityID_Clear bit = 0,
-- ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTimesheetSchedule]
--     @ID UUID,
--     @PersonID_Clear bit = 0,
--     @PersonID UUID = NULL,
--     @ScopeEntityID_Clear bit = 0,
--     @Sc...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTimesheetSchedule]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TimesheetSchedule]
--     WHERE
--       ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTimesheet]
--     @ID UUID = NULL,
--     @PersonID UUID,
--     @PeriodStart date,
--     @PeriodEnd date,
--     @Status VARCHAR(20) = NULL,
--  ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTimesheet]
--     @ID UUID,
--     @PersonID UUID = NULL,
--     @PeriodStart date = NULL,
--     @PeriodEnd date = NULL,
--     @Status TEXT...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTimesheet]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[Timesheet]
--     WHERE
--         [ID] = @ID
-- 
-- 
--  ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTimesheetApproval]
--     @ID UUID = NULL,
--     @TimesheetID UUID,
--     @SubmissionRound INTEGER = NULL,
--     @ScopeTaskID_Clear bit = 0,
--   ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTimesheetApproval]
--     @ID UUID,
--     @TimesheetID UUID = NULL,
--     @SubmissionRound INTEGER = NULL,
--     @ScopeTaskID_Clear bit = 0,
--   ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTimesheetApproval]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TimesheetApproval]
--     WHERE
--       ...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spCreateTimeApprover]
--     @ID UUID = NULL,
--     @ApproverPersonID UUID,
--     @WorkerPersonID_Clear bit = 0,
--     @WorkerPersonID uniqueidenti...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spUpdateTimeApprover]
--     @ID UUID,
--     @ApproverPersonID UUID = NULL,
--     @WorkerPersonID_Clear bit = 0,
--     @WorkerPersonID uniqueidenti...

-- SKIPPED: procedure (auto-conversion not supported)
-- CREATE PROCEDURE [__mj_BizAppsTasks].[spDeleteTimeApprover]
--     @ID UUID
-- AS
-- BEGIN
--     SET NOCOUNT ON;
-- 
--     DELETE FROM
--         [__mj_BizAppsTasks].[TimeApprover]
--     WHERE
--         [ID] = @...


-- ===================== Triggers =====================

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTaskAgentRun
-- ON __mj_BizAppsTasks."TaskAgentRun"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskAgentRun"
--     SET
 

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTaskType
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
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTaskTimeEntryLink
-- ON __mj_BizAppsTasks."TaskTimeEntryLink"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskTimeEntry

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks".trgUpdateTaskTimer
-- ON __mj_BizAppsTasks."TaskTimer"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskTimer"
--     SET
--         __

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTaskTimeEntry
-- ON __mj_BizAppsTasks."TaskTimeEntry"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TaskTimeEntry"
--     SE

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

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTimesheetLink
-- ON __mj_BizAppsTasks."TimesheetLink"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TimesheetLink"
--     SE

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTimesheetSchedule
-- ON __mj_BizAppsTasks."TimesheetSchedule"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TimesheetSche

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks".trgUpdateTimesheet
-- ON __mj_BizAppsTasks."Timesheet"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."Timesheet"
--     SET
--         __

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks].trgUpdateTimesheetApproval
-- ON __mj_BizAppsTasks."TimesheetApproval"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TimesheetAppr

-- SKIPPED: trigger (auto-conversion not supported)
-- CREATE TRIGGER [__mj_BizAppsTasks".trgUpdateTimeApprover
-- ON __mj_BizAppsTasks."TimeApprover"
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     UPDATE
--         __mj_BizAppsTasks."TimeApprover"
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
         'ea40801a-df1b-443a-b0d3-ea0415645603',
         'MJ_BizApps_Tasks: Task Time Entries',
         'Task Time Entries',
         'Individual time entries logged by a person against a task on a specific business calendar date.',
         NULL,
         'TaskTimeEntry',
         'vwTaskTimeEntries',
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

/* SQL generated to add entity MJ_BizApps_Tasks: Task Time Entries to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO ${mjSchema}."ApplicationEntity"
                                    ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'ea40801a-df1b-443a-b0d3-ea0415645603', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM ${mjSchema}."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Time Entries for role UI */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('ea40801a-df1b-443a-b0d3-ea0415645603' AS UUID), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 0, 0, 0, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('ea40801a-df1b-443a-b0d3-ea0415645603' AS UUID) AND "RoleID" = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Time Entries for role Developer */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('ea40801a-df1b-443a-b0d3-ea0415645603' AS UUID), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('ea40801a-df1b-443a-b0d3-ea0415645603' AS UUID) AND "RoleID" = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Time Entries for role Integration */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('ea40801a-df1b-443a-b0d3-ea0415645603' AS UUID), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('ea40801a-df1b-443a-b0d3-ea0415645603' AS UUID) AND "RoleID" = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Timers */

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
         '87c6f7ff-3752-48d2-b382-30b9a4d1cf51',
         'MJ_BizApps_Tasks: Task Timers',
         'Task Timers',
         'Currently running task stopwatch per person. At most one row per PersonID exists at any time; stopping a timer deletes the row and writes TaskTimeEntry rows.',
         NULL,
         'TaskTimer',
         'vwTaskTimers',
         '__mj_BizAppsTasks',
         TRUE,
         TRUE,
         FALSE,
         FALSE,
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

/* SQL generated to add entity MJ_BizApps_Tasks: Task Timers to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO ${mjSchema}."ApplicationEntity"
                                    ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '87c6f7ff-3752-48d2-b382-30b9a4d1cf51', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM ${mjSchema}."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Timers for role UI */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('87c6f7ff-3752-48d2-b382-30b9a4d1cf51' AS UUID), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 0, 0, 0, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('87c6f7ff-3752-48d2-b382-30b9a4d1cf51' AS UUID) AND "RoleID" = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Timers for role Developer */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('87c6f7ff-3752-48d2-b382-30b9a4d1cf51' AS UUID), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('87c6f7ff-3752-48d2-b382-30b9a4d1cf51' AS UUID) AND "RoleID" = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Timers for role Integration */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('87c6f7ff-3752-48d2-b382-30b9a4d1cf51' AS UUID), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('87c6f7ff-3752-48d2-b382-30b9a4d1cf51' AS UUID) AND "RoleID" = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Agent Runs */

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
         '03a6558c-487b-4a91-b7c6-0bc1b54a65f3',
         'MJ_BizApps_Tasks: Task Agent Runs',
         'Task Agent Runs',
         'Links a task to a MemberJunction AI Agent Run so agent effort (runs, tokens, cost, wall-clock duration) is attributed alongside human time.',
         NULL,
         'TaskAgentRun',
         'vwTaskAgentRuns',
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

/* SQL generated to add entity MJ_BizApps_Tasks: Task Agent Runs to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO ${mjSchema}."ApplicationEntity"
                                    ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '03a6558c-487b-4a91-b7c6-0bc1b54a65f3', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM ${mjSchema}."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Agent Runs for role UI */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('03a6558c-487b-4a91-b7c6-0bc1b54a65f3' AS UUID), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 0, 0, 0, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('03a6558c-487b-4a91-b7c6-0bc1b54a65f3' AS UUID) AND "RoleID" = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Agent Runs for role Developer */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('03a6558c-487b-4a91-b7c6-0bc1b54a65f3' AS UUID), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('03a6558c-487b-4a91-b7c6-0bc1b54a65f3' AS UUID) AND "RoleID" = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Agent Runs for role Integration */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('03a6558c-487b-4a91-b7c6-0bc1b54a65f3' AS UUID), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('03a6558c-487b-4a91-b7c6-0bc1b54a65f3' AS UUID) AND "RoleID" = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Timesheets */

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
         'ed90ee09-0d39-4298-93dc-77c057fce97a',
         'MJ_BizApps_Tasks: Timesheets',
         'Timesheets',
         'Period timesheet header for a person, grouping task time entries across a date range for submission and approval.',
         NULL,
         'Timesheet',
         'vwTimesheets',
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

/* SQL generated to add entity MJ_BizApps_Tasks: Timesheets to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO ${mjSchema}."ApplicationEntity"
                                    ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'ed90ee09-0d39-4298-93dc-77c057fce97a', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM ${mjSchema}."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheets for role UI */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('ed90ee09-0d39-4298-93dc-77c057fce97a' AS UUID), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 0, 0, 0, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('ed90ee09-0d39-4298-93dc-77c057fce97a' AS UUID) AND "RoleID" = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheets for role Developer */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('ed90ee09-0d39-4298-93dc-77c057fce97a' AS UUID), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('ed90ee09-0d39-4298-93dc-77c057fce97a' AS UUID) AND "RoleID" = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheets for role Integration */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('ed90ee09-0d39-4298-93dc-77c057fce97a' AS UUID), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('ed90ee09-0d39-4298-93dc-77c057fce97a' AS UUID) AND "RoleID" = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Timesheet Approvals */

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
         '02c38b1a-6987-463d-8b6b-4c86e0887d42',
         'MJ_BizApps_Tasks: Timesheet Approvals',
         'Timesheet Approvals',
         'Per-project approval slice of a submitted timesheet, backed by a real approval Task in the Tasks inbox.',
         NULL,
         'TimesheetApproval',
         'vwTimesheetApprovals',
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

/* SQL generated to add entity MJ_BizApps_Tasks: Timesheet Approvals to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO ${mjSchema}."ApplicationEntity"
                                    ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '02c38b1a-6987-463d-8b6b-4c86e0887d42', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM ${mjSchema}."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Approvals for role UI */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('02c38b1a-6987-463d-8b6b-4c86e0887d42' AS UUID), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 0, 0, 0, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('02c38b1a-6987-463d-8b6b-4c86e0887d42' AS UUID) AND "RoleID" = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Approvals for role Developer */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('02c38b1a-6987-463d-8b6b-4c86e0887d42' AS UUID), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('02c38b1a-6987-463d-8b6b-4c86e0887d42' AS UUID) AND "RoleID" = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Approvals for role Integration */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('02c38b1a-6987-463d-8b6b-4c86e0887d42' AS UUID), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('02c38b1a-6987-463d-8b6b-4c86e0887d42' AS UUID) AND "RoleID" = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Time Approvers */

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
         'c82f6ef9-b9c4-4387-8c10-f5b59fa24133',
         'MJ_BizApps_Tasks: Time Approvers',
         'Time Approvers',
         'Configurable directory of who approves whose time, optionally scoped to a specific worker, root project task, or external entity record.',
         NULL,
         'TimeApprover',
         'vwTimeApprovers',
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

/* SQL generated to add entity MJ_BizApps_Tasks: Time Approvers to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO ${mjSchema}."ApplicationEntity"
                                    ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'c82f6ef9-b9c4-4387-8c10-f5b59fa24133', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM ${mjSchema}."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Time Approvers for role UI */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('c82f6ef9-b9c4-4387-8c10-f5b59fa24133' AS UUID), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 0, 0, 0, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('c82f6ef9-b9c4-4387-8c10-f5b59fa24133' AS UUID) AND "RoleID" = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Time Approvers for role Developer */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('c82f6ef9-b9c4-4387-8c10-f5b59fa24133' AS UUID), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('c82f6ef9-b9c4-4387-8c10-f5b59fa24133' AS UUID) AND "RoleID" = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Time Approvers for role Integration */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('c82f6ef9-b9c4-4387-8c10-f5b59fa24133' AS UUID), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('c82f6ef9-b9c4-4387-8c10-f5b59fa24133' AS UUID) AND "RoleID" = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Timesheet Links */

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
         'd594b91d-4de0-4d20-8d71-21f041fa505d',
         'MJ_BizApps_Tasks: Timesheet Links',
         'Timesheet Links',
         'Polymorphic links from a Timesheet to external records such as payroll batches, invoices, or expense reports.',
         NULL,
         'TimesheetLink',
         'vwTimesheetLinks',
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

/* SQL generated to add entity MJ_BizApps_Tasks: Timesheet Links to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO ${mjSchema}."ApplicationEntity"
                                    ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'd594b91d-4de0-4d20-8d71-21f041fa505d', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM ${mjSchema}."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Links for role UI */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('d594b91d-4de0-4d20-8d71-21f041fa505d' AS UUID), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 0, 0, 0, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('d594b91d-4de0-4d20-8d71-21f041fa505d' AS UUID) AND "RoleID" = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Links for role Developer */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('d594b91d-4de0-4d20-8d71-21f041fa505d' AS UUID), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('d594b91d-4de0-4d20-8d71-21f041fa505d' AS UUID) AND "RoleID" = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Links for role Integration */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('d594b91d-4de0-4d20-8d71-21f041fa505d' AS UUID), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('d594b91d-4de0-4d20-8d71-21f041fa505d' AS UUID) AND "RoleID" = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Time Entry Links */

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
         '5a25b67b-d67d-453f-8340-94bf69cf8cee',
         'MJ_BizApps_Tasks: Task Time Entry Links',
         'Task Time Entry Links',
         'Polymorphic links from a TaskTimeEntry to external records such as invoice lines, journal entry lines, commits, or pull requests.',
         NULL,
         'TaskTimeEntryLink',
         'vwTaskTimeEntryLinks',
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

/* SQL generated to add entity MJ_BizApps_Tasks: Task Time Entry Links to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO ${mjSchema}."ApplicationEntity"
                                    ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '5a25b67b-d67d-453f-8340-94bf69cf8cee', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM ${mjSchema}."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Time Entry Links for role UI */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('5a25b67b-d67d-453f-8340-94bf69cf8cee' AS UUID), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 0, 0, 0, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('5a25b67b-d67d-453f-8340-94bf69cf8cee' AS UUID) AND "RoleID" = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Time Entry Links for role Developer */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('5a25b67b-d67d-453f-8340-94bf69cf8cee' AS UUID), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('5a25b67b-d67d-453f-8340-94bf69cf8cee' AS UUID) AND "RoleID" = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Time Entry Links for role Integration */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('5a25b67b-d67d-453f-8340-94bf69cf8cee' AS UUID), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('5a25b67b-d67d-453f-8340-94bf69cf8cee' AS UUID) AND "RoleID" = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Timesheet Schedules */

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
         '6a27830f-a203-4d3e-8adf-b1085e1f908c',
         'MJ_BizApps_Tasks: Timesheet Schedules',
         'Timesheet Schedules',
         'Effective-dated timesheet period cadence schedule, globally or scoped to a specific Person or external entity record.',
         NULL,
         'TimesheetSchedule',
         'vwTimesheetSchedules',
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

/* SQL generated to add entity MJ_BizApps_Tasks: Timesheet Schedules to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */

INSERT INTO ${mjSchema}."ApplicationEntity"
                                    ("ApplicationID", "EntityID", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt") VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '6a27830f-a203-4d3e-8adf-b1085e1f908c', (SELECT COALESCE(MAX("Sequence"),0)+1 FROM ${mjSchema}."ApplicationEntity" WHERE "ApplicationID" = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), NOW(), NOW());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Schedules for role UI */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('6a27830f-a203-4d3e-8adf-b1085e1f908c' AS UUID), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 0, 0, 0, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('6a27830f-a203-4d3e-8adf-b1085e1f908c' AS UUID) AND "RoleID" = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Schedules for role Developer */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('6a27830f-a203-4d3e-8adf-b1085e1f908c' AS UUID), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('6a27830f-a203-4d3e-8adf-b1085e1f908c' AS UUID) AND "RoleID" = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Schedules for role Integration */

INSERT INTO ${mjSchema}."EntityPermission"
                ("EntityID", "RoleID", "Type", "CanRead", "CanCreate", "CanUpdate", "CanDelete", "__mj_CreatedAt", "__mj_UpdatedAt")
              SELECT CAST('6a27830f-a203-4d3e-8adf-b1085e1f908c' AS UUID), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID), 'Allow', 1, 1, 1, 1, NOW(), NOW()
              WHERE NOT EXISTS (
                SELECT 1 FROM ${mjSchema}."EntityPermission"
                WHERE "EntityID" = CAST('6a27830f-a203-4d3e-8adf-b1085e1f908c' AS UUID) AND "RoleID" = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS UUID) AND "Type" = 'Allow'
              );

/* SQL text to update existing entities from schema */

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks."TaskAgentRun" */
UPDATE __mj_BizAppsTasks."TaskAgentRun" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.TaskAgentRun */
ALTER TABLE __mj_BizAppsTasks."TaskAgentRun" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."TaskAgentRun"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks."TaskAgentRun" */
UPDATE __mj_BizAppsTasks."TaskAgentRun" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TaskAgentRun */
ALTER TABLE __mj_BizAppsTasks."TaskAgentRun" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."TaskAgentRun"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks."TimesheetLink" */
UPDATE __mj_BizAppsTasks."TimesheetLink" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.TimesheetLink */
ALTER TABLE __mj_BizAppsTasks."TimesheetLink" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."TimesheetLink"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks."TimesheetLink" */
UPDATE __mj_BizAppsTasks."TimesheetLink" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TimesheetLink */
ALTER TABLE __mj_BizAppsTasks."TimesheetLink" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."TimesheetLink"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks."TaskTimer" */
UPDATE __mj_BizAppsTasks."TaskTimer" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.TaskTimer */
ALTER TABLE __mj_BizAppsTasks."TaskTimer" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."TaskTimer"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks."TaskTimer" */
UPDATE __mj_BizAppsTasks."TaskTimer" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TaskTimer */
ALTER TABLE __mj_BizAppsTasks."TaskTimer" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."TaskTimer"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks."TimesheetApproval" */
UPDATE __mj_BizAppsTasks."TimesheetApproval" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.TimesheetApproval */
ALTER TABLE __mj_BizAppsTasks."TimesheetApproval" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."TimesheetApproval"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks."TimesheetApproval" */
UPDATE __mj_BizAppsTasks."TimesheetApproval" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TimesheetApproval */
ALTER TABLE __mj_BizAppsTasks."TimesheetApproval" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."TimesheetApproval"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks."Timesheet" */
UPDATE __mj_BizAppsTasks."Timesheet" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.Timesheet */
ALTER TABLE __mj_BizAppsTasks."Timesheet" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."Timesheet"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks."Timesheet" */
UPDATE __mj_BizAppsTasks."Timesheet" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.Timesheet */
ALTER TABLE __mj_BizAppsTasks."Timesheet" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."Timesheet"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks."TaskTimeEntryLink" */
UPDATE __mj_BizAppsTasks."TaskTimeEntryLink" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.TaskTimeEntryLink */
ALTER TABLE __mj_BizAppsTasks."TaskTimeEntryLink" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."TaskTimeEntryLink"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks."TaskTimeEntryLink" */
UPDATE __mj_BizAppsTasks."TaskTimeEntryLink" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TaskTimeEntryLink */
ALTER TABLE __mj_BizAppsTasks."TaskTimeEntryLink" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."TaskTimeEntryLink"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks."TimesheetSchedule" */
UPDATE __mj_BizAppsTasks."TimesheetSchedule" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.TimesheetSchedule */
ALTER TABLE __mj_BizAppsTasks."TimesheetSchedule" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."TimesheetSchedule"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks."TimesheetSchedule" */
UPDATE __mj_BizAppsTasks."TimesheetSchedule" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TimesheetSchedule */
ALTER TABLE __mj_BizAppsTasks."TimesheetSchedule" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."TimesheetSchedule"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks."TaskTimeEntry" */
UPDATE __mj_BizAppsTasks."TaskTimeEntry" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.TaskTimeEntry */
ALTER TABLE __mj_BizAppsTasks."TaskTimeEntry" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."TaskTimeEntry"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks."TaskTimeEntry" */
UPDATE __mj_BizAppsTasks."TaskTimeEntry" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TaskTimeEntry */
ALTER TABLE __mj_BizAppsTasks."TaskTimeEntry" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."TaskTimeEntry"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks."TimeApprover" */
UPDATE __mj_BizAppsTasks."TimeApprover" SET "__mj_CreatedAt" = NOW() WHERE "__mj_CreatedAt" IS NULL;

/* SQL text to add special date field __mj_CreatedAt to entity __mj_BizAppsTasks.TimeApprover */
ALTER TABLE __mj_BizAppsTasks."TimeApprover" ALTER COLUMN "__mj_CreatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."TimeApprover"
  ALTER COLUMN "__mj_CreatedAt" SET DEFAULT NOW();

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks."TimeApprover" */
UPDATE __mj_BizAppsTasks."TimeApprover" SET "__mj_UpdatedAt" = NOW() WHERE "__mj_UpdatedAt" IS NULL;

/* SQL text to add special date field __mj_UpdatedAt to entity __mj_BizAppsTasks.TimeApprover */
ALTER TABLE __mj_BizAppsTasks."TimeApprover" ALTER COLUMN "__mj_UpdatedAt" SET NOT NULL;

ALTER TABLE __mj_BizAppsTasks."TimeApprover"
  ALTER COLUMN "__mj_UpdatedAt" SET DEFAULT NOW();

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '10a4264b-9519-4c9d-8f43-855a97d402a7' OR ("EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND "Name" = 'ID')
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
        '10a4264b-9519-4c9d-8f43-855a97d402a7',
        '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- "Entity": "MJ_BizApps_Tasks": "Task" "Agent" "Runs"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
        'ID',
        'ID',
        'Primary key for the task agent run link.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '16554986-6995-435a-a9f6-62c837d5fd72' OR ("EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND "Name" = 'TaskID')
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
        '16554986-6995-435a-a9f6-62c837d5fd72',
        '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- "Entity": "MJ_BizApps_Tasks": "Task" "Agent" "Runs"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
        'TaskID',
        'Task ID',
        'The task the AI agent run contributed to.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'ab51a173-82c1-4f42-86a6-8cc30ccd8048' OR ("EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND "Name" = 'AIAgentRunID')
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
        'ab51a173-82c1-4f42-86a6-8cc30ccd8048',
        '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- "Entity": "MJ_BizApps_Tasks": "Task" "Agent" "Runs"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
        'AIAgentRunID',
        'AI Agent Run ID',
        'The MemberJunction AI Agent Run linked to the task.',
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
        '5190AF93-4C39-4429-BDAA-0AEB492A0256',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '8ad0134d-2f51-4fdd-baf2-4fe7cb8f8f82' OR ("EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND "Name" = 'Role')
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
        '8ad0134d-2f51-4fdd-baf2-4fe7cb8f8f82',
        '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- "Entity": "MJ_BizApps_Tasks": "Task" "Agent" "Runs"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
        'Role',
        'Role',
        'How the agent run contributed to the task: Executed, Assisted, Reviewed, Planned, or Triaged.',
        'TEXT',
        60,
        0,
        0,
        FALSE,
        'Executed',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '008c8596-40fc-49db-bea2-a6659a1d2de9' OR ("EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND "Name" = 'Notes')
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
        '008c8596-40fc-49db-bea2-a6659a1d2de9',
        '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- "Entity": "MJ_BizApps_Tasks": "Task" "Agent" "Runs"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
        'Notes',
        'Notes',
        'Optional notes describing what the agent run did for the task.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '6e54ffef-dbd9-483c-a4c4-c9a56fc37326' OR ("EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND "Name" = '__mj_CreatedAt')
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
        '6e54ffef-dbd9-483c-a4c4-c9a56fc37326',
        '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- "Entity": "MJ_BizApps_Tasks": "Task" "Agent" "Runs"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'cf1cfefe-a9c1-41ed-9a9f-557063415d94' OR ("EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND "Name" = '__mj_UpdatedAt')
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
        'cf1cfefe-a9c1-41ed-9a9f-557063415d94',
        '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- "Entity": "MJ_BizApps_Tasks": "Task" "Agent" "Runs"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '008647c6-3662-4df7-8897-c6a98c0c5330' OR ("EntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND "Name" = 'ID')
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
        '008647c6-3662-4df7-8897-c6a98c0c5330',
        'D594B91D-4DE0-4D20-8D71-21F041FA505D', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Links"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D'),
        'ID',
        'ID',
        'Primary key for the timesheet link.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '19dcc9ea-6024-4c8c-a595-651b4d7915a7' OR ("EntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND "Name" = 'TimesheetID')
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
        '19dcc9ea-6024-4c8c-a595-651b4d7915a7',
        'D594B91D-4DE0-4D20-8D71-21F041FA505D', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Links"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D'),
        'TimesheetID',
        'Timesheet ID',
        'The Timesheet being linked.',
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
        'ED90EE09-0D39-4298-93DC-77C057FCE97A',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'd14542b0-ed38-4ecd-83cf-6645eeb5be2e' OR ("EntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND "Name" = 'EntityID')
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
        'd14542b0-ed38-4ecd-83cf-6645eeb5be2e',
        'D594B91D-4DE0-4D20-8D71-21F041FA505D', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Links"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D'),
        'EntityID',
        'Entity ID',
        'Target MemberJunction Entity ID for the linked external record.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'fa2e8a87-cb72-4491-ab69-706bd03f32da' OR ("EntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND "Name" = 'RecordID')
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
        'fa2e8a87-cb72-4491-ab69-706bd03f32da',
        'D594B91D-4DE0-4D20-8D71-21F041FA505D', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Links"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D'),
        'RecordID',
        'Record ID',
        'Primary key value of the linked record in EntityID.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '2ea93151-5257-4972-be84-6cb41d3541d8' OR ("EntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND "Name" = 'Relationship')
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
        '2ea93151-5257-4972-be84-6cb41d3541d8',
        'D594B91D-4DE0-4D20-8D71-21F041FA505D', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Links"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D'),
        'Relationship',
        'Relationship',
        'Semantic relationship of the linked record to the timesheet: PayrollBatch, Invoice, ExpenseReport, or Related.',
        'TEXT',
        60,
        0,
        0,
        FALSE,
        'Related',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'b2dbcb2d-38ba-49c7-9872-c6add8479fd8' OR ("EntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND "Name" = '__mj_CreatedAt')
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
        'b2dbcb2d-38ba-49c7-9872-c6add8479fd8',
        'D594B91D-4DE0-4D20-8D71-21F041FA505D', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Links"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '6d6c70c4-0895-4f55-bb81-e070940b5464' OR ("EntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND "Name" = '__mj_UpdatedAt')
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
        '6d6c70c4-0895-4f55-bb81-e070940b5464',
        'D594B91D-4DE0-4D20-8D71-21F041FA505D', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Links"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'dec85961-3349-4f5e-a436-d24fc71ef6ff' OR ("EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND "Name" = 'ID')
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
        'dec85961-3349-4f5e-a436-d24fc71ef6ff',
        '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- "Entity": "MJ_BizApps_Tasks": "Task" "Timers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
        'ID',
        'ID',
        'Primary key for the running timer.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'c331ddd2-06cc-4dea-833f-bdaeafc80db8' OR ("EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND "Name" = 'TaskID')
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
        'c331ddd2-06cc-4dea-833f-bdaeafc80db8',
        '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- "Entity": "MJ_BizApps_Tasks": "Task" "Timers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
        'TaskID',
        'Task ID',
        'The task currently being timed.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '033e45df-d452-4846-bf76-537937eef114' OR ("EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND "Name" = 'PersonID')
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
        '033e45df-d452-4846-bf76-537937eef114',
        '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- "Entity": "MJ_BizApps_Tasks": "Task" "Timers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
        'PersonID',
        'Person ID',
        'The Person whose stopwatch is running (unique across TaskTimer).',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '1ae44efe-9590-4af3-8546-3a2388b2ef24' OR ("EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND "Name" = 'StartedAt')
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
        '1ae44efe-9590-4af3-8546-3a2388b2ef24',
        '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- "Entity": "MJ_BizApps_Tasks": "Task" "Timers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
        'StartedAt',
        'Started At',
        'Timestamp when the timer was started.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '3df0d48b-c3ca-4578-9de3-0970425d1bba' OR ("EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND "Name" = 'Notes')
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
        '3df0d48b-c3ca-4578-9de3-0970425d1bba',
        '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- "Entity": "MJ_BizApps_Tasks": "Task" "Timers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
        'Notes',
        'Notes',
        'Draft work notes carried over into the resulting TaskTimeEntry rows when the timer stops.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '9c62fb30-1e7d-4ed3-b081-3fd0e9f38ae3' OR ("EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND "Name" = 'IsBillable')
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
        '9c62fb30-1e7d-4ed3-b081-3fd0e9f38ae3',
        '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- "Entity": "MJ_BizApps_Tasks": "Task" "Timers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
        'IsBillable',
        'Is Billable',
        'Billable flag carried over into the resulting TaskTimeEntry rows when the timer stops.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '45e7a083-2d91-4c04-8442-ad5cde338a7f' OR ("EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND "Name" = '__mj_CreatedAt')
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
        '45e7a083-2d91-4c04-8442-ad5cde338a7f',
        '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- "Entity": "MJ_BizApps_Tasks": "Task" "Timers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '4bc42f17-02da-4118-8f21-df320a41cb17' OR ("EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND "Name" = '__mj_UpdatedAt')
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
        '4bc42f17-02da-4118-8f21-df320a41cb17',
        '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- "Entity": "MJ_BizApps_Tasks": "Task" "Timers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '4f2ae59e-b44e-457d-8f74-fb49960b042c' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'ID')
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
        '4f2ae59e-b44e-457d-8f74-fb49960b042c',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
        'ID',
        'ID',
        'Primary key for the timesheet approval part.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '31c7941c-e273-4217-a603-01a8e961bb25' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'TimesheetID')
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
        '31c7941c-e273-4217-a603-01a8e961bb25',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
        'TimesheetID',
        'Timesheet ID',
        'The Timesheet this approval slice belongs to.',
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
        'ED90EE09-0D39-4298-93DC-77C057FCE97A',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'bdbec7ef-0a27-480e-8dd3-b1697358cf3a' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'SubmissionRound')
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
        'bdbec7ef-0a27-480e-8dd3-b1697358cf3a',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
        'SubmissionRound',
        'Submission Round',
        'Submission round number (1 on initial submit, incremented on each resubmit).',
        'INTEGER',
        4,
        10,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '313378b3-a046-4a6e-a58d-7d1ce9486988' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'ScopeTaskID')
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
        '313378b3-a046-4a6e-a58d-7d1ce9486988',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
        'ScopeTaskID',
        'Scope Task ID',
        'Root project task for this approval slice, or NULL for the whole-timesheet / unassigned slice.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'da4b81fd-828e-4b52-b51e-a56a2216a124' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'ApprovalTaskID')
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
        'da4b81fd-828e-4b52-b51e-a56a2216a124',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
        'ApprovalTaskID',
        'Approval Task ID',
        'The approval Task created in the Tasks inbox for this slice.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '42303ef6-dd3d-408e-af35-4ecb9cc2706e' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'Minutes')
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
        '42303ef6-dd3d-408e-af35-4ecb9cc2706e',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
        'Minutes',
        'Minutes',
        'Total minutes in this approval slice at submission time.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '77571818-970e-4694-905e-b4b1b35aa43a' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'BillableMinutes')
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
        '77571818-970e-4694-905e-b4b1b35aa43a',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
        'BillableMinutes',
        'Billable Minutes',
        'Total billable minutes in this approval slice at submission time.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '425a8f3d-b2c6-4e8b-bb5c-da1f4ba52a37' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'EntryCount')
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
        '425a8f3d-b2c6-4e8b-bb5c-da1f4ba52a37',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
        'EntryCount',
        'Entry Count',
        'Number of TaskTimeEntry rows included in this approval slice.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '30f4c2c5-5a50-4aeb-b2cb-e1751ebf4e23' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'SnapshotHash')
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
        '30f4c2c5-5a50-4aeb-b2cb-e1751ebf4e23',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
        'SnapshotHash',
        'Snapshot Hash',
        'Deterministic SHA-256 hex digest of the slice time entries, used to carry forward unchanged Approved parts across resubmissions.',
        'TEXT',
        128,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '062734fe-ac90-42bb-b3ba-09fda28a517e' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'Status')
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
        '062734fe-ac90-42bb-b3ba-09fda28a517e',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
        'Status',
        'Status',
        'Current status of this approval slice: Pending, Approved, Rejected, or Canceled.',
        'TEXT',
        40,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '8bee7526-7aff-4767-8ba2-6a752b8b7000' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'DecidedByPersonID')
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
        '8bee7526-7aff-4767-8ba2-6a752b8b7000',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
        'DecidedByPersonID',
        'Decided By Person ID',
        'The Person who recorded the approval or rejection decision.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'a0fa4544-0274-495b-b285-5de5dd6a92b3' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'DecidedAt')
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
        'a0fa4544-0274-495b-b285-5de5dd6a92b3',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
        'DecidedAt',
        'Decided At',
        'Timestamp when the decision on this slice was recorded.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '71d9821c-22a1-4f42-996f-f28699998dce' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'DecisionNotes')
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
        '71d9821c-22a1-4f42-996f-f28699998dce',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
        'DecisionNotes',
        'Decision Notes',
        'Notes or feedback provided by the approver when deciding this slice.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '24702025-cddd-4c55-bdcd-7b0fb9abf565' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = '__mj_CreatedAt')
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
        '24702025-cddd-4c55-bdcd-7b0fb9abf565',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '254eb111-1fdb-4354-a0b8-8d7a996474b6' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = '__mj_UpdatedAt')
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
        '254eb111-1fdb-4354-a0b8-8d7a996474b6',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '5bb85555-0b3c-4a59-88d5-c9308cd72a46' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "Name" = 'ID')
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
        '5bb85555-0b3c-4a59-88d5-c9308cd72a46',
        'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- "Entity": "MJ_BizApps_Tasks": "Timesheets"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
        'ID',
        'ID',
        'Primary key for the timesheet.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'c5d5c45e-61c7-45f9-afce-2a9798f84aa2' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "Name" = 'PersonID')
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
        'c5d5c45e-61c7-45f9-afce-2a9798f84aa2',
        'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- "Entity": "MJ_BizApps_Tasks": "Timesheets"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
        'PersonID',
        'Person ID',
        'The Person whose time entries are covered by this timesheet.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '4eb77aea-41c5-4fab-bdba-0d15c5ae3101' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "Name" = 'PeriodStart')
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
        '4eb77aea-41c5-4fab-bdba-0d15c5ae3101',
        'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- "Entity": "MJ_BizApps_Tasks": "Timesheets"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
        'PeriodStart',
        'Period Start',
        'Inclusive start date of the timesheet period.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'f6c58764-9078-4ac5-9f88-b7f3685e2aae' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "Name" = 'PeriodEnd')
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
        'f6c58764-9078-4ac5-9f88-b7f3685e2aae',
        'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- "Entity": "MJ_BizApps_Tasks": "Timesheets"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
        'PeriodEnd',
        'Period End',
        'Inclusive end date of the timesheet period.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'dcafd61e-a2f4-4d42-819c-f37b9638cf35' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "Name" = 'Status')
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
        'dcafd61e-a2f4-4d42-819c-f37b9638cf35',
        'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- "Entity": "MJ_BizApps_Tasks": "Timesheets"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
        'Status',
        'Status',
        'Lifecycle status of the timesheet: Draft, Submitted, Approved, or Rejected.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'df49cc9a-4e5f-404a-9d32-9ca929abdc89' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "Name" = 'SubmittedAt')
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
        'df49cc9a-4e5f-404a-9d32-9ca929abdc89',
        'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- "Entity": "MJ_BizApps_Tasks": "Timesheets"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
        'SubmittedAt',
        'Submitted At',
        'Timestamp when the timesheet was most recently submitted.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'bc31c246-345f-4a54-8c9f-a09f01295492' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "Name" = 'SubmittedByUserID')
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
        'bc31c246-345f-4a54-8c9f-a09f01295492',
        'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- "Entity": "MJ_BizApps_Tasks": "Timesheets"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
        'SubmittedByUserID',
        'Submitted By User ID',
        'The MemberJunction User who submitted the timesheet.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '23a414b3-9872-4854-9977-be1fa4bed440' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "Name" = 'TotalMinutes')
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
        '23a414b3-9872-4854-9977-be1fa4bed440',
        'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- "Entity": "MJ_BizApps_Tasks": "Timesheets"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
        'TotalMinutes',
        'Total Minutes',
        'Total minutes across all time entries attached to this timesheet.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'e129f157-61f0-4638-8e15-03719a49dd22' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "Name" = 'BillableMinutes')
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
        'e129f157-61f0-4638-8e15-03719a49dd22',
        'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- "Entity": "MJ_BizApps_Tasks": "Timesheets"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
        'BillableMinutes',
        'Billable Minutes',
        'Total billable minutes across all time entries attached to this timesheet.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '4f6d6e31-e5e6-4b69-81c1-e6c28c18f346' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "Name" = 'Notes')
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
        '4f6d6e31-e5e6-4b69-81c1-e6c28c18f346',
        'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- "Entity": "MJ_BizApps_Tasks": "Timesheets"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
        'Notes',
        'Notes',
        'Worker notes or comments submitted with the timesheet.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '9815c5be-a1a4-498f-a080-1bfc656490ff' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "Name" = '__mj_CreatedAt')
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
        '9815c5be-a1a4-498f-a080-1bfc656490ff',
        'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- "Entity": "MJ_BizApps_Tasks": "Timesheets"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '34b24358-368d-4238-8063-4c664026eb73' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "Name" = '__mj_UpdatedAt')
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
        '34b24358-368d-4238-8063-4c664026eb73',
        'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- "Entity": "MJ_BizApps_Tasks": "Timesheets"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '32c6e1e7-7717-47e7-99b7-5dd4efd42895' OR ("EntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND "Name" = 'ID')
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
        '32c6e1e7-7717-47e7-99b7-5dd4efd42895',
        '5A25B67B-D67D-453F-8340-94BF69CF8CEE', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entry" "Links"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE'),
        'ID',
        'ID',
        'Primary key for the task time entry link.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'ecfd46fe-63d5-445d-8282-3bc018676cba' OR ("EntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND "Name" = 'TaskTimeEntryID')
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
        'ecfd46fe-63d5-445d-8282-3bc018676cba',
        '5A25B67B-D67D-453F-8340-94BF69CF8CEE', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entry" "Links"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE'),
        'TaskTimeEntryID',
        'Task Time Entry ID',
        'The TaskTimeEntry being linked.',
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
        'EA40801A-DF1B-443A-B0D3-EA0415645603',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '023bf220-43da-42b1-b24d-331243bdb452' OR ("EntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND "Name" = 'EntityID')
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
        '023bf220-43da-42b1-b24d-331243bdb452',
        '5A25B67B-D67D-453F-8340-94BF69CF8CEE', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entry" "Links"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE'),
        'EntityID',
        'Entity ID',
        'Target MemberJunction Entity ID for the linked external record.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '6721c788-1070-4dc1-876d-f67307aafeb7' OR ("EntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND "Name" = 'RecordID')
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
        '6721c788-1070-4dc1-876d-f67307aafeb7',
        '5A25B67B-D67D-453F-8340-94BF69CF8CEE', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entry" "Links"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE'),
        'RecordID',
        'Record ID',
        'Primary key value of the linked record in EntityID.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '3d44d5b8-b4fe-4929-8980-7967f79e8e7d' OR ("EntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND "Name" = 'Relationship')
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
        '3d44d5b8-b4fe-4929-8980-7967f79e8e7d',
        '5A25B67B-D67D-453F-8340-94BF69CF8CEE', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entry" "Links"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE'),
        'Relationship',
        'Relationship',
        'Semantic relationship of the linked record to the time entry: InvoiceLine, JournalEntryLine, Commit, PullRequest, or Related.',
        'TEXT',
        60,
        0,
        0,
        FALSE,
        'Related',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '3150f98d-8c90-4da3-a33b-b2ddaa8f7763' OR ("EntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND "Name" = '__mj_CreatedAt')
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
        '3150f98d-8c90-4da3-a33b-b2ddaa8f7763',
        '5A25B67B-D67D-453F-8340-94BF69CF8CEE', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entry" "Links"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '798cd59a-52c7-4479-8bbf-d7fcdee5c871' OR ("EntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND "Name" = '__mj_UpdatedAt')
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
        '798cd59a-52c7-4479-8bbf-d7fcdee5c871',
        '5A25B67B-D67D-453F-8340-94BF69CF8CEE', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entry" "Links"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'dcb405a1-7f31-4016-b177-eb813df88895' OR ("EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = 'ID')
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
        'dcb405a1-7f31-4016-b177-eb813df88895',
        '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Schedules"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
        'ID',
        'ID',
        'Primary key for the timesheet schedule.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '73405dd0-fad3-4c48-948d-58d729e26521' OR ("EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = 'PersonID')
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
        '73405dd0-fad3-4c48-948d-58d729e26521',
        '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Schedules"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
        'PersonID',
        'Person ID',
        'Optional Person this schedule applies to (NULL for organization/entity-scoped or global schedules).',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '2ce5f2b1-19bc-444f-8ebb-96263103b081' OR ("EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = 'ScopeEntityID')
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
        '2ce5f2b1-19bc-444f-8ebb-96263103b081',
        '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Schedules"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
        'ScopeEntityID',
        'Scope Entity ID',
        'Optional MJ Entity ID when scoping the schedule to an organization or department record.',
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
        'E0238F34-2837-EF11-86D4-6045BDEE16E6',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'd5c5fbf0-f90a-48cd-a06e-34cea9b924fe' OR ("EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = 'ScopeRecordID')
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
        'd5c5fbf0-f90a-48cd-a06e-34cea9b924fe',
        '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Schedules"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
        'ScopeRecordID',
        'Scope Record ID',
        'Companion record ID in ScopeEntityID for entity-scoped schedules.',
        'TEXT',
        900,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '8a2be0bf-64c1-4429-a821-8c8213fdc3c5' OR ("EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = 'Cadence')
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
        '8a2be0bf-64c1-4429-a821-8c8213fdc3c5',
        '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Schedules"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
        'Cadence',
        'Cadence',
        'Timesheet period cadence: Weekly, BiWeekly, SemiMonthly, or Monthly.',
        'TEXT',
        40,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'e423a509-1f64-48d0-a6c9-e40fcaabbc39' OR ("EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = 'WeekStartDay')
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
        'e423a509-1f64-48d0-a6c9-e40fcaabbc39',
        '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Schedules"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
        'WeekStartDay',
        'Week Start Day',
        'First day of the work week for Weekly and BiWeekly cadences: Monday, Sunday, or Saturday.',
        'TEXT',
        20,
        0,
        0,
        FALSE,
        'Monday',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '89ea42e1-0e09-419d-8fe9-e2c67eca4bab' OR ("EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = 'BiWeeklyAnchorDate')
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
        '89ea42e1-0e09-419d-8fe9-e2c67eca4bab',
        '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Schedules"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
        'BiWeeklyAnchorDate',
        'Bi Weekly Anchor Date',
        'Anchor date (which must fall on WeekStartDay) defining the 14-day boundary for BiWeekly cadences.',
        'date',
        3,
        10,
        0,
        FALSE,
        '2026-01-05',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'f01ac808-cef3-40e0-8693-cf9cbeb878a7' OR ("EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = 'EffectiveFrom')
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
        'f01ac808-cef3-40e0-8693-cf9cbeb878a7',
        '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Schedules"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
        'EffectiveFrom',
        'Effective From',
        'Inclusive start date from which this schedule is effective (must fall on a period boundary).',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '63c8dc44-f85b-40c9-9b6b-a725f26a42f3' OR ("EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = 'EffectiveTo')
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
        '63c8dc44-f85b-40c9-9b6b-a725f26a42f3',
        '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Schedules"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
        'EffectiveTo',
        'Effective To',
        'Optional inclusive end date through which this schedule is effective.',
        'date',
        3,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'b94e0a7b-f022-4805-b0e9-3dd73fa0372e' OR ("EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = 'Notes')
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
        'b94e0a7b-f022-4805-b0e9-3dd73fa0372e',
        '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Schedules"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
        'Notes',
        'Notes',
        'Optional notes explaining this schedule or cadence change.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'b9014bd1-90ee-4315-840f-a9a47168eb8a' OR ("EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = '__mj_CreatedAt')
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
        'b9014bd1-90ee-4315-840f-a9a47168eb8a',
        '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Schedules"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'd10e9b23-be52-4a0a-af35-619e08da1550' OR ("EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = '__mj_UpdatedAt')
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
        'd10e9b23-be52-4a0a-af35-619e08da1550',
        '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Schedules"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'f0054c13-720c-49d9-9ebd-11802d49caac' OR ("EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND "Name" = 'RequiresAssigneeDecision')
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
        'f0054c13-720c-49d9-9ebd-11802d49caac',
        '1E30141A-826F-4278-BAA9-BBE14D29E606', -- "Entity": "MJ_BizApps_Tasks": "Task" "Types"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '1E30141A-826F-4278-BAA9-BBE14D29E606'),
        'RequiresAssigneeDecision',
        'Requires Assignee Decision',
        'When true on an approval task type, only an assigned approver (and never the task creator unless exempt) may record a decision on tasks of this type, regardless of the global PreventSelfApproval setting.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '11176ee4-de36-49c9-97ae-854962530dc8' OR ("EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "Name" = 'ID')
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
        '11176ee4-de36-49c9-97ae-854962530dc8',
        'EA40801A-DF1B-443A-B0D3-EA0415645603', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entries"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
        'ID',
        'ID',
        'Primary key for the task time entry.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '91493f5a-6b8c-48b4-82dc-4455a88797a8' OR ("EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "Name" = 'TaskID')
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
        '91493f5a-6b8c-48b4-82dc-4455a88797a8',
        'EA40801A-DF1B-443A-B0D3-EA0415645603', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entries"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
        'TaskID',
        'Task ID',
        'The task this time entry is logged against.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '5cc9964f-5ca5-4be3-9237-9901052413b3' OR ("EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "Name" = 'PersonID')
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
        '5cc9964f-5ca5-4be3-9237-9901052413b3',
        'EA40801A-DF1B-443A-B0D3-EA0415645603', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entries"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
        'PersonID',
        'Person ID',
        'The Person who performed the work.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '74d80d59-9934-4656-bd13-3d919f088aca' OR ("EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "Name" = 'WorkDate')
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
        '74d80d59-9934-4656-bd13-3d919f088aca',
        'EA40801A-DF1B-443A-B0D3-EA0415645603', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entries"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
        'WorkDate',
        'Work Date',
        'Business calendar date the work was performed on.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'a4b7b796-99d1-4283-bc8a-94f6dcd24f4f' OR ("EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "Name" = 'Minutes')
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
        'a4b7b796-99d1-4283-bc8a-94f6dcd24f4f',
        'EA40801A-DF1B-443A-B0D3-EA0415645603', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entries"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
        'Minutes',
        'Minutes',
        'Duration of work in whole minutes (1 to 1440).',
        'INTEGER',
        4,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'a58eed88-9e28-49c6-aec3-795bff8193f9' OR ("EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "Name" = 'StartedAt')
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
        'a58eed88-9e28-49c6-aec3-795bff8193f9',
        'EA40801A-DF1B-443A-B0D3-EA0415645603', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entries"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
        'StartedAt',
        'Started At',
        'Optional timestamp when the work interval started (populated for timer-backed entries).',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'a2f0a401-c8f7-4d3d-ae20-f57201dc594d' OR ("EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "Name" = 'EndedAt')
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
        'a2f0a401-c8f7-4d3d-ae20-f57201dc594d',
        'EA40801A-DF1B-443A-B0D3-EA0415645603', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entries"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
        'EndedAt',
        'Ended At',
        'Optional timestamp when the work interval ended (populated for timer-backed entries).',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'a9d9f3ea-2041-4314-9116-cb9073078f83' OR ("EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "Name" = 'Notes')
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
        'a9d9f3ea-2041-4314-9116-cb9073078f83',
        'EA40801A-DF1B-443A-B0D3-EA0415645603', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entries"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
        'Notes',
        'Notes',
        'Narrative description of what was accomplished during this time entry.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '73b9b79b-bdb8-479f-8db1-4677da98f85f' OR ("EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "Name" = 'Source')
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
        '73b9b79b-bdb8-479f-8db1-4677da98f85f',
        'EA40801A-DF1B-443A-B0D3-EA0415645603', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entries"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
        'Source',
        'Source',
        'How the time entry was created: Manual, Timer, Imported, or Agent.',
        'TEXT',
        40,
        0,
        0,
        FALSE,
        'Manual',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '6e75e4ab-b38b-42cc-8958-af5d1bc5313c' OR ("EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "Name" = 'IsBillable')
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
        '6e75e4ab-b38b-42cc-8958-af5d1bc5313c',
        'EA40801A-DF1B-443A-B0D3-EA0415645603', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entries"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
        'IsBillable',
        'Is Billable',
        'Whether this time entry is billable to a client or external party.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '27604c00-3920-4c53-a0a7-182421db2d65' OR ("EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "Name" = 'TimesheetID')
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
        '27604c00-3920-4c53-a0a7-182421db2d65',
        'EA40801A-DF1B-443A-B0D3-EA0415645603', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entries"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
        'TimesheetID',
        'Timesheet ID',
        'Optional Timesheet this time entry has been attached to.',
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
        'ED90EE09-0D39-4298-93DC-77C057FCE97A',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '97466ac9-28b2-4a28-9b47-e2490194426d' OR ("EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "Name" = '__mj_CreatedAt')
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
        '97466ac9-28b2-4a28-9b47-e2490194426d',
        'EA40801A-DF1B-443A-B0D3-EA0415645603', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entries"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '48e91c0a-bd0a-40a9-bd35-323bb43eceee' OR ("EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "Name" = '__mj_UpdatedAt')
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
        '48e91c0a-bd0a-40a9-bd35-323bb43eceee',
        'EA40801A-DF1B-443A-B0D3-EA0415645603', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entries"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '975e4d65-8b74-4bda-9e6f-6d4413fa1d2b' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'LoggedMinutes')
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
        '975e4d65-8b74-4bda-9e6f-6d4413fa1d2b',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'LoggedMinutes',
        'Logged Minutes',
        NULL,
        'INTEGER',
        4,
        10,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '189e951c-1bde-450c-86b7-17db5a94c50a' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'AgentRunCount')
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
        '189e951c-1bde-450c-86b7-17db5a94c50a',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'AgentRunCount',
        'Agent Run Count',
        NULL,
        'INTEGER',
        4,
        10,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'e897f9ea-75e9-4ff4-8cba-99031292ae72' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'AgentCost')
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
        'e897f9ea-75e9-4ff4-8cba-99031292ae72',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'AgentCost',
        'Agent Cost',
        NULL,
        'decimal',
        17,
        38,
        8,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '633313c6-a992-4fe6-9da1-205fd09f2c30' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "Name" = 'AgentTokens')
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
        '633313c6-a992-4fe6-9da1-205fd09f2c30',
        'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- "Entity": "MJ_BizApps_Tasks": "Tasks"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
        'AgentTokens',
        'Agent Tokens',
        NULL,
        'INTEGER',
        4,
        10,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'efb188d4-046b-4904-b1cc-7ce66b6aadc2' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'ID')
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
        'efb188d4-046b-4904-b1cc-7ce66b6aadc2',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
        'ID',
        'ID',
        'Primary key for the time approver rule.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '384549e1-5ddd-481c-a809-862c39893966' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'ApproverPersonID')
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
        '384549e1-5ddd-481c-a809-862c39893966',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
        'ApproverPersonID',
        'Approver Person ID',
        'The Person who is granted time approval authority by this rule.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '0c2c4d67-b8a8-442a-9ce8-e2f0d35a183e' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'WorkerPersonID')
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
        '0c2c4d67-b8a8-442a-9ce8-e2f0d35a183e',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
        'WorkerPersonID',
        'Worker Person ID',
        'Optional Worker Person whose time this rule applies to (NULL matches any worker).',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '690c2a28-5f12-47de-8580-12e6f0990ec7' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'ScopeTaskID')
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
        '690c2a28-5f12-47de-8580-12e6f0990ec7',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
        'ScopeTaskID',
        'Scope Task ID',
        'Optional project/parent Task this rule scopes approval to (NULL matches any task).',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '9e17e4c3-ca9c-4b4a-841c-d5efb5d6259c' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'IncludeDescendants')
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
        '9e17e4c3-ca9c-4b4a-841c-d5efb5d6259c',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
        'IncludeDescendants',
        'Include Descendants',
        'When ScopeTaskID is set, whether sub-tasks beneath ScopeTaskID also match this rule.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'fe1bf4b9-32b1-4edc-9e13-dbe524f895a6' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'ScopeEntityID')
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
        'fe1bf4b9-32b1-4edc-9e13-dbe524f895a6',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
        'ScopeEntityID',
        'Scope Entity ID',
        'Optional MJ Entity ID when scoping approval to tasks linked to an external record via TaskLink.',
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
        'E0238F34-2837-EF11-86D4-6045BDEE16E6',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '96bc903c-08e1-45ad-8a02-4078f80383d4' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'ScopeRecordID')
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
        '96bc903c-08e1-45ad-8a02-4078f80383d4',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
        'ScopeRecordID',
        'Scope Record ID',
        'Companion record ID in ScopeEntityID when scoping approval to tasks linked via TaskLink.',
        'TEXT',
        900,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '49619251-166f-444d-9595-ba0e019604c6' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'EffectiveFrom')
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
        '49619251-166f-444d-9595-ba0e019604c6',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
        'EffectiveFrom',
        'Effective From',
        'Optional start date from which this approver rule is effective.',
        'date',
        3,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '18b4dfb6-d189-468c-9ad4-ec4a973093f9' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'EffectiveTo')
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
        '18b4dfb6-d189-468c-9ad4-ec4a973093f9',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
        'EffectiveTo',
        'Effective To',
        'Optional end date through which this approver rule is effective.',
        'date',
        3,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '4b175a4f-ec87-44c5-8a07-7dde597d6130' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'IsActive')
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
        '4b175a4f-ec87-44c5-8a07-7dde597d6130',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
        'IsActive',
        'Is Active',
        'Whether this approver rule is currently active.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'f6953759-6df8-45a6-902b-ca152e95439a' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'Notes')
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
        'f6953759-6df8-45a6-902b-ca152e95439a',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
        'Notes',
        'Notes',
        'Optional administrative notes about this approver rule.',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '51d6a9a2-cf3f-4375-b6ab-f66d72c05424' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = '__mj_CreatedAt')
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
        '51d6a9a2-cf3f-4375-b6ab-f66d72c05424',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '9afd097d-bdb5-4663-a8e9-3481a153be6d' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = '__mj_UpdatedAt')
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
        '9afd097d-bdb5-4663-a8e9-3481a153be6d',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
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

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('0f7adb8a-27f4-45b5-9ce4-9b8441ff54ed', '73B9B79B-BDB8-479F-8DB1-4677DA98F85F', 1, 'Agent', 'Agent', NOW(), NOW());

/* SQL text to insert entity field value with ID 83d181db-a0af-412a-9a74-922e5086c460 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('83d181db-a0af-412a-9a74-922e5086c460', '73B9B79B-BDB8-479F-8DB1-4677DA98F85F', 2, 'Imported', 'Imported', NOW(), NOW());

/* SQL text to insert entity field value with ID ae1eeb3a-87ab-4f74-9f8d-c56f1098d625 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('ae1eeb3a-87ab-4f74-9f8d-c56f1098d625', '73B9B79B-BDB8-479F-8DB1-4677DA98F85F', 3, 'Manual', 'Manual', NOW(), NOW());

/* SQL text to insert entity field value with ID 9aef775a-feff-421f-aaa8-9e8de6fc3088 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('9aef775a-feff-421f-aaa8-9e8de6fc3088', '73B9B79B-BDB8-479F-8DB1-4677DA98F85F', 4, 'Timer', 'Timer', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 73B9B79B-BDB8-479F-8DB1-4677DA98F85F */

UPDATE ${mjSchema}."EntityField" SET "ValueListType"='List' WHERE "ID"='73B9B79B-BDB8-479F-8DB1-4677DA98F85F';

/* SQL text to insert entity field value with ID 1173df07-4c7e-4f5f-b2ec-a19b473dab36 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('1173df07-4c7e-4f5f-b2ec-a19b473dab36', '8AD0134D-2F51-4FDD-BAF2-4FE7CB8F8F82', 1, 'Assisted', 'Assisted', NOW(), NOW());

/* SQL text to insert entity field value with ID ff4fb037-6572-48c2-b88f-8676a49c874a */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('ff4fb037-6572-48c2-b88f-8676a49c874a', '8AD0134D-2F51-4FDD-BAF2-4FE7CB8F8F82', 2, 'Executed', 'Executed', NOW(), NOW());

/* SQL text to insert entity field value with ID ee2ae9d4-43fd-49cd-a68e-be20dbf0c6ac */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('ee2ae9d4-43fd-49cd-a68e-be20dbf0c6ac', '8AD0134D-2F51-4FDD-BAF2-4FE7CB8F8F82', 3, 'Planned', 'Planned', NOW(), NOW());

/* SQL text to insert entity field value with ID f7767307-fd6c-4f40-b083-c8f1ec1b56ff */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('f7767307-fd6c-4f40-b083-c8f1ec1b56ff', '8AD0134D-2F51-4FDD-BAF2-4FE7CB8F8F82', 4, 'Reviewed', 'Reviewed', NOW(), NOW());

/* SQL text to insert entity field value with ID d15da97e-9afb-428c-83ce-d8f954b7175c */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('d15da97e-9afb-428c-83ce-d8f954b7175c', '8AD0134D-2F51-4FDD-BAF2-4FE7CB8F8F82', 5, 'Triaged', 'Triaged', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 8AD0134D-2F51-4FDD-BAF2-4FE7CB8F8F82 */

UPDATE ${mjSchema}."EntityField" SET "ValueListType"='List' WHERE "ID"='8AD0134D-2F51-4FDD-BAF2-4FE7CB8F8F82';

/* SQL text to insert entity field value with ID 7c83f162-21a1-441f-b322-3a474c9491bd */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('7c83f162-21a1-441f-b322-3a474c9491bd', 'DCAFD61E-A2F4-4D42-819C-F37B9638CF35', 1, 'Approved', 'Approved', NOW(), NOW());

/* SQL text to insert entity field value with ID 82ae3360-a5b5-4485-9410-ca14f79afa44 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('82ae3360-a5b5-4485-9410-ca14f79afa44', 'DCAFD61E-A2F4-4D42-819C-F37B9638CF35', 2, 'Draft', 'Draft', NOW(), NOW());

/* SQL text to insert entity field value with ID a75aa577-37bc-4b42-90e7-ed43ff91bc78 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('a75aa577-37bc-4b42-90e7-ed43ff91bc78', 'DCAFD61E-A2F4-4D42-819C-F37B9638CF35', 3, 'Rejected', 'Rejected', NOW(), NOW());

/* SQL text to insert entity field value with ID 6476977a-f0dd-450c-9e82-91cf26d60db4 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('6476977a-f0dd-450c-9e82-91cf26d60db4', 'DCAFD61E-A2F4-4D42-819C-F37B9638CF35', 4, 'Submitted', 'Submitted', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID DCAFD61E-A2F4-4D42-819C-F37B9638CF35 */

UPDATE ${mjSchema}."EntityField" SET "ValueListType"='List' WHERE "ID"='DCAFD61E-A2F4-4D42-819C-F37B9638CF35';

/* SQL text to insert entity field value with ID 5f1ccd70-1333-4753-b13f-70821662790b */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('5f1ccd70-1333-4753-b13f-70821662790b', '062734FE-AC90-42BB-B3BA-09FDA28A517E', 1, 'Approved', 'Approved', NOW(), NOW());

/* SQL text to insert entity field value with ID 942cddf9-f28e-4ad6-9a33-540e15a53f47 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('942cddf9-f28e-4ad6-9a33-540e15a53f47', '062734FE-AC90-42BB-B3BA-09FDA28A517E', 2, 'Canceled', 'Canceled', NOW(), NOW());

/* SQL text to insert entity field value with ID 2771390d-69d9-4120-93bd-7cbdb2c5ed29 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('2771390d-69d9-4120-93bd-7cbdb2c5ed29', '062734FE-AC90-42BB-B3BA-09FDA28A517E', 3, 'Pending', 'Pending', NOW(), NOW());

/* SQL text to insert entity field value with ID 3dbff4a8-79d5-49a8-bce4-ae0e191d4096 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('3dbff4a8-79d5-49a8-bce4-ae0e191d4096', '062734FE-AC90-42BB-B3BA-09FDA28A517E', 4, 'Rejected', 'Rejected', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 062734FE-AC90-42BB-B3BA-09FDA28A517E */

UPDATE ${mjSchema}."EntityField" SET "ValueListType"='List' WHERE "ID"='062734FE-AC90-42BB-B3BA-09FDA28A517E';

/* SQL text to insert entity field value with ID ea3d3016-ebd1-4e4c-94ed-ef996514230d */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('ea3d3016-ebd1-4e4c-94ed-ef996514230d', '2EA93151-5257-4972-BE84-6CB41D3541D8', 1, 'ExpenseReport', 'ExpenseReport', NOW(), NOW());

/* SQL text to insert entity field value with ID c731a73b-c7e7-4a38-a979-01550b305872 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('c731a73b-c7e7-4a38-a979-01550b305872', '2EA93151-5257-4972-BE84-6CB41D3541D8', 2, 'Invoice', 'Invoice', NOW(), NOW());

/* SQL text to insert entity field value with ID 308ce7c0-5108-4ffe-9ab2-25a7ceaf2e51 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('308ce7c0-5108-4ffe-9ab2-25a7ceaf2e51', '2EA93151-5257-4972-BE84-6CB41D3541D8', 3, 'PayrollBatch', 'PayrollBatch', NOW(), NOW());

/* SQL text to insert entity field value with ID 422d0a4b-6e93-42c3-ac01-73aed562c6b0 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('422d0a4b-6e93-42c3-ac01-73aed562c6b0', '2EA93151-5257-4972-BE84-6CB41D3541D8', 4, 'Related', 'Related', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 2EA93151-5257-4972-BE84-6CB41D3541D8 */

UPDATE ${mjSchema}."EntityField" SET "ValueListType"='List' WHERE "ID"='2EA93151-5257-4972-BE84-6CB41D3541D8';

/* SQL text to insert entity field value with ID 32792ca1-bb61-4bc1-b627-fde08bcde748 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('32792ca1-bb61-4bc1-b627-fde08bcde748', '3D44D5B8-B4FE-4929-8980-7967F79E8E7D', 1, 'Commit', 'Commit', NOW(), NOW());

/* SQL text to insert entity field value with ID b08ccc00-43d2-4582-bcbd-5ab274d045ba */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('b08ccc00-43d2-4582-bcbd-5ab274d045ba', '3D44D5B8-B4FE-4929-8980-7967F79E8E7D', 2, 'InvoiceLine', 'InvoiceLine', NOW(), NOW());

/* SQL text to insert entity field value with ID 6e6946ea-ec62-4a62-92be-9eb7f6744c6c */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('6e6946ea-ec62-4a62-92be-9eb7f6744c6c', '3D44D5B8-B4FE-4929-8980-7967F79E8E7D', 3, 'JournalEntryLine', 'JournalEntryLine', NOW(), NOW());

/* SQL text to insert entity field value with ID 9ac28ad0-0824-4326-a764-25e4448b75fb */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('9ac28ad0-0824-4326-a764-25e4448b75fb', '3D44D5B8-B4FE-4929-8980-7967F79E8E7D', 4, 'PullRequest', 'PullRequest', NOW(), NOW());

/* SQL text to insert entity field value with ID 1fbac371-f9d5-4389-9015-23e68e667f9f */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('1fbac371-f9d5-4389-9015-23e68e667f9f', '3D44D5B8-B4FE-4929-8980-7967F79E8E7D', 5, 'Related', 'Related', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 3D44D5B8-B4FE-4929-8980-7967F79E8E7D */

UPDATE ${mjSchema}."EntityField" SET "ValueListType"='List' WHERE "ID"='3D44D5B8-B4FE-4929-8980-7967F79E8E7D';

/* SQL text to insert entity field value with ID 13852a60-9a05-43c8-912c-d6807380368d */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('13852a60-9a05-43c8-912c-d6807380368d', '8A2BE0BF-64C1-4429-A821-8C8213FDC3C5', 1, 'BiWeekly', 'BiWeekly', NOW(), NOW());

/* SQL text to insert entity field value with ID adb4881e-62b3-4577-9b7b-f95d822b7d61 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('adb4881e-62b3-4577-9b7b-f95d822b7d61', '8A2BE0BF-64C1-4429-A821-8C8213FDC3C5', 2, 'Monthly', 'Monthly', NOW(), NOW());

/* SQL text to insert entity field value with ID 15f9974a-0b7a-4615-aa45-708e271149b7 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('15f9974a-0b7a-4615-aa45-708e271149b7', '8A2BE0BF-64C1-4429-A821-8C8213FDC3C5', 3, 'SemiMonthly', 'SemiMonthly', NOW(), NOW());

/* SQL text to insert entity field value with ID 6edf9d40-3007-43c4-a3b5-a82b056ad0f8 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('6edf9d40-3007-43c4-a3b5-a82b056ad0f8', '8A2BE0BF-64C1-4429-A821-8C8213FDC3C5', 4, 'Weekly', 'Weekly', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID 8A2BE0BF-64C1-4429-A821-8C8213FDC3C5 */

UPDATE ${mjSchema}."EntityField" SET "ValueListType"='List' WHERE "ID"='8A2BE0BF-64C1-4429-A821-8C8213FDC3C5';

/* SQL text to insert entity field value with ID 73eb2c1e-7e5d-4133-935e-6ed0a1cde9d8 */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('73eb2c1e-7e5d-4133-935e-6ed0a1cde9d8', 'E423A509-1F64-48D0-A6C9-E40FCAABBC39', 1, 'Monday', 'Monday', NOW(), NOW());

/* SQL text to insert entity field value with ID f3147050-847b-4245-abb8-977e64bf72bf */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('f3147050-847b-4245-abb8-977e64bf72bf', 'E423A509-1F64-48D0-A6C9-E40FCAABBC39', 2, 'Saturday', 'Saturday', NOW(), NOW());

/* SQL text to insert entity field value with ID 110a599e-d733-403d-9095-a99030eeb2bf */

INSERT INTO ${mjSchema}."EntityFieldValue"
                                       ("ID", "EntityFieldID", "Sequence", "Value", "Code", "__mj_CreatedAt", "__mj_UpdatedAt")
                                    VALUES
                                       ('110a599e-d733-403d-9095-a99030eeb2bf', 'E423A509-1F64-48D0-A6C9-E40FCAABBC39', 3, 'Sunday', 'Sunday', NOW(), NOW());

/* SQL text to update ValueListType for entity field ID E423A509-1F64-48D0-A6C9-E40FCAABBC39 */

UPDATE ${mjSchema}."EntityField" SET "ValueListType"='List' WHERE "ID"='E423A509-1F64-48D0-A6C9-E40FCAABBC39';

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
              AND e."SchemaName" NOT IN ('${mjSchema}','__mj_BizAppsCommon','__mj_BizAppsContactCenter','__mj_BizAppsIssues','sys')
              AND NOT EXISTS (
               SELECT 1 FROM ${mjSchema}."EntityField" f2
               WHERE f2."EntityID" = e."ID"
                 AND f2."IncludeInUserSearchAPI" = TRUE
            )
         );


/* Create Entity Relationship: MJ: AI Agent Runs -> MJ_BizApps_Tasks: Task Agent Runs (One To Many via AIAgentRunID) */

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '3f24065e-e1be-4b26-bb07-3efc77223db7' OR ("EntityID" = '5190AF93-4C39-4429-BDAA-0AEB492A0256' AND "RelatedEntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND "RelatedEntityJoinField" = 'AIAgentRunID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('3f24065e-e1be-4b26-bb07-3efc77223db7', '5190AF93-4C39-4429-BDAA-0AEB492A0256', '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', 'AIAgentRunID', 'One To Many', TRUE, TRUE, 17, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '6d091fc6-c7bf-4b57-ba56-672af385e6c4' OR ("EntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "RelatedEntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND "RelatedEntityJoinField" = 'EntityID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('6d091fc6-c7bf-4b57-ba56-672af385e6c4', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'D594B91D-4DE0-4D20-8D71-21F041FA505D', 'EntityID', 'One To Many', TRUE, TRUE, 95, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '51dfd298-ab46-4c16-9e74-11d1aa2cc82f' OR ("EntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "RelatedEntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND "RelatedEntityJoinField" = 'EntityID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('51dfd298-ab46-4c16-9e74-11d1aa2cc82f', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '5A25B67B-D67D-453F-8340-94BF69CF8CEE', 'EntityID', 'One To Many', TRUE, TRUE, 96, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = 'bcefa591-b4a1-4847-aa18-ab4e80eda6d4' OR ("EntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "RelatedEntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "RelatedEntityJoinField" = 'ScopeEntityID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('bcefa591-b4a1-4847-aa18-ab4e80eda6d4', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '6A27830F-A203-4D3E-8ADF-B1085E1F908C', 'ScopeEntityID', 'One To Many', TRUE, TRUE, 97, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = 'ba097ef1-7e19-4730-9ee3-d804ad150177' OR ("EntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "RelatedEntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "RelatedEntityJoinField" = 'ScopeEntityID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('ba097ef1-7e19-4730-9ee3-d804ad150177', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', 'ScopeEntityID', 'One To Many', TRUE, TRUE, 98, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '33a3fa98-2b24-4f59-a28c-5e266cfd94bd' OR ("EntityID" = 'E1238F34-2837-EF11-86D4-6045BDEE16E6' AND "RelatedEntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "RelatedEntityJoinField" = 'SubmittedByUserID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('33a3fa98-2b24-4f59-a28c-5e266cfd94bd', 'E1238F34-2837-EF11-86D4-6045BDEE16E6', 'ED90EE09-0D39-4298-93DC-77C057FCE97A', 'SubmittedByUserID', 'One To Many', TRUE, TRUE, 129, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = 'c898e0a1-c95d-4af4-bbc0-9404c626d5fe' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "RelatedEntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND "RelatedEntityJoinField" = 'TimesheetID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('c898e0a1-c95d-4af4-bbc0-9404c626d5fe', 'ED90EE09-0D39-4298-93DC-77C057FCE97A', 'D594B91D-4DE0-4D20-8D71-21F041FA505D', 'TimesheetID', 'One To Many', TRUE, TRUE, 1, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = 'd6cc7803-b063-482e-9237-cb1a817af26c' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "RelatedEntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "RelatedEntityJoinField" = 'TimesheetID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('d6cc7803-b063-482e-9237-cb1a817af26c', 'ED90EE09-0D39-4298-93DC-77C057FCE97A', '02C38B1A-6987-463D-8B6B-4C86E0887D42', 'TimesheetID', 'One To Many', TRUE, TRUE, 2, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '94ed04ef-6b63-4a47-b0ac-922e2c03acb7' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "RelatedEntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "RelatedEntityJoinField" = 'TimesheetID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('94ed04ef-6b63-4a47-b0ac-922e2c03acb7', 'ED90EE09-0D39-4298-93DC-77C057FCE97A', 'EA40801A-DF1B-443A-B0D3-EA0415645603', 'TimesheetID', 'One To Many', TRUE, TRUE, 3, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = 'a1656f17-b4f7-4e9d-a07b-8a2f17a47457' OR ("EntityID" = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND "RelatedEntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND "RelatedEntityJoinField" = 'PersonID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('a1656f17-b4f7-4e9d-a07b-8a2f17a47457', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', 'PersonID', 'One To Many', TRUE, TRUE, 17, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '93ad10c2-6775-411b-85d4-f3327194a94f' OR ("EntityID" = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND "RelatedEntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "RelatedEntityJoinField" = 'DecidedByPersonID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('93ad10c2-6775-411b-85d4-f3327194a94f', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '02C38B1A-6987-463D-8B6B-4C86E0887D42', 'DecidedByPersonID', 'One To Many', TRUE, TRUE, 18, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '120b45a0-65e5-4282-a943-fe69dd97e4ef' OR ("EntityID" = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND "RelatedEntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "RelatedEntityJoinField" = 'PersonID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('120b45a0-65e5-4282-a943-fe69dd97e4ef', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'ED90EE09-0D39-4298-93DC-77C057FCE97A', 'PersonID', 'One To Many', TRUE, TRUE, 19, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '10f6be5d-7b1c-48a5-b62c-614d04b3d67a' OR ("EntityID" = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND "RelatedEntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "RelatedEntityJoinField" = 'PersonID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('10f6be5d-7b1c-48a5-b62c-614d04b3d67a', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '6A27830F-A203-4D3E-8ADF-B1085E1F908C', 'PersonID', 'One To Many', TRUE, TRUE, 20, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = 'e27e7264-14ea-45bd-a88e-b4960ca82d51' OR ("EntityID" = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND "RelatedEntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "RelatedEntityJoinField" = 'PersonID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('e27e7264-14ea-45bd-a88e-b4960ca82d51', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'EA40801A-DF1B-443A-B0D3-EA0415645603', 'PersonID', 'One To Many', TRUE, TRUE, 21, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '859cdff4-cbcf-4e6f-b999-03d4c1f9e3db' OR ("EntityID" = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND "RelatedEntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "RelatedEntityJoinField" = 'ApproverPersonID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('859cdff4-cbcf-4e6f-b999-03d4c1f9e3db', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', 'ApproverPersonID', 'One To Many', TRUE, TRUE, 22, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '4fa8726c-45c6-4a38-8bca-6ccf383340a0' OR ("EntityID" = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND "RelatedEntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "RelatedEntityJoinField" = 'WorkerPersonID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('4fa8726c-45c6-4a38-8bca-6ccf383340a0', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', 'WorkerPersonID', 'One To Many', TRUE, TRUE, 23, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = 'c2551a0b-b873-4efb-ba8c-ab7bbc3f58ef' OR ("EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "RelatedEntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND "RelatedEntityJoinField" = 'TaskTimeEntryID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('c2551a0b-b873-4efb-ba8c-ab7bbc3f58ef', 'EA40801A-DF1B-443A-B0D3-EA0415645603', '5A25B67B-D67D-453F-8340-94BF69CF8CEE', 'TaskTimeEntryID', 'One To Many', TRUE, TRUE, 1, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '3b77b4dd-3c81-481a-a817-c425146af146' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "RelatedEntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND "RelatedEntityJoinField" = 'TaskID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('3b77b4dd-3c81-481a-a817-c425146af146', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', 'TaskID', 'One To Many', TRUE, TRUE, 12, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '6b6f417c-7096-4932-b036-009850b541ba' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "RelatedEntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND "RelatedEntityJoinField" = 'TaskID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('6b6f417c-7096-4932-b036-009850b541ba', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', 'TaskID', 'One To Many', TRUE, TRUE, 13, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = 'a41b9caf-18f9-4ea6-95b0-c98c555c6d83' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "RelatedEntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "RelatedEntityJoinField" = 'ScopeTaskID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('a41b9caf-18f9-4ea6-95b0-c98c555c6d83', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '02C38B1A-6987-463D-8B6B-4C86E0887D42', 'ScopeTaskID', 'One To Many', TRUE, TRUE, 14, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '66644f1a-f908-4241-9e31-5f55928a5c54' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "RelatedEntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "RelatedEntityJoinField" = 'ApprovalTaskID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('66644f1a-f908-4241-9e31-5f55928a5c54', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '02C38B1A-6987-463D-8B6B-4C86E0887D42', 'ApprovalTaskID', 'One To Many', TRUE, TRUE, 15, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = 'b25b6bb5-0b36-4ee4-a80c-8d7d56adf0ef' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "RelatedEntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "RelatedEntityJoinField" = 'TaskID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('b25b6bb5-0b36-4ee4-a80c-8d7d56adf0ef', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'EA40801A-DF1B-443A-B0D3-EA0415645603', 'TaskID', 'One To Many', TRUE, TRUE, 16, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityRelationship" WHERE "ID" = '7929bd74-68ca-4723-9370-28f853808036' OR ("EntityID" = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND "RelatedEntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "RelatedEntityJoinField" = 'ScopeTaskID')
    ) THEN
        INSERT INTO ${mjSchema}."EntityRelationship" ("ID", "EntityID", "RelatedEntityID", "RelatedEntityJoinField", "Type", "BundleInAPI", "DisplayInForm", "Sequence", "__mj_CreatedAt", "__mj_UpdatedAt")
        VALUES ('7929bd74-68ca-4723-9370-28f853808036', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', 'ScopeTaskID', 'One To Many', TRUE, TRUE, 17, NOW(), NOW());
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '93c49e82-2719-4156-aa8a-2645ce9317cc' OR ("EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND "Name" = 'Task')
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
        '93c49e82-2719-4156-aa8a-2645ce9317cc',
        '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- "Entity": "MJ_BizApps_Tasks": "Task" "Agent" "Runs"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '0b1cb8a1-257d-4980-80aa-3654015f2fb1' OR ("EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND "Name" = 'AIAgentRun')
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
        '0b1cb8a1-257d-4980-80aa-3654015f2fb1',
        '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- "Entity": "MJ_BizApps_Tasks": "Task" "Agent" "Runs"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
        'AIAgentRun',
        'AI Agent Run',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'f2ca7c2b-347d-44aa-b01e-a7ed26e7aca0' OR ("EntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND "Name" = 'Entity')
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
        'f2ca7c2b-347d-44aa-b01e-a7ed26e7aca0',
        'D594B91D-4DE0-4D20-8D71-21F041FA505D', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Links"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'D594B91D-4DE0-4D20-8D71-21F041FA505D'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '4616ffe0-a43a-48c7-bef1-910f560dada2' OR ("EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND "Name" = 'Task')
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
        '4616ffe0-a43a-48c7-bef1-910f560dada2',
        '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- "Entity": "MJ_BizApps_Tasks": "Task" "Timers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '1b8bd14f-5709-461b-991d-454184621fe7' OR ("EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND "Name" = 'Person')
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
        '1b8bd14f-5709-461b-991d-454184621fe7',
        '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- "Entity": "MJ_BizApps_Tasks": "Task" "Timers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
        'Person',
        'Person',
        NULL,
        'TEXT',
        500,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'fbe84ae0-8109-43e3-875e-6ec1278b3316' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'ScopeTask')
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
        'fbe84ae0-8109-43e3-875e-6ec1278b3316',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
        'ScopeTask',
        'Scope Task',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '159ae0e7-0b53-4c67-95c0-be5e5df4d5f8' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'ApprovalTask')
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
        '159ae0e7-0b53-4c67-95c0-be5e5df4d5f8',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
        'ApprovalTask',
        'Approval Task',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '6cf66121-2c7f-4838-9b36-c6827c669a27' OR ("EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'DecidedByPerson')
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
        '6cf66121-2c7f-4838-9b36-c6827c669a27',
        '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Approvals"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
        'DecidedByPerson',
        'Decided By Person',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '2c5fc472-6a98-42c4-b0c6-2b3aa529c0c3' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "Name" = 'Person')
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
        '2c5fc472-6a98-42c4-b0c6-2b3aa529c0c3',
        'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- "Entity": "MJ_BizApps_Tasks": "Timesheets"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
        'Person',
        'Person',
        NULL,
        'TEXT',
        500,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'd98d52d7-a33a-43fc-aeff-1b2255a297c3' OR ("EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "Name" = 'SubmittedByUser')
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
        'd98d52d7-a33a-43fc-aeff-1b2255a297c3',
        'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- "Entity": "MJ_BizApps_Tasks": "Timesheets"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
        'SubmittedByUser',
        'Submitted By User',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'a3a97216-e31f-4599-b84c-9ee673e76515' OR ("EntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND "Name" = 'Entity')
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
        'a3a97216-e31f-4599-b84c-9ee673e76515',
        '5A25B67B-D67D-453F-8340-94BF69CF8CEE', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entry" "Links"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '5A25B67B-D67D-453F-8340-94BF69CF8CEE'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '73b0b7c5-fc7f-4254-b4a4-bfadbd47c74f' OR ("EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = 'Person')
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
        '73b0b7c5-fc7f-4254-b4a4-bfadbd47c74f',
        '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Schedules"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '0c906264-ec3d-4e70-9bfe-e0b6d90a2cd7' OR ("EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = 'ScopeEntity')
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
        '0c906264-ec3d-4e70-9bfe-e0b6d90a2cd7',
        '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- "Entity": "MJ_BizApps_Tasks": "Timesheet" "Schedules"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
        'ScopeEntity',
        'Scope Entity',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = 'cc0edc1e-0322-4974-8f85-9d6c0d066070' OR ("EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "Name" = 'Task')
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
        'cc0edc1e-0322-4974-8f85-9d6c0d066070',
        'EA40801A-DF1B-443A-B0D3-EA0415645603', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entries"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '2d457cbe-bb88-4e3b-bc1b-2fa99139c399' OR ("EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "Name" = 'Person')
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
        '2d457cbe-bb88-4e3b-bc1b-2fa99139c399',
        'EA40801A-DF1B-443A-B0D3-EA0415645603', -- "Entity": "MJ_BizApps_Tasks": "Task" "Time" "Entries"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
        'Person',
        'Person',
        NULL,
        'TEXT',
        500,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '9f773da1-6235-49d5-ba9d-1fbd466be64c' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'ApproverPerson')
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
        '9f773da1-6235-49d5-ba9d-1fbd466be64c',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
        'ApproverPerson',
        'Approver Person',
        NULL,
        'TEXT',
        500,
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '05a327a0-e5da-422a-a9d4-0c0da669f5b6' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'WorkerPerson')
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
        '05a327a0-e5da-422a-a9d4-0c0da669f5b6',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
        'WorkerPerson',
        'Worker Person',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '08912325-9de8-41c5-a838-16dbe5e5395b' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'ScopeTask')
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
        '08912325-9de8-41c5-a838-16dbe5e5395b',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
        'ScopeTask',
        'Scope Task',
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
        SELECT 1 FROM ${mjSchema}."EntityField" WHERE "ID" = '1a236b60-be82-457d-9a37-724d713f2d51' OR ("EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'ScopeEntity')
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
        '1a236b60-be82-457d-9a37-724d713f2d51',
        'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- "Entity": "MJ_BizApps_Tasks": "Time" "Approvers"
        (SELECT COALESCE(MAX("Sequence"), 0) + 1 FROM ${mjSchema}."EntityField" WHERE "EntityID" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
        'ScopeEntity',
        'Scope Entity',
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
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = 'A4B7B796-99D1-4283-BC8A-94F6DCD24F4F'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('4d68f0b7-5e82-46cb-8f6d-cf5206324661', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([Minutes]>(0) AND [Minutes]<=(1440))', 'public ValidateMinutesRange(result: ValidationResult) {
        if (this.Minutes != null && (this.Minutes <= 0 || this.Minutes > 1440)) {
        result.Errors.push(new ValidationErrorInfo(
        "Minutes",
        "Minutes worked must be greater than 0 and cannot exceed 1440 (24 hours).",
        this.Minutes,
        ValidationErrorType.Failure
        ));
        }
        }', 'Minutes worked must be greater than 0 and cannot exceed 1,440 minutes (24 hours) in a single entry.', 'ValidateMinutesRange', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', 'A4B7B796-99D1-4283-BC8A-94F6DCD24F4F');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND "Name" = 'ValidateEndedAtOnOrAfterStartedAt'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('06e594ab-c050-4f25-9c59-6247458dabb9', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([StartedAt] IS NULL OR [EndedAt] IS NULL OR [EndedAt]>=[StartedAt])', 'public ValidateEndedAtOnOrAfterStartedAt(result: ValidationResult) {
        if (this.StartedAt != null && this.EndedAt != null && new Date(this.EndedAt).getTime() < new Date(this.StartedAt).getTime()) {
        result.Errors.push(new ValidationErrorInfo(
        "EndedAt",
        "End time must be on or after the start time.",
        this.EndedAt,
        ValidationErrorType.Failure
        ));
        }
        }', 'If both start and end times are recorded, the end time must be at or after the start time.', 'ValidateEndedAtOnOrAfterStartedAt', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'EA40801A-DF1B-443A-B0D3-EA0415645603');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'ValidateEffectiveToOnOrAfterEffectiveFrom'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('a0801bd1-273f-4a08-b7c8-fdff05499bbd', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([EffectiveFrom] IS NULL OR [EffectiveTo] IS NULL OR [EffectiveTo]>=[EffectiveFrom])', 'public ValidateEffectiveToOnOrAfterEffectiveFrom(result: ValidationResult) {
        if (this.EffectiveFrom != null && this.EffectiveTo != null && this.EffectiveTo < this.EffectiveFrom) {
        result.Errors.push(new ValidationErrorInfo(
        "EffectiveTo",
        "Effective To date must be on or after the Effective From date.",
        this.EffectiveTo,
        ValidationErrorType.Failure
        ));
        }
        }', 'The effective end date must be on or after the effective start date when both dates are provided.', 'ValidateEffectiveToOnOrAfterEffectiveFrom', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'ValidateScopeEntityAndRecordPair'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('ecf8dd64-969b-40e3-8dd3-f258b6156f47', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([ScopeEntityID] IS NULL AND [ScopeRecordID] IS NULL OR [ScopeEntityID] IS NOT NULL AND [ScopeRecordID] IS NOT NULL)', '	public ValidateScopeEntityAndRecordPair(result: ValidationResult) {
        const hasEntity = this.ScopeEntityID != null;
        const hasRecord = this.ScopeRecordID != null && this.ScopeRecordID.trim() !== "";
        
        if ((hasEntity && !hasRecord) || (!hasEntity && hasRecord)) {
        result.Errors.push(new ValidationErrorInfo(
        "ScopeEntityID",
        "Scope Entity and Scope Record must either both be provided or both be left empty.",
        this.ScopeEntityID,
        ValidationErrorType.Failure
        ));
        }
        }', 'Scope entity and scope record must either both be specified or both be left empty to ensure consistent scoping.', 'ValidateScopeEntityAndRecordPair', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND "Name" = 'ValidateWorkerPersonIDNotEqualToApproverPersonID'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('ac25be0a-e5d9-4e19-bb6e-299226e53b5b', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([WorkerPersonID] IS NULL OR [WorkerPersonID]<>[ApproverPersonID])', 'public ValidateWorkerPersonIDNotEqualToApproverPersonID(result: ValidationResult) {
        if (this.WorkerPersonID != null && this.WorkerPersonID === this.ApproverPersonID) {
        result.Errors.push(new ValidationErrorInfo(
        "WorkerPersonID",
        "The worker cannot be the same person as the approver.",
        this.WorkerPersonID,
        ValidationErrorType.Failure
        ));
        }
        }', 'The worker person cannot be the same as the approver person.', 'ValidateWorkerPersonIDNotEqualToApproverPersonID', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = 'BDBEC7EF-0A27-480E-8DD3-B1697358CF3A'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('d785b476-2c17-48c0-80aa-161448170f7a', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([SubmissionRound]>=(1))', '	public ValidateSubmissionRoundMinimum(result: ValidationResult) {
        if (this.SubmissionRound != null && this.SubmissionRound < 1) {
        result.Errors.push(new ValidationErrorInfo(
        "SubmissionRound",
        "Submission round must be at least 1.",
        this.SubmissionRound,
        ValidationErrorType.Failure
        ));
        }
        }', 'Submission round must be 1 or greater.', 'ValidateSubmissionRoundMinimum', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', 'BDBEC7EF-0A27-480E-8DD3-B1697358CF3A');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND "Name" = 'ValidateTimesheetMinutesAndEntryCount'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('5dee8e6a-e17e-4e11-a81f-e5e5568e865c', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([Minutes]>=(0) AND [BillableMinutes]>=(0) AND [BillableMinutes]<=[Minutes] AND [EntryCount]>=(0))', 'public ValidateTimesheetMinutesAndEntryCount(result: ValidationResult) {
        if (this.Minutes != null && this.Minutes < 0) {
        result.Errors.push(new ValidationErrorInfo(
        "Minutes",
        "Minutes cannot be negative.",
        this.Minutes,
        ValidationErrorType.Failure
        ));
        }
        if (this.BillableMinutes != null && this.BillableMinutes < 0) {
        result.Errors.push(new ValidationErrorInfo(
        "BillableMinutes",
        "Billable minutes cannot be negative.",
        this.BillableMinutes,
        ValidationErrorType.Failure
        ));
        }
        if (this.BillableMinutes != null && this.Minutes != null && this.BillableMinutes > this.Minutes) {
        result.Errors.push(new ValidationErrorInfo(
        "BillableMinutes",
        "Billable minutes cannot exceed total minutes.",
        this.BillableMinutes,
        ValidationErrorType.Failure
        ));
        }
        if (this.EntryCount != null && this.EntryCount < 0) {
        result.Errors.push(new ValidationErrorInfo(
        "EntryCount",
        "Entry count cannot be negative.",
        this.EntryCount,
        ValidationErrorType.Failure
        ));
        }
        }', 'Minutes, billable minutes, and entry count must all be non-negative (zero or greater), and billable minutes cannot exceed the total minutes recorded.', 'ValidateTimesheetMinutesAndEntryCount', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '02C38B1A-6987-463D-8B6B-4C86E0887D42');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = 'ValidateEffectiveToOnOrAfterEffectiveFrom'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('e2cb08d9-6e2c-41d6-ae13-c31c1406eefd', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([EffectiveTo] IS NULL OR [EffectiveTo]>=[EffectiveFrom])', 'public ValidateEffectiveToOnOrAfterEffectiveFrom(result: ValidationResult) {
        if (this.EffectiveTo != null && this.EffectiveFrom != null && this.EffectiveTo < this.EffectiveFrom) {
        result.Errors.push(new ValidationErrorInfo(
        "EffectiveTo",
        "Effective To date must be on or after the Effective From date.",
        this.EffectiveTo,
        ValidationErrorType.Failure
        ));
        }
        }', 'Effective to date must be on or after the effective from date, ensuring the validity period is chronologically correct.', 'ValidateEffectiveToOnOrAfterEffectiveFrom', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '6A27830F-A203-4D3E-8ADF-B1085E1F908C');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = 'ValidatePersonIDAndScopeEntityIDMutualExclusivity'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('deddd970-bb49-4b24-8b7a-705312645809', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([PersonID] IS NULL OR [ScopeEntityID] IS NULL)', '	public ValidatePersonIDAndScopeEntityIDMutualExclusivity(result: ValidationResult) {
        if (this.PersonID != null && this.ScopeEntityID != null) {
        result.Errors.push(new ValidationErrorInfo(
        "PersonID",
        "A record cannot have both a Person and a Scope Entity specified.",
        this.PersonID,
        ValidationErrorType.Failure
        ));
        }
        }', 'A record cannot be assigned to both a specific person and a scope entity at the same time; at least one of these assignments must remain empty.', 'ValidatePersonIDAndScopeEntityIDMutualExclusivity', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '6A27830F-A203-4D3E-8ADF-B1085E1F908C');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND "Name" = 'ValidateScopeEntityIDAndScopeRecordIDCoexistence'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('03bc9ac8-7625-454b-abc1-f20b8987ea2e', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([ScopeEntityID] IS NULL AND [ScopeRecordID] IS NULL OR [ScopeEntityID] IS NOT NULL AND [ScopeRecordID] IS NOT NULL)', 'public ValidateScopeEntityIDAndScopeRecordIDCoexistence(result: ValidationResult) {
        const hasEntity = this.ScopeEntityID != null;
        const hasRecord = this.ScopeRecordID != null && this.ScopeRecordID.trim() !== "";
        
        if ((hasEntity && !hasRecord) || (!hasEntity && hasRecord)) {
        result.Errors.push(new ValidationErrorInfo(
        "ScopeEntityID",
        "Both Scope Entity and Scope Record must be provided together, or both must be omitted.",
        this.ScopeEntityID,
        ValidationErrorType.Failure
        ));
        }
        }', 'Scope entity and scope record must either both be provided or both be left empty.', 'ValidateScopeEntityIDAndScopeRecordIDCoexistence', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '6A27830F-A203-4D3E-8ADF-B1085E1F908C');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "Name" = 'ValidatePeriodEndOnOrAfterPeriodStart'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('3a1c7393-0742-4cdf-940d-c4919d4d4311', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([PeriodEnd]>=[PeriodStart])', 'public ValidatePeriodEndOnOrAfterPeriodStart(result: ValidationResult) {
        if (this.PeriodStart != null && this.PeriodEnd != null && this.PeriodEnd < this.PeriodStart) {
        result.Errors.push(new ValidationErrorInfo(
        "PeriodEnd",
        "The period end date must be on or after the period start date.",
        this.PeriodEnd,
        ValidationErrorType.Failure
        ));
        }
        }', 'Period end date must be on or after the period start date.', 'ValidatePeriodEndOnOrAfterPeriodStart', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'ED90EE09-0D39-4298-93DC-77C057FCE97A');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM ${mjSchema}."GeneratedCode" WHERE "CategoryID" = (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators') AND "LinkedEntityID" = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND "LinkedRecordPrimaryKey" = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND "Name" = 'ValidateTotalAndBillableMinutes'
    ) THEN
        INSERT INTO ${mjSchema}."GeneratedCode" ("ID", "CategoryID", "GeneratedByModelID", "GeneratedAt", "Language", "Status", "Source", "Code", "Description", "Name", "LinkedEntityID", "LinkedRecordPrimaryKey")
        VALUES ('a79faf46-3ce9-45c1-811c-83495b1c93c0', (SELECT "ID" FROM ${mjSchema}."vwGeneratedCodeCategories" WHERE "Name"='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', NOW(), 'TypeScript', 'Approved', '([TotalMinutes]>=(0) AND [BillableMinutes]>=(0) AND [BillableMinutes]<=[TotalMinutes])', 'public ValidateTotalAndBillableMinutes(result: ValidationResult) {
        if (this.TotalMinutes != null && this.TotalMinutes < 0) {
        result.Errors.push(new ValidationErrorInfo(
        "TotalMinutes",
        "Total minutes cannot be negative.",
        this.TotalMinutes,
        ValidationErrorType.Failure
        ));
        }
        
        if (this.BillableMinutes != null && this.BillableMinutes < 0) {
        result.Errors.push(new ValidationErrorInfo(
        "BillableMinutes",
        "Billable minutes cannot be negative.",
        this.BillableMinutes,
        ValidationErrorType.Failure
        ));
        }
        
        if (this.TotalMinutes != null && this.BillableMinutes != null && this.BillableMinutes > this.TotalMinutes) {
        result.Errors.push(new ValidationErrorInfo(
        "BillableMinutes",
        "Billable minutes cannot exceed total minutes.",
        this.BillableMinutes,
        ValidationErrorType.Failure
        ));
        }
        }', 'Total minutes and billable minutes must both be zero or positive, and billable minutes cannot exceed total minutes.', 'ValidateTotalAndBillableMinutes', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'ED90EE09-0D39-4298-93DC-77C057FCE97A');
    END IF;
END $$;


-- ===================== Grants =====================

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskAgentRuns" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Agent Runs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Agent Runs
-- Item: Permissions for vwTaskAgentRuns
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskAgentRuns" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Agent Runs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Agent Runs
-- Item: spCreateTaskAgentRun
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskAgentRun
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskAgentRun" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Agent Runs */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskAgentRun" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Agent Runs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Agent Runs
-- Item: spUpdateTaskAgentRun
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskAgentRun
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskAgentRun" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskAgentRun" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Agent Runs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Agent Runs
-- Item: spDeleteTaskAgentRun
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskAgentRun
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskAgentRun" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Agent Runs */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskAgentRun" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Index for Foreign Keys for TaskTimeEntry */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Time Entries
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskID in table TaskTimeEntry;

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
/* Base View SQL for MJ_BizApps_Tasks: Task Time Entry Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Time Entry Links
-- Item: vwTaskTimeEntryLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Time Entry Links
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  TaskTimeEntryLink
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTimeEntryLinks" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Time Entry Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Time Entry Links
-- Item: Permissions for vwTaskTimeEntryLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTimeEntryLinks" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Time Entry Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Time Entry Links
-- Item: spCreateTaskTimeEntryLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTimeEntryLink
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTimeEntryLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Time Entry Links */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTimeEntryLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Time Entry Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Time Entry Links
-- Item: spUpdateTaskTimeEntryLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTimeEntryLink
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTimeEntryLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTimeEntryLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Time Entry Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Time Entry Links
-- Item: spDeleteTaskTimeEntryLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTimeEntryLink
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTimeEntryLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Time Entry Links */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTimeEntryLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* SQL text to update entity field related entity name field map for entity field ID 5CC9964F-5CA5-4BE3-9237-9901052413B3 */

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTimers" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Timers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Timers
-- Item: Permissions for vwTaskTimers
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTimers" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Timers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Timers
-- Item: spCreateTaskTimer
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTimer
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTimer" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Timers */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTimer" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Timers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Timers
-- Item: spUpdateTaskTimer
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTimer
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTimer" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTimer" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Timers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Timers
-- Item: spDeleteTaskTimer
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTimer
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTimer" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Timers */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTimer" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View SQL for MJ_BizApps_Tasks: Task Time Entries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Time Entries
-- Item: vwTaskTimeEntries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Time Entries
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  TaskTimeEntry
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTimeEntries" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Time Entries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Time Entries
-- Item: Permissions for vwTaskTimeEntries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTaskTimeEntries" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Task Time Entries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Time Entries
-- Item: spCreateTaskTimeEntry
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TaskTimeEntry
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTimeEntry" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Task Time Entries */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTaskTimeEntry" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Task Time Entries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Time Entries
-- Item: spUpdateTaskTimeEntry
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TaskTimeEntry
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTimeEntry" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTaskTimeEntry" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Task Time Entries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Time Entries
-- Item: spDeleteTaskTimeEntry
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TaskTimeEntry
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTimeEntry" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Task Time Entries */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTaskTimeEntry" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
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
/* Base View SQL for MJ_BizApps_Tasks: Timesheet Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Links
-- Item: vwTimesheetLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Timesheet Links
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  TimesheetLink
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTimesheetLinks" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Timesheet Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Links
-- Item: Permissions for vwTimesheetLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTimesheetLinks" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Timesheet Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Links
-- Item: spCreateTimesheetLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TimesheetLink
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTimesheetLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Timesheet Links */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTimesheetLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Timesheet Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Links
-- Item: spUpdateTimesheetLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TimesheetLink
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTimesheetLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTimesheetLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Timesheet Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Links
-- Item: spDeleteTimesheetLink
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TimesheetLink
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTimesheetLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Timesheet Links */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTimesheetLink" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* SQL text to update entity field related entity name field map for entity field ID BC31C246-345F-4A54-8C9F-A09F01295492 */

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTimesheetSchedules" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Timesheet Schedules */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Schedules
-- Item: Permissions for vwTimesheetSchedules
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTimesheetSchedules" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Timesheet Schedules */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Schedules
-- Item: spCreateTimesheetSchedule
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TimesheetSchedule
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTimesheetSchedule" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Timesheet Schedules */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTimesheetSchedule" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Timesheet Schedules */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Schedules
-- Item: spUpdateTimesheetSchedule
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TimesheetSchedule
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTimesheetSchedule" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTimesheetSchedule" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Timesheet Schedules */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Schedules
-- Item: spDeleteTimesheetSchedule
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TimesheetSchedule
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTimesheetSchedule" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Timesheet Schedules */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTimesheetSchedule" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* SQL text to update entity field related entity name field map for entity field ID 690C2A28-5F12-47DE-8580-12E6F0990EC7 */

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTimesheets" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Timesheets */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheets
-- Item: Permissions for vwTimesheets
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTimesheets" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Timesheets */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheets
-- Item: spCreateTimesheet
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR Timesheet
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTimesheet" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Timesheets */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTimesheet" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Timesheets */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheets
-- Item: spUpdateTimesheet
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR Timesheet
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTimesheet" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTimesheet" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Timesheets */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheets
-- Item: spDeleteTimesheet
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR Timesheet
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTimesheet" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Timesheets */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTimesheet" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* SQL text to update entity field related entity name field map for entity field ID FE1BF4B9-32B1-4EDC-9E13-DBE524F895A6 */

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTimesheetApprovals" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Timesheet Approvals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Approvals
-- Item: Permissions for vwTimesheetApprovals
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTimesheetApprovals" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Timesheet Approvals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Approvals
-- Item: spCreateTimesheetApproval
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TimesheetApproval
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTimesheetApproval" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Timesheet Approvals */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTimesheetApproval" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Timesheet Approvals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Approvals
-- Item: spUpdateTimesheetApproval
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TimesheetApproval
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTimesheetApproval" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTimesheetApproval" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Timesheet Approvals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Approvals
-- Item: spDeleteTimesheetApproval
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TimesheetApproval
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTimesheetApproval" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Timesheet Approvals */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTimesheetApproval" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View SQL for MJ_BizApps_Tasks: Time Approvers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Time Approvers
-- Item: vwTimeApprovers
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Time Approvers
-----               SCHEMA:      __mj_BizAppsTasks
-----               BASE TABLE:  TimeApprover
-----               PRIMARY KEY: ID
------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTimeApprovers" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* Base View Permissions SQL for MJ_BizApps_Tasks: Time Approvers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Time Approvers
-- Item: Permissions for vwTimeApprovers
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

DO $$ BEGIN GRANT SELECT ON __mj_BizAppsTasks."vwTimeApprovers" TO "cdp_UI", "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate SQL for MJ_BizApps_Tasks: Time Approvers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Time Approvers
-- Item: spCreateTimeApprover
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR TimeApprover
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTimeApprover" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spCreate Permissions for MJ_BizApps_Tasks: Time Approvers */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spCreateTimeApprover" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spUpdate SQL for MJ_BizApps_Tasks: Time Approvers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Time Approvers
-- Item: spUpdateTimeApprover
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR TimeApprover
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTimeApprover" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spUpdateTimeApprover" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete SQL for MJ_BizApps_Tasks: Time Approvers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Time Approvers
-- Item: spDeleteTimeApprover
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR TimeApprover
------------------------------------------------------------;

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTimeApprover" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* spDelete Permissions for MJ_BizApps_Tasks: Time Approvers */

DO $$ BEGIN GRANT EXECUTE ON FUNCTION __mj_BizAppsTasks."spDeleteTimeApprover" TO "cdp_Developer", "cdp_Integration"; EXCEPTION WHEN others THEN NULL; END $$;
/* SQL text to insert 19 new entity field(s) */


-- ===================== Comments =====================

COMMENT ON TABLE __mj_BizAppsTasks."TaskTimeEntry" IS 'Individual time entries logged by a person against a task on a specific business calendar date.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimeEntry"."ID" IS 'Primary key for the task time entry.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimeEntry"."TaskID" IS 'The task this time entry is logged against.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimeEntry"."PersonID" IS 'The Person who performed the work.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimeEntry"."WorkDate" IS 'Business calendar date the work was performed on.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimeEntry"."Minutes" IS 'Duration of work in whole minutes (1 to 1440).';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimeEntry"."StartedAt" IS 'Optional timestamp when the work interval started (populated for timer-backed entries).';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimeEntry"."EndedAt" IS 'Optional timestamp when the work interval ended (populated for timer-backed entries).';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimeEntry"."Notes" IS 'Narrative description of what was accomplished during this time entry.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimeEntry"."Source" IS 'How the time entry was created: Manual, Timer, Imported, or Agent.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimeEntry"."IsBillable" IS 'Whether this time entry is billable to a client or external party.';

COMMENT ON TABLE __mj_BizAppsTasks."TaskTimer" IS 'Currently running task stopwatch per person. At most one row per PersonID exists at any time; stopping a timer deletes the row and writes TaskTimeEntry rows.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimer"."ID" IS 'Primary key for the running timer.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimer"."TaskID" IS 'The task currently being timed.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimer"."PersonID" IS 'The Person whose stopwatch is running (unique across TaskTimer).';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimer"."StartedAt" IS 'Timestamp when the timer was started.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimer"."Notes" IS 'Draft work notes carried over into the resulting TaskTimeEntry rows when the timer stops.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimer"."IsBillable" IS 'Billable flag carried over into the resulting TaskTimeEntry rows when the timer stops.';

COMMENT ON TABLE __mj_BizAppsTasks."TaskAgentRun" IS 'Links a task to a MemberJunction AI Agent Run so agent effort (runs, tokens, cost, wall-clock duration) is attributed alongside human time.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskAgentRun"."ID" IS 'Primary key for the task agent run link.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskAgentRun"."TaskID" IS 'The task the AI agent run contributed to.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskAgentRun"."AIAgentRunID" IS 'The MemberJunction AI Agent Run linked to the task.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskAgentRun"."Role" IS 'How the agent run contributed to the task: Executed, Assisted, Reviewed, Planned, or Triaged.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskAgentRun"."Notes" IS 'Optional notes describing what the agent run did for the task.';

COMMENT ON TABLE __mj_BizAppsTasks."Timesheet" IS 'Period timesheet header for a person, grouping task time entries across a date range for submission and approval.';

COMMENT ON COLUMN __mj_BizAppsTasks."Timesheet"."ID" IS 'Primary key for the timesheet.';

COMMENT ON COLUMN __mj_BizAppsTasks."Timesheet"."PersonID" IS 'The Person whose time entries are covered by this timesheet.';

COMMENT ON COLUMN __mj_BizAppsTasks."Timesheet"."PeriodStart" IS 'Inclusive start date of the timesheet period.';

COMMENT ON COLUMN __mj_BizAppsTasks."Timesheet"."PeriodEnd" IS 'Inclusive end date of the timesheet period.';

COMMENT ON COLUMN __mj_BizAppsTasks."Timesheet"."Status" IS 'Lifecycle status of the timesheet: Draft, Submitted, Approved, or Rejected.';

COMMENT ON COLUMN __mj_BizAppsTasks."Timesheet"."SubmittedAt" IS 'Timestamp when the timesheet was most recently submitted.';

COMMENT ON COLUMN __mj_BizAppsTasks."Timesheet"."SubmittedByUserID" IS 'The MemberJunction User who submitted the timesheet.';

COMMENT ON COLUMN __mj_BizAppsTasks."Timesheet"."TotalMinutes" IS 'Total minutes across all time entries attached to this timesheet.';

COMMENT ON COLUMN __mj_BizAppsTasks."Timesheet"."BillableMinutes" IS 'Total billable minutes across all time entries attached to this timesheet.';

COMMENT ON COLUMN __mj_BizAppsTasks."Timesheet"."Notes" IS 'Worker notes or comments submitted with the timesheet.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimeEntry"."TimesheetID" IS 'Optional Timesheet this time entry has been attached to.';

COMMENT ON TABLE __mj_BizAppsTasks."TimesheetApproval" IS 'Per-project approval slice of a submitted timesheet, backed by a real approval Task in the Tasks inbox.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetApproval"."ID" IS 'Primary key for the timesheet approval part.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetApproval"."TimesheetID" IS 'The Timesheet this approval slice belongs to.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetApproval"."SubmissionRound" IS 'Submission round number (1 on initial submit, incremented on each resubmit).';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetApproval"."ScopeTaskID" IS 'Root project task for this approval slice, or NULL for the whole-timesheet / unassigned slice.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetApproval"."ApprovalTaskID" IS 'The approval Task created in the Tasks inbox for this slice.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetApproval"."Minutes" IS 'Total minutes in this approval slice at submission time.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetApproval"."BillableMinutes" IS 'Total billable minutes in this approval slice at submission time.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetApproval"."EntryCount" IS 'Number of TaskTimeEntry rows included in this approval slice.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetApproval"."SnapshotHash" IS 'Deterministic SHA-256 hex digest of the slice time entries, used to carry forward unchanged Approved parts across resubmissions.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetApproval"."Status" IS 'Current status of this approval slice: Pending, Approved, Rejected, or Canceled.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetApproval"."DecidedByPersonID" IS 'The Person who recorded the approval or rejection decision.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetApproval"."DecidedAt" IS 'Timestamp when the decision on this slice was recorded.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetApproval"."DecisionNotes" IS 'Notes or feedback provided by the approver when deciding this slice.';

COMMENT ON TABLE __mj_BizAppsTasks."TimeApprover" IS 'Configurable directory of who approves whose time, optionally scoped to a specific worker, root project task, or external entity record.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimeApprover"."ID" IS 'Primary key for the time approver rule.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimeApprover"."ApproverPersonID" IS 'The Person who is granted time approval authority by this rule.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimeApprover"."WorkerPersonID" IS 'Optional Worker Person whose time this rule applies to (NULL matches any worker).';

COMMENT ON COLUMN __mj_BizAppsTasks."TimeApprover"."ScopeTaskID" IS 'Optional project/parent Task this rule scopes approval to (NULL matches any task).';

COMMENT ON COLUMN __mj_BizAppsTasks."TimeApprover"."IncludeDescendants" IS 'When ScopeTaskID is set, whether sub-tasks beneath ScopeTaskID also match this rule.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimeApprover"."ScopeEntityID" IS 'Optional MJ Entity ID when scoping approval to tasks linked to an external record via TaskLink.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimeApprover"."ScopeRecordID" IS 'Companion record ID in ScopeEntityID when scoping approval to tasks linked via TaskLink.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimeApprover"."EffectiveFrom" IS 'Optional start date from which this approver rule is effective.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimeApprover"."EffectiveTo" IS 'Optional end date through which this approver rule is effective.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimeApprover"."IsActive" IS 'Whether this approver rule is currently active.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimeApprover"."Notes" IS 'Optional administrative notes about this approver rule.';

COMMENT ON TABLE __mj_BizAppsTasks."TimesheetLink" IS 'Polymorphic links from a Timesheet to external records such as payroll batches, invoices, or expense reports.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetLink"."ID" IS 'Primary key for the timesheet link.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetLink"."TimesheetID" IS 'The Timesheet being linked.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetLink"."EntityID" IS 'Target MemberJunction Entity ID for the linked external record.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetLink"."RecordID" IS 'Primary key value of the linked record in EntityID.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetLink"."Relationship" IS 'Semantic relationship of the linked record to the timesheet: PayrollBatch, Invoice, ExpenseReport, or Related.';

COMMENT ON TABLE __mj_BizAppsTasks."TaskTimeEntryLink" IS 'Polymorphic links from a TaskTimeEntry to external records such as invoice lines, journal entry lines, commits, or pull requests.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimeEntryLink"."ID" IS 'Primary key for the task time entry link.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimeEntryLink"."TaskTimeEntryID" IS 'The TaskTimeEntry being linked.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimeEntryLink"."EntityID" IS 'Target MemberJunction Entity ID for the linked external record.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimeEntryLink"."RecordID" IS 'Primary key value of the linked record in EntityID.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskTimeEntryLink"."Relationship" IS 'Semantic relationship of the linked record to the time entry: InvoiceLine, JournalEntryLine, Commit, PullRequest, or Related.';

COMMENT ON TABLE __mj_BizAppsTasks."TimesheetSchedule" IS 'Effective-dated timesheet period cadence schedule, globally or scoped to a specific Person or external entity record.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetSchedule"."ID" IS 'Primary key for the timesheet schedule.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetSchedule"."PersonID" IS 'Optional Person this schedule applies to (NULL for organization/entity-scoped or global schedules).';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetSchedule"."ScopeEntityID" IS 'Optional MJ Entity ID when scoping the schedule to an organization or department record.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetSchedule"."ScopeRecordID" IS 'Companion record ID in ScopeEntityID for entity-scoped schedules.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetSchedule"."Cadence" IS 'Timesheet period cadence: Weekly, BiWeekly, SemiMonthly, or Monthly.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetSchedule"."WeekStartDay" IS 'First day of the work week for Weekly and BiWeekly cadences: Monday, Sunday, or Saturday.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetSchedule"."BiWeeklyAnchorDate" IS 'Anchor date (which must fall on WeekStartDay) defining the 14-day boundary for BiWeekly cadences.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetSchedule"."EffectiveFrom" IS 'Inclusive start date from which this schedule is effective (must fall on a period boundary).';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetSchedule"."EffectiveTo" IS 'Optional inclusive end date through which this schedule is effective.';

COMMENT ON COLUMN __mj_BizAppsTasks."TimesheetSchedule"."Notes" IS 'Optional notes explaining this schedule or cadence change.';

COMMENT ON COLUMN __mj_BizAppsTasks."TaskType"."RequiresAssigneeDecision" IS 'When true on an approval task type, only an assigned approver (and never the task creator unless exempt) may record a decision on tasks of this type, regardless of the global PreventSelfApproval setting.';


-- ===================== Other =====================

-- =============================================================================
-- GENERATED BY MemberJunction CodeGen — DO NOT EDIT BY HAND
-- =============================================================================

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Time Entries */

/* SQL text to insert 99 new entity field(s) */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Agent Runs */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Types */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Time Entry Links */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Timers */

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Time Entries */

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

/* spUpdate Permissions for MJ_BizApps_Tasks: Timesheet Links */

/* spUpdate Permissions for MJ_BizApps_Tasks: Timesheet Schedules */

/* spUpdate Permissions for MJ_BizApps_Tasks: Timesheets */

/* spUpdate Permissions for MJ_BizApps_Tasks: Timesheet Approvals */

/* spUpdate Permissions for MJ_BizApps_Tasks: Time Approvers */
