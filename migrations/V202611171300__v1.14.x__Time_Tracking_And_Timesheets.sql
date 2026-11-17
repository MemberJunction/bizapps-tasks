-- =============================================================================
-- BizApps Tasks v1.11.0 — Time Tracking, Agent Effort, and Timesheets
-- =============================================================================
-- Adds:
--   1. TaskTimeEntry        — human & agent time entries logged against tasks
--   2. TaskTimer            — at most one running stopwatch per person
--   3. TaskAgentRun         — links Tasks to MJ: AI Agent Runs
--   4. Timesheet            — period header per person + TaskTimeEntry.TimesheetID FK
--   5. TimesheetApproval    — per-project approval parts backed by Tasks
--   6. TimeApprover         — configurable time approver directory
--   7. TimesheetLink        — polymorphic links from Timesheet to external records
--   8. TaskTimeEntryLink    — polymorphic links from TaskTimeEntry to external records
--   9. TimesheetSchedule    — effective-dated cadence history
--  10. TaskType.RequiresAssigneeDecision — decision authority column on TaskType
--  11. vwTaskRootAgentEffort & rebuilt vwTasks with LoggedMinutes, AgentRunCount,
--      AgentCost, and AgentTokens virtual columns
-- =============================================================================

---------------------------------------------------------------------------
-- 1. TaskTimeEntry
---------------------------------------------------------------------------
CREATE TABLE [${flyway:defaultSchema}].[TaskTimeEntry] (
    [ID]          UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_TaskTimeEntry_ID] DEFAULT (NEWSEQUENTIALID()),
    [TaskID]      UNIQUEIDENTIFIER NOT NULL,
    [PersonID]    UNIQUEIDENTIFIER NOT NULL,
    [WorkDate]    DATE             NOT NULL,
    [Minutes]     INT              NOT NULL,
    [StartedAt]   DATETIMEOFFSET   NULL,
    [EndedAt]     DATETIMEOFFSET   NULL,
    [Notes]       NVARCHAR(MAX)    NULL,
    [Source]      NVARCHAR(20)     NOT NULL CONSTRAINT [DF_TaskTimeEntry_Source] DEFAULT ('Manual'),
    [IsBillable]  BIT              NOT NULL CONSTRAINT [DF_TaskTimeEntry_IsBillable] DEFAULT (0),

    CONSTRAINT [PK_TaskTimeEntry] PRIMARY KEY ([ID]),
    CONSTRAINT [FK_TaskTimeEntry_Task]
        FOREIGN KEY ([TaskID]) REFERENCES [${flyway:defaultSchema}].[Task]([ID]),
    CONSTRAINT [FK_TaskTimeEntry_Person]
        FOREIGN KEY ([PersonID]) REFERENCES [__mj_BizAppsCommon].[Person]([ID]),
    CONSTRAINT [CK_TaskTimeEntry_Minutes]
        CHECK ([Minutes] > 0 AND [Minutes] <= 1440),
    CONSTRAINT [CK_TaskTimeEntry_Source]
        CHECK ([Source] IN ('Manual', 'Timer', 'Imported', 'Agent')),
    CONSTRAINT [CK_TaskTimeEntry_TimeRange]
        CHECK ([StartedAt] IS NULL OR [EndedAt] IS NULL OR [EndedAt] >= [StartedAt])
);
GO

CREATE INDEX [IDX_TaskTimeEntry_Task_WorkDate]
    ON [${flyway:defaultSchema}].[TaskTimeEntry] ([TaskID], [WorkDate] DESC)
    INCLUDE ([Minutes], [PersonID], [IsBillable]);
GO

CREATE INDEX [IDX_TaskTimeEntry_Person_WorkDate]
    ON [${flyway:defaultSchema}].[TaskTimeEntry] ([PersonID], [WorkDate] DESC)
    INCLUDE ([Minutes], [TaskID], [IsBillable]);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Individual time entries logged by a person against a task on a specific business calendar date.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntry';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Primary key for the task time entry.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntry',
    @level2type = N'COLUMN', @level2name = N'ID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The task this time entry is logged against.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntry',
    @level2type = N'COLUMN', @level2name = N'TaskID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The Person who performed the work.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntry',
    @level2type = N'COLUMN', @level2name = N'PersonID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Business calendar date the work was performed on.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntry',
    @level2type = N'COLUMN', @level2name = N'WorkDate';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Duration of work in whole minutes (1 to 1440).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntry',
    @level2type = N'COLUMN', @level2name = N'Minutes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional timestamp when the work interval started (populated for timer-backed entries).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntry',
    @level2type = N'COLUMN', @level2name = N'StartedAt';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional timestamp when the work interval ended (populated for timer-backed entries).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntry',
    @level2type = N'COLUMN', @level2name = N'EndedAt';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Narrative description of what was accomplished during this time entry.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntry',
    @level2type = N'COLUMN', @level2name = N'Notes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'How the time entry was created: Manual, Timer, Imported, or Agent.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntry',
    @level2type = N'COLUMN', @level2name = N'Source';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether this time entry is billable to a client or external party.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntry',
    @level2type = N'COLUMN', @level2name = N'IsBillable';
GO

---------------------------------------------------------------------------
-- 2. TaskTimer
---------------------------------------------------------------------------
CREATE TABLE [${flyway:defaultSchema}].[TaskTimer] (
    [ID]          UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_TaskTimer_ID] DEFAULT (NEWSEQUENTIALID()),
    [TaskID]      UNIQUEIDENTIFIER NOT NULL,
    [PersonID]    UNIQUEIDENTIFIER NOT NULL,
    [StartedAt]   DATETIMEOFFSET   NOT NULL CONSTRAINT [DF_TaskTimer_StartedAt] DEFAULT (SYSDATETIMEOFFSET()),
    [Notes]       NVARCHAR(MAX)    NULL,
    [IsBillable]  BIT              NOT NULL CONSTRAINT [DF_TaskTimer_IsBillable] DEFAULT (0),

    CONSTRAINT [PK_TaskTimer] PRIMARY KEY ([ID]),
    CONSTRAINT [FK_TaskTimer_Task]
        FOREIGN KEY ([TaskID]) REFERENCES [${flyway:defaultSchema}].[Task]([ID]),
    CONSTRAINT [FK_TaskTimer_Person]
        FOREIGN KEY ([PersonID]) REFERENCES [__mj_BizAppsCommon].[Person]([ID]),
    CONSTRAINT [UQ_TaskTimer_Person] UNIQUE ([PersonID])
);
GO

CREATE INDEX [IDX_TaskTimer_Task]
    ON [${flyway:defaultSchema}].[TaskTimer] ([TaskID]);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Currently running task stopwatch per person. At most one row per PersonID exists at any time; stopping a timer deletes the row and writes TaskTimeEntry rows.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimer';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Primary key for the running timer.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimer',
    @level2type = N'COLUMN', @level2name = N'ID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The task currently being timed.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimer',
    @level2type = N'COLUMN', @level2name = N'TaskID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The Person whose stopwatch is running (unique across TaskTimer).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimer',
    @level2type = N'COLUMN', @level2name = N'PersonID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the timer was started.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimer',
    @level2type = N'COLUMN', @level2name = N'StartedAt';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Draft work notes carried over into the resulting TaskTimeEntry rows when the timer stops.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimer',
    @level2type = N'COLUMN', @level2name = N'Notes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Billable flag carried over into the resulting TaskTimeEntry rows when the timer stops.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimer',
    @level2type = N'COLUMN', @level2name = N'IsBillable';
GO

---------------------------------------------------------------------------
-- 3. TaskAgentRun
---------------------------------------------------------------------------
CREATE TABLE [${flyway:defaultSchema}].[TaskAgentRun] (
    [ID]            UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_TaskAgentRun_ID] DEFAULT (NEWSEQUENTIALID()),
    [TaskID]        UNIQUEIDENTIFIER NOT NULL,
    [AIAgentRunID]  UNIQUEIDENTIFIER NOT NULL,
    [Role]          NVARCHAR(30)     NOT NULL CONSTRAINT [DF_TaskAgentRun_Role] DEFAULT ('Executed'),
    [Notes]         NVARCHAR(MAX)    NULL,

    CONSTRAINT [PK_TaskAgentRun] PRIMARY KEY ([ID]),
    CONSTRAINT [FK_TaskAgentRun_Task]
        FOREIGN KEY ([TaskID]) REFERENCES [${flyway:defaultSchema}].[Task]([ID]),
    CONSTRAINT [FK_TaskAgentRun_AIAgentRun]
        FOREIGN KEY ([AIAgentRunID]) REFERENCES [__mj].[AIAgentRun]([ID]),
    CONSTRAINT [UQ_TaskAgentRun_Task_Run] UNIQUE ([TaskID], [AIAgentRunID]),
    CONSTRAINT [CK_TaskAgentRun_Role]
        CHECK ([Role] IN ('Executed', 'Assisted', 'Reviewed', 'Planned', 'Triaged'))
);
GO

CREATE INDEX [IDX_TaskAgentRun_AIAgentRun]
    ON [${flyway:defaultSchema}].[TaskAgentRun] ([AIAgentRunID]);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Links a task to a MemberJunction AI Agent Run so agent effort (runs, tokens, cost, wall-clock duration) is attributed alongside human time.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskAgentRun';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Primary key for the task agent run link.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskAgentRun',
    @level2type = N'COLUMN', @level2name = N'ID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The task the AI agent run contributed to.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskAgentRun',
    @level2type = N'COLUMN', @level2name = N'TaskID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The MemberJunction AI Agent Run linked to the task.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskAgentRun',
    @level2type = N'COLUMN', @level2name = N'AIAgentRunID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'How the agent run contributed to the task: Executed, Assisted, Reviewed, Planned, or Triaged.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskAgentRun',
    @level2type = N'COLUMN', @level2name = N'Role';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional notes describing what the agent run did for the task.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskAgentRun',
    @level2type = N'COLUMN', @level2name = N'Notes';
GO

---------------------------------------------------------------------------
-- 4. Timesheet & TaskTimeEntry.TimesheetID FK
---------------------------------------------------------------------------
CREATE TABLE [${flyway:defaultSchema}].[Timesheet] (
    [ID]                  UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_Timesheet_ID] DEFAULT (NEWSEQUENTIALID()),
    [PersonID]            UNIQUEIDENTIFIER NOT NULL,
    [PeriodStart]         DATE             NOT NULL,
    [PeriodEnd]           DATE             NOT NULL,
    [Status]              NVARCHAR(20)     NOT NULL CONSTRAINT [DF_Timesheet_Status] DEFAULT ('Draft'),
    [SubmittedAt]         DATETIMEOFFSET   NULL,
    [SubmittedByUserID]   UNIQUEIDENTIFIER NULL,
    [TotalMinutes]        INT              NOT NULL CONSTRAINT [DF_Timesheet_TotalMinutes] DEFAULT (0),
    [BillableMinutes]     INT              NOT NULL CONSTRAINT [DF_Timesheet_BillableMinutes] DEFAULT (0),
    [Notes]               NVARCHAR(MAX)    NULL,

    CONSTRAINT [PK_Timesheet] PRIMARY KEY ([ID]),
    CONSTRAINT [FK_Timesheet_Person]
        FOREIGN KEY ([PersonID]) REFERENCES [__mj_BizAppsCommon].[Person]([ID]),
    CONSTRAINT [FK_Timesheet_SubmittedByUser]
        FOREIGN KEY ([SubmittedByUserID]) REFERENCES [__mj].[User]([ID]),
    CONSTRAINT [UQ_Timesheet_Person_Period]
        UNIQUE ([PersonID], [PeriodStart], [PeriodEnd]),
    CONSTRAINT [CK_Timesheet_Period]
        CHECK ([PeriodEnd] >= [PeriodStart]),
    CONSTRAINT [CK_Timesheet_Status]
        CHECK ([Status] IN ('Draft', 'Submitted', 'Approved', 'Rejected')),
    CONSTRAINT [CK_Timesheet_Totals]
        CHECK ([TotalMinutes] >= 0 AND [BillableMinutes] >= 0 AND [BillableMinutes] <= [TotalMinutes])
);
GO

CREATE INDEX [IDX_Timesheet_Status_Period]
    ON [${flyway:defaultSchema}].[Timesheet] ([Status], [PeriodStart] DESC);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Period timesheet header for a person, grouping task time entries across a date range for submission and approval.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Timesheet';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Primary key for the timesheet.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Timesheet',
    @level2type = N'COLUMN', @level2name = N'ID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The Person whose time entries are covered by this timesheet.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Timesheet',
    @level2type = N'COLUMN', @level2name = N'PersonID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Inclusive start date of the timesheet period.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Timesheet',
    @level2type = N'COLUMN', @level2name = N'PeriodStart';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Inclusive end date of the timesheet period.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Timesheet',
    @level2type = N'COLUMN', @level2name = N'PeriodEnd';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Lifecycle status of the timesheet: Draft, Submitted, Approved, or Rejected.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Timesheet',
    @level2type = N'COLUMN', @level2name = N'Status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the timesheet was most recently submitted.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Timesheet',
    @level2type = N'COLUMN', @level2name = N'SubmittedAt';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The MemberJunction User who submitted the timesheet.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Timesheet',
    @level2type = N'COLUMN', @level2name = N'SubmittedByUserID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total minutes across all time entries attached to this timesheet.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Timesheet',
    @level2type = N'COLUMN', @level2name = N'TotalMinutes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total billable minutes across all time entries attached to this timesheet.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Timesheet',
    @level2type = N'COLUMN', @level2name = N'BillableMinutes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Worker notes or comments submitted with the timesheet.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'Timesheet',
    @level2type = N'COLUMN', @level2name = N'Notes';
GO

ALTER TABLE [${flyway:defaultSchema}].[TaskTimeEntry]
    ADD [TimesheetID] UNIQUEIDENTIFIER NULL
        CONSTRAINT [FK_TaskTimeEntry_Timesheet]
        FOREIGN KEY REFERENCES [${flyway:defaultSchema}].[Timesheet]([ID]);
GO

CREATE INDEX [IDX_TaskTimeEntry_Timesheet]
    ON [${flyway:defaultSchema}].[TaskTimeEntry] ([TimesheetID])
    WHERE [TimesheetID] IS NOT NULL;
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional Timesheet this time entry has been attached to.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntry',
    @level2type = N'COLUMN', @level2name = N'TimesheetID';
GO

---------------------------------------------------------------------------
-- 5. TimesheetApproval
---------------------------------------------------------------------------
CREATE TABLE [${flyway:defaultSchema}].[TimesheetApproval] (
    [ID]                UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_TimesheetApproval_ID] DEFAULT (NEWSEQUENTIALID()),
    [TimesheetID]       UNIQUEIDENTIFIER NOT NULL,
    [SubmissionRound]   INT              NOT NULL CONSTRAINT [DF_TimesheetApproval_Round] DEFAULT (1),
    [ScopeTaskID]       UNIQUEIDENTIFIER NULL,
    [ApprovalTaskID]    UNIQUEIDENTIFIER NOT NULL,
    [Minutes]           INT              NOT NULL CONSTRAINT [DF_TimesheetApproval_Minutes] DEFAULT (0),
    [BillableMinutes]   INT              NOT NULL CONSTRAINT [DF_TimesheetApproval_Billable] DEFAULT (0),
    [EntryCount]        INT              NOT NULL CONSTRAINT [DF_TimesheetApproval_Count] DEFAULT (0),
    [SnapshotHash]      NVARCHAR(64)     NOT NULL,
    [Status]            NVARCHAR(20)     NOT NULL CONSTRAINT [DF_TimesheetApproval_Status] DEFAULT ('Pending'),
    [DecidedByPersonID] UNIQUEIDENTIFIER NULL,
    [DecidedAt]         DATETIMEOFFSET   NULL,
    [DecisionNotes]     NVARCHAR(MAX)    NULL,

    CONSTRAINT [PK_TimesheetApproval] PRIMARY KEY ([ID]),
    CONSTRAINT [FK_TimesheetApproval_Timesheet]
        FOREIGN KEY ([TimesheetID]) REFERENCES [${flyway:defaultSchema}].[Timesheet]([ID]),
    CONSTRAINT [FK_TimesheetApproval_ScopeTask]
        FOREIGN KEY ([ScopeTaskID]) REFERENCES [${flyway:defaultSchema}].[Task]([ID]),
    CONSTRAINT [FK_TimesheetApproval_ApprovalTask]
        FOREIGN KEY ([ApprovalTaskID]) REFERENCES [${flyway:defaultSchema}].[Task]([ID]),
    CONSTRAINT [FK_TimesheetApproval_Decider]
        FOREIGN KEY ([DecidedByPersonID]) REFERENCES [__mj_BizAppsCommon].[Person]([ID]),
    CONSTRAINT [UQ_TimesheetApproval_ApprovalTask]
        UNIQUE ([ApprovalTaskID]),
    CONSTRAINT [CK_TimesheetApproval_Round]
        CHECK ([SubmissionRound] >= 1),
    CONSTRAINT [CK_TimesheetApproval_Status]
        CHECK ([Status] IN ('Pending', 'Approved', 'Rejected', 'Canceled')),
    CONSTRAINT [CK_TimesheetApproval_Totals]
        CHECK ([Minutes] >= 0 AND [BillableMinutes] >= 0 AND [BillableMinutes] <= [Minutes] AND [EntryCount] >= 0)
);
GO

CREATE UNIQUE INDEX [UQ_TimesheetApproval_Part_Round]
    ON [${flyway:defaultSchema}].[TimesheetApproval] ([TimesheetID], [SubmissionRound], [ScopeTaskID]);
GO

CREATE INDEX [IDX_TimesheetApproval_Timesheet]
    ON [${flyway:defaultSchema}].[TimesheetApproval] ([TimesheetID], [SubmissionRound] DESC);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Per-project approval slice of a submitted timesheet, backed by a real approval Task in the Tasks inbox.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetApproval';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Primary key for the timesheet approval part.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetApproval',
    @level2type = N'COLUMN', @level2name = N'ID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The Timesheet this approval slice belongs to.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetApproval',
    @level2type = N'COLUMN', @level2name = N'TimesheetID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Submission round number (1 on initial submit, incremented on each resubmit).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetApproval',
    @level2type = N'COLUMN', @level2name = N'SubmissionRound';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Root project task for this approval slice, or NULL for the whole-timesheet / unassigned slice.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetApproval',
    @level2type = N'COLUMN', @level2name = N'ScopeTaskID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The approval Task created in the Tasks inbox for this slice.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetApproval',
    @level2type = N'COLUMN', @level2name = N'ApprovalTaskID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total minutes in this approval slice at submission time.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetApproval',
    @level2type = N'COLUMN', @level2name = N'Minutes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total billable minutes in this approval slice at submission time.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetApproval',
    @level2type = N'COLUMN', @level2name = N'BillableMinutes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Number of TaskTimeEntry rows included in this approval slice.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetApproval',
    @level2type = N'COLUMN', @level2name = N'EntryCount';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Deterministic SHA-256 hex digest of the slice time entries, used to carry forward unchanged Approved parts across resubmissions.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetApproval',
    @level2type = N'COLUMN', @level2name = N'SnapshotHash';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Current status of this approval slice: Pending, Approved, Rejected, or Canceled.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetApproval',
    @level2type = N'COLUMN', @level2name = N'Status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The Person who recorded the approval or rejection decision.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetApproval',
    @level2type = N'COLUMN', @level2name = N'DecidedByPersonID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the decision on this slice was recorded.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetApproval',
    @level2type = N'COLUMN', @level2name = N'DecidedAt';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Notes or feedback provided by the approver when deciding this slice.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetApproval',
    @level2type = N'COLUMN', @level2name = N'DecisionNotes';
GO

---------------------------------------------------------------------------
-- 6. TimeApprover
---------------------------------------------------------------------------
CREATE TABLE [${flyway:defaultSchema}].[TimeApprover] (
    [ID]                 UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_TimeApprover_ID] DEFAULT (NEWSEQUENTIALID()),
    [ApproverPersonID]   UNIQUEIDENTIFIER NOT NULL,
    [WorkerPersonID]     UNIQUEIDENTIFIER NULL,
    [ScopeTaskID]        UNIQUEIDENTIFIER NULL,
    [IncludeDescendants] BIT              NOT NULL CONSTRAINT [DF_TimeApprover_Descendants] DEFAULT (1),
    [ScopeEntityID]      UNIQUEIDENTIFIER NULL,
    [ScopeRecordID]      NVARCHAR(450)    NULL,
    [EffectiveFrom]      DATE             NULL,
    [EffectiveTo]        DATE             NULL,
    [IsActive]           BIT              NOT NULL CONSTRAINT [DF_TimeApprover_IsActive] DEFAULT (1),
    [Notes]              NVARCHAR(MAX)    NULL,

    CONSTRAINT [PK_TimeApprover] PRIMARY KEY ([ID]),
    CONSTRAINT [FK_TimeApprover_Approver]
        FOREIGN KEY ([ApproverPersonID]) REFERENCES [__mj_BizAppsCommon].[Person]([ID]),
    CONSTRAINT [FK_TimeApprover_Worker]
        FOREIGN KEY ([WorkerPersonID]) REFERENCES [__mj_BizAppsCommon].[Person]([ID]),
    CONSTRAINT [FK_TimeApprover_ScopeTask]
        FOREIGN KEY ([ScopeTaskID]) REFERENCES [${flyway:defaultSchema}].[Task]([ID]),
    CONSTRAINT [FK_TimeApprover_ScopeEntity]
        FOREIGN KEY ([ScopeEntityID]) REFERENCES [__mj].[Entity]([ID]),
    CONSTRAINT [CK_TimeApprover_NotSelf]
        CHECK ([WorkerPersonID] IS NULL OR [WorkerPersonID] <> [ApproverPersonID]),
    CONSTRAINT [CK_TimeApprover_EntityPair]
        CHECK (([ScopeEntityID] IS NULL AND [ScopeRecordID] IS NULL)
            OR ([ScopeEntityID] IS NOT NULL AND [ScopeRecordID] IS NOT NULL)),
    CONSTRAINT [CK_TimeApprover_Dates]
        CHECK ([EffectiveFrom] IS NULL OR [EffectiveTo] IS NULL OR [EffectiveTo] >= [EffectiveFrom])
);
GO

CREATE INDEX [IDX_TimeApprover_Worker]
    ON [${flyway:defaultSchema}].[TimeApprover] ([WorkerPersonID], [IsActive]);
GO

CREATE INDEX [IDX_TimeApprover_ScopeTask]
    ON [${flyway:defaultSchema}].[TimeApprover] ([ScopeTaskID], [IsActive])
    WHERE [ScopeTaskID] IS NOT NULL;
GO

CREATE INDEX [IDX_TimeApprover_ScopeRecord]
    ON [${flyway:defaultSchema}].[TimeApprover] ([ScopeEntityID], [ScopeRecordID], [IsActive])
    WHERE [ScopeEntityID] IS NOT NULL;
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Configurable directory of who approves whose time, optionally scoped to a specific worker, root project task, or external entity record.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimeApprover';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Primary key for the time approver rule.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimeApprover',
    @level2type = N'COLUMN', @level2name = N'ID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The Person who is granted time approval authority by this rule.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimeApprover',
    @level2type = N'COLUMN', @level2name = N'ApproverPersonID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional Worker Person whose time this rule applies to (NULL matches any worker).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimeApprover',
    @level2type = N'COLUMN', @level2name = N'WorkerPersonID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional project/parent Task this rule scopes approval to (NULL matches any task).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimeApprover',
    @level2type = N'COLUMN', @level2name = N'ScopeTaskID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When ScopeTaskID is set, whether sub-tasks beneath ScopeTaskID also match this rule.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimeApprover',
    @level2type = N'COLUMN', @level2name = N'IncludeDescendants';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional MJ Entity ID when scoping approval to tasks linked to an external record via TaskLink.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimeApprover',
    @level2type = N'COLUMN', @level2name = N'ScopeEntityID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Companion record ID in ScopeEntityID when scoping approval to tasks linked via TaskLink.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimeApprover',
    @level2type = N'COLUMN', @level2name = N'ScopeRecordID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional start date from which this approver rule is effective.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimeApprover',
    @level2type = N'COLUMN', @level2name = N'EffectiveFrom';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional end date through which this approver rule is effective.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimeApprover',
    @level2type = N'COLUMN', @level2name = N'EffectiveTo';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether this approver rule is currently active.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimeApprover',
    @level2type = N'COLUMN', @level2name = N'IsActive';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional administrative notes about this approver rule.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimeApprover',
    @level2type = N'COLUMN', @level2name = N'Notes';
GO

---------------------------------------------------------------------------
-- 7. TimesheetLink & TaskTimeEntryLink
---------------------------------------------------------------------------
CREATE TABLE [${flyway:defaultSchema}].[TimesheetLink] (
    [ID]           UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_TimesheetLink_ID] DEFAULT (NEWSEQUENTIALID()),
    [TimesheetID]  UNIQUEIDENTIFIER NOT NULL,
    [EntityID]     UNIQUEIDENTIFIER NOT NULL,
    [RecordID]     NVARCHAR(450)    NOT NULL,
    [Relationship] NVARCHAR(30)     NOT NULL CONSTRAINT [DF_TimesheetLink_Rel] DEFAULT ('Related'),

    CONSTRAINT [PK_TimesheetLink] PRIMARY KEY ([ID]),
    CONSTRAINT [FK_TimesheetLink_Timesheet]
        FOREIGN KEY ([TimesheetID]) REFERENCES [${flyway:defaultSchema}].[Timesheet]([ID]),
    CONSTRAINT [FK_TimesheetLink_Entity]
        FOREIGN KEY ([EntityID]) REFERENCES [__mj].[Entity]([ID]),
    CONSTRAINT [UQ_TimesheetLink_Target]
        UNIQUE ([TimesheetID], [EntityID], [RecordID], [Relationship]),
    CONSTRAINT [CK_TimesheetLink_Rel]
        CHECK ([Relationship] IN ('PayrollBatch', 'Invoice', 'ExpenseReport', 'Related'))
);
GO

CREATE INDEX [IDX_TimesheetLink_Entity_Record]
    ON [${flyway:defaultSchema}].[TimesheetLink] ([EntityID], [RecordID]);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Polymorphic links from a Timesheet to external records such as payroll batches, invoices, or expense reports.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetLink';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Primary key for the timesheet link.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetLink',
    @level2type = N'COLUMN', @level2name = N'ID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The Timesheet being linked.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetLink',
    @level2type = N'COLUMN', @level2name = N'TimesheetID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Target MemberJunction Entity ID for the linked external record.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetLink',
    @level2type = N'COLUMN', @level2name = N'EntityID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Primary key value of the linked record in EntityID.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetLink',
    @level2type = N'COLUMN', @level2name = N'RecordID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Semantic relationship of the linked record to the timesheet: PayrollBatch, Invoice, ExpenseReport, or Related.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetLink',
    @level2type = N'COLUMN', @level2name = N'Relationship';
GO

CREATE TABLE [${flyway:defaultSchema}].[TaskTimeEntryLink] (
    [ID]              UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_TaskTimeEntryLink_ID] DEFAULT (NEWSEQUENTIALID()),
    [TaskTimeEntryID] UNIQUEIDENTIFIER NOT NULL,
    [EntityID]        UNIQUEIDENTIFIER NOT NULL,
    [RecordID]        NVARCHAR(450)    NOT NULL,
    [Relationship]    NVARCHAR(30)     NOT NULL CONSTRAINT [DF_TaskTimeEntryLink_Rel] DEFAULT ('Related'),

    CONSTRAINT [PK_TaskTimeEntryLink] PRIMARY KEY ([ID]),
    CONSTRAINT [FK_TaskTimeEntryLink_Entry]
        FOREIGN KEY ([TaskTimeEntryID]) REFERENCES [${flyway:defaultSchema}].[TaskTimeEntry]([ID]),
    CONSTRAINT [FK_TaskTimeEntryLink_Entity]
        FOREIGN KEY ([EntityID]) REFERENCES [__mj].[Entity]([ID]),
    CONSTRAINT [UQ_TaskTimeEntryLink_Target]
        UNIQUE ([TaskTimeEntryID], [EntityID], [RecordID], [Relationship]),
    CONSTRAINT [CK_TaskTimeEntryLink_Rel]
        CHECK ([Relationship] IN ('InvoiceLine', 'JournalEntryLine', 'Commit', 'PullRequest', 'Related'))
);
GO

CREATE INDEX [IDX_TaskTimeEntryLink_Entity_Record]
    ON [${flyway:defaultSchema}].[TaskTimeEntryLink] ([EntityID], [RecordID]);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Polymorphic links from a TaskTimeEntry to external records such as invoice lines, journal entry lines, commits, or pull requests.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntryLink';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Primary key for the task time entry link.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntryLink',
    @level2type = N'COLUMN', @level2name = N'ID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The TaskTimeEntry being linked.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntryLink',
    @level2type = N'COLUMN', @level2name = N'TaskTimeEntryID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Target MemberJunction Entity ID for the linked external record.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntryLink',
    @level2type = N'COLUMN', @level2name = N'EntityID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Primary key value of the linked record in EntityID.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntryLink',
    @level2type = N'COLUMN', @level2name = N'RecordID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Semantic relationship of the linked record to the time entry: InvoiceLine, JournalEntryLine, Commit, PullRequest, or Related.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskTimeEntryLink',
    @level2type = N'COLUMN', @level2name = N'Relationship';
GO

---------------------------------------------------------------------------
-- 8. TimesheetSchedule
---------------------------------------------------------------------------
CREATE TABLE [${flyway:defaultSchema}].[TimesheetSchedule] (
    [ID]                 UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_TimesheetSchedule_ID] DEFAULT (NEWSEQUENTIALID()),
    [PersonID]           UNIQUEIDENTIFIER NULL,
    [ScopeEntityID]      UNIQUEIDENTIFIER NULL,
    [ScopeRecordID]      NVARCHAR(450)    NULL,
    [Cadence]            NVARCHAR(20)     NOT NULL,
    [WeekStartDay]       NVARCHAR(10)     NOT NULL CONSTRAINT [DF_TimesheetSchedule_WeekStart] DEFAULT ('Monday'),
    [BiWeeklyAnchorDate] DATE             NOT NULL CONSTRAINT [DF_TimesheetSchedule_Anchor] DEFAULT ('2026-01-05'),
    [EffectiveFrom]      DATE             NOT NULL,
    [EffectiveTo]        DATE             NULL,
    [Notes]              NVARCHAR(MAX)    NULL,

    CONSTRAINT [PK_TimesheetSchedule] PRIMARY KEY ([ID]),
    CONSTRAINT [FK_TimesheetSchedule_Person]
        FOREIGN KEY ([PersonID]) REFERENCES [__mj_BizAppsCommon].[Person]([ID]),
    CONSTRAINT [FK_TimesheetSchedule_Entity]
        FOREIGN KEY ([ScopeEntityID]) REFERENCES [__mj].[Entity]([ID]),
    CONSTRAINT [CK_TimesheetSchedule_Cadence]
        CHECK ([Cadence] IN ('Weekly', 'BiWeekly', 'SemiMonthly', 'Monthly')),
    CONSTRAINT [CK_TimesheetSchedule_WeekStart]
        CHECK ([WeekStartDay] IN ('Monday', 'Sunday', 'Saturday')),
    CONSTRAINT [CK_TimesheetSchedule_EntityPair]
        CHECK (([ScopeEntityID] IS NULL AND [ScopeRecordID] IS NULL)
            OR ([ScopeEntityID] IS NOT NULL AND [ScopeRecordID] IS NOT NULL)),
    CONSTRAINT [CK_TimesheetSchedule_SingleTarget]
        CHECK ([PersonID] IS NULL OR [ScopeEntityID] IS NULL),
    CONSTRAINT [CK_TimesheetSchedule_Dates]
        CHECK ([EffectiveTo] IS NULL OR [EffectiveTo] >= [EffectiveFrom])
);
GO

CREATE INDEX [IDX_TimesheetSchedule_Lookup]
    ON [${flyway:defaultSchema}].[TimesheetSchedule] ([PersonID], [ScopeEntityID], [ScopeRecordID], [EffectiveFrom] DESC);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Effective-dated timesheet period cadence schedule, globally or scoped to a specific Person or external entity record.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetSchedule';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Primary key for the timesheet schedule.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetSchedule',
    @level2type = N'COLUMN', @level2name = N'ID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional Person this schedule applies to (NULL for organization/entity-scoped or global schedules).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetSchedule',
    @level2type = N'COLUMN', @level2name = N'PersonID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional MJ Entity ID when scoping the schedule to an organization or department record.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetSchedule',
    @level2type = N'COLUMN', @level2name = N'ScopeEntityID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Companion record ID in ScopeEntityID for entity-scoped schedules.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetSchedule',
    @level2type = N'COLUMN', @level2name = N'ScopeRecordID';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timesheet period cadence: Weekly, BiWeekly, SemiMonthly, or Monthly.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetSchedule',
    @level2type = N'COLUMN', @level2name = N'Cadence';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'First day of the work week for Weekly and BiWeekly cadences: Monday, Sunday, or Saturday.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetSchedule',
    @level2type = N'COLUMN', @level2name = N'WeekStartDay';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Anchor date (which must fall on WeekStartDay) defining the 14-day boundary for BiWeekly cadences.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetSchedule',
    @level2type = N'COLUMN', @level2name = N'BiWeeklyAnchorDate';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Inclusive start date from which this schedule is effective (must fall on a period boundary).',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetSchedule',
    @level2type = N'COLUMN', @level2name = N'EffectiveFrom';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional inclusive end date through which this schedule is effective.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetSchedule',
    @level2type = N'COLUMN', @level2name = N'EffectiveTo';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional notes explaining this schedule or cadence change.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TimesheetSchedule',
    @level2type = N'COLUMN', @level2name = N'Notes';
GO

---------------------------------------------------------------------------
-- 9. TaskType.RequiresAssigneeDecision
---------------------------------------------------------------------------
ALTER TABLE [${flyway:defaultSchema}].[TaskType]
    ADD [RequiresAssigneeDecision] BIT NOT NULL
        CONSTRAINT [DF_TaskType_RequiresAssigneeDecision] DEFAULT (0);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When true on an approval task type, only an assigned approver (and never the task creator unless exempt) may record a decision on tasks of this type, regardless of the global PreventSelfApproval setting.',
    @level0type = N'SCHEMA', @level0name = N'${flyway:defaultSchema}',
    @level1type = N'TABLE',  @level1name = N'TaskType',
    @level2type = N'COLUMN', @level2name = N'RequiresAssigneeDecision';
GO

---------------------------------------------------------------------------
-- 10. vwTaskRootAgentEffort & Rebuilt vwTasks
---------------------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskRootAgentEffort]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskRootAgentEffort];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskRootAgentEffort]
AS
SELECT
    tar.[TaskID],
    COUNT(*)                                                                  AS [AgentRunCount],
    SUM(COALESCE(r.[TotalCostRollup],       r.[TotalCost],       0))          AS [AgentCost],
    SUM(COALESCE(r.[TotalTokensUsedRollup], r.[TotalTokensUsed], 0))          AS [AgentTokens]
FROM [${flyway:defaultSchema}].[TaskAgentRun] tar
INNER JOIN [__mj].[vwAIAgentRuns] r ON r.[ID] = tar.[AIAgentRunID]
WHERE NOT EXISTS (
    SELECT 1
    FROM [${flyway:defaultSchema}].[TaskAgentRun] tar2
    WHERE tar2.[TaskID]       = tar.[TaskID]
      AND tar2.[AIAgentRunID] <> tar.[AIAgentRunID]
      AND r.[ParentRunIDPath] LIKE '%/' + CAST(tar2.[AIAgentRunID] AS NVARCHAR(36)) + '/%'
)
GROUP BY tar.[TaskID];
GO

IF DATABASE_PRINCIPAL_ID('cdp_UI') IS NOT NULL
    EXEC('GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskRootAgentEffort] TO [cdp_UI]');
IF DATABASE_PRINCIPAL_ID('cdp_Developer') IS NOT NULL
    EXEC('GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskRootAgentEffort] TO [cdp_Developer]');
IF DATABASE_PRINCIPAL_ID('cdp_Integration') IS NOT NULL
    EXEC('GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskRootAgentEffort] TO [cdp_Integration]');
GO

IF OBJECT_ID('[${flyway:defaultSchema}].[vwTasks]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTasks];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTasks]
AS
SELECT
    g.*,
    root_ParentID.RootID AS [RootParentID],
    CASE
        WHEN g.[CompletedAt] IS NOT NULL AND g.[DueAt] IS NOT NULL THEN
            CASE WHEN g.[CompletedAt] > g.[DueAt] THEN 'Breached' ELSE 'Met' END
        ELSE NULL
    END AS [IsSLABreached],
    CASE
        WHEN g.[StartedAt] IS NOT NULL AND g.[DueAt] IS NOT NULL THEN
            DATEDIFF(day, g.[StartedAt], g.[DueAt])
        WHEN g.[__mj_CreatedAt] IS NOT NULL AND g.[DueAt] IS NOT NULL THEN
            DATEDIFF(day, g.[__mj_CreatedAt], g.[DueAt])
        ELSE NULL
    END AS [LeadDays],
    ISNULL(a.[AssignmentsCount], 0)                   AS [AssignmentsCount],
    ISNULL(c.[CommentsCount], 0)                      AS [CommentsCount],
    ISNULL(te.[LoggedMinutes], 0)                     AS [LoggedMinutes],
    ISNULL(ae.[AgentRunCount], 0)                     AS [AgentRunCount],
    ISNULL(ae.[AgentCost], CAST(0 AS DECIMAL(19, 8))) AS [AgentCost],
    ISNULL(ae.[AgentTokens], 0)                       AS [AgentTokens]
FROM
    [${flyway:defaultSchema}].[vwTasksGenerated] AS g
OUTER APPLY
    [${flyway:defaultSchema}].[fnTaskParentID_GetRootID]([g].[ID], [g].[ParentID]) AS root_ParentID
LEFT OUTER JOIN (
    SELECT [TaskID], COUNT(*) AS [AssignmentsCount]
    FROM [${flyway:defaultSchema}].[TaskAssignment]
    GROUP BY [TaskID]
) AS a ON a.[TaskID] = g.[ID]
LEFT OUTER JOIN (
    SELECT [TaskID], COUNT(*) AS [CommentsCount]
    FROM [${flyway:defaultSchema}].[TaskComment]
    GROUP BY [TaskID]
) AS c ON c.[TaskID] = g.[ID]
LEFT OUTER JOIN (
    SELECT [TaskID], SUM([Minutes]) AS [LoggedMinutes]
    FROM [${flyway:defaultSchema}].[TaskTimeEntry]
    GROUP BY [TaskID]
) AS te ON te.[TaskID] = g.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[vwTaskRootAgentEffort] AS ae
    ON ae.[TaskID] = g.[ID];
GO

IF DATABASE_PRINCIPAL_ID('cdp_UI') IS NOT NULL
    EXEC('GRANT SELECT ON [${flyway:defaultSchema}].[vwTasks] TO [cdp_UI]');
IF DATABASE_PRINCIPAL_ID('cdp_Developer') IS NOT NULL
    EXEC('GRANT SELECT ON [${flyway:defaultSchema}].[vwTasks] TO [cdp_Developer]');
IF DATABASE_PRINCIPAL_ID('cdp_Integration') IS NOT NULL
    EXEC('GRANT SELECT ON [${flyway:defaultSchema}].[vwTasks] TO [cdp_Integration]');
GO























































-- =============================================================================
-- GENERATED BY MemberJunction CodeGen — DO NOT EDIT BY HAND
-- =============================================================================

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Time Entries */

      INSERT INTO [${mjSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching],
         [TrackRecordChanges],
         [AuditRecordAccess],
         [AuditViewRuns],
         [AllowAllRowsAPI],
         [AllowCreateAPI],
         [AllowUpdateAPI],
         [AllowDeleteAPI],
         [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         'ea40801a-df1b-443a-b0d3-ea0415645603',
         'MJ_BizApps_Tasks: Task Time Entries',
         'Task Time Entries',
         'Individual time entries logged by a person against a task on a specific business calendar date.',
         NULL,
         'TaskTimeEntry',
         'vwTaskTimeEntries',
         '${flyway:defaultSchema}',
         1,
         1,
         0,
         1,
         0,
         0,
         0,
         1,
         1,
         1,
         1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add entity MJ_BizApps_Tasks: Task Time Entries to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                    ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'ea40801a-df1b-443a-b0d3-ea0415645603', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Time Entries for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('ea40801a-df1b-443a-b0d3-ea0415645603' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('ea40801a-df1b-443a-b0d3-ea0415645603' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Time Entries for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('ea40801a-df1b-443a-b0d3-ea0415645603' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('ea40801a-df1b-443a-b0d3-ea0415645603' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Time Entries for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('ea40801a-df1b-443a-b0d3-ea0415645603' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('ea40801a-df1b-443a-b0d3-ea0415645603' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Timers */

      INSERT INTO [${mjSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching],
         [TrackRecordChanges],
         [AuditRecordAccess],
         [AuditViewRuns],
         [AllowAllRowsAPI],
         [AllowCreateAPI],
         [AllowUpdateAPI],
         [AllowDeleteAPI],
         [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         '87c6f7ff-3752-48d2-b382-30b9a4d1cf51',
         'MJ_BizApps_Tasks: Task Timers',
         'Task Timers',
         'Currently running task stopwatch per person. At most one row per PersonID exists at any time; stopping a timer deletes the row and writes TaskTimeEntry rows.',
         NULL,
         'TaskTimer',
         'vwTaskTimers',
         '${flyway:defaultSchema}',
         1,
         1,
         0,
         0,
         0,
         0,
         0,
         1,
         1,
         1,
         1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add entity MJ_BizApps_Tasks: Task Timers to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                    ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '87c6f7ff-3752-48d2-b382-30b9a4d1cf51', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Timers for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('87c6f7ff-3752-48d2-b382-30b9a4d1cf51' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('87c6f7ff-3752-48d2-b382-30b9a4d1cf51' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Timers for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('87c6f7ff-3752-48d2-b382-30b9a4d1cf51' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('87c6f7ff-3752-48d2-b382-30b9a4d1cf51' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Timers for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('87c6f7ff-3752-48d2-b382-30b9a4d1cf51' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('87c6f7ff-3752-48d2-b382-30b9a4d1cf51' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Agent Runs */

      INSERT INTO [${mjSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching],
         [TrackRecordChanges],
         [AuditRecordAccess],
         [AuditViewRuns],
         [AllowAllRowsAPI],
         [AllowCreateAPI],
         [AllowUpdateAPI],
         [AllowDeleteAPI],
         [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         '03a6558c-487b-4a91-b7c6-0bc1b54a65f3',
         'MJ_BizApps_Tasks: Task Agent Runs',
         'Task Agent Runs',
         'Links a task to a MemberJunction AI Agent Run so agent effort (runs, tokens, cost, wall-clock duration) is attributed alongside human time.',
         NULL,
         'TaskAgentRun',
         'vwTaskAgentRuns',
         '${flyway:defaultSchema}',
         1,
         1,
         0,
         1,
         0,
         0,
         0,
         1,
         1,
         1,
         1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add entity MJ_BizApps_Tasks: Task Agent Runs to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                    ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '03a6558c-487b-4a91-b7c6-0bc1b54a65f3', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Agent Runs for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('03a6558c-487b-4a91-b7c6-0bc1b54a65f3' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('03a6558c-487b-4a91-b7c6-0bc1b54a65f3' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Agent Runs for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('03a6558c-487b-4a91-b7c6-0bc1b54a65f3' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('03a6558c-487b-4a91-b7c6-0bc1b54a65f3' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Agent Runs for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('03a6558c-487b-4a91-b7c6-0bc1b54a65f3' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('03a6558c-487b-4a91-b7c6-0bc1b54a65f3' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Timesheets */

      INSERT INTO [${mjSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching],
         [TrackRecordChanges],
         [AuditRecordAccess],
         [AuditViewRuns],
         [AllowAllRowsAPI],
         [AllowCreateAPI],
         [AllowUpdateAPI],
         [AllowDeleteAPI],
         [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         'ed90ee09-0d39-4298-93dc-77c057fce97a',
         'MJ_BizApps_Tasks: Timesheets',
         'Timesheets',
         'Period timesheet header for a person, grouping task time entries across a date range for submission and approval.',
         NULL,
         'Timesheet',
         'vwTimesheets',
         '${flyway:defaultSchema}',
         1,
         1,
         0,
         1,
         0,
         0,
         0,
         1,
         1,
         1,
         1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add entity MJ_BizApps_Tasks: Timesheets to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                    ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'ed90ee09-0d39-4298-93dc-77c057fce97a', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheets for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('ed90ee09-0d39-4298-93dc-77c057fce97a' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('ed90ee09-0d39-4298-93dc-77c057fce97a' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheets for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('ed90ee09-0d39-4298-93dc-77c057fce97a' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('ed90ee09-0d39-4298-93dc-77c057fce97a' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheets for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('ed90ee09-0d39-4298-93dc-77c057fce97a' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('ed90ee09-0d39-4298-93dc-77c057fce97a' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Timesheet Approvals */

      INSERT INTO [${mjSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching],
         [TrackRecordChanges],
         [AuditRecordAccess],
         [AuditViewRuns],
         [AllowAllRowsAPI],
         [AllowCreateAPI],
         [AllowUpdateAPI],
         [AllowDeleteAPI],
         [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         '02c38b1a-6987-463d-8b6b-4c86e0887d42',
         'MJ_BizApps_Tasks: Timesheet Approvals',
         'Timesheet Approvals',
         'Per-project approval slice of a submitted timesheet, backed by a real approval Task in the Tasks inbox.',
         NULL,
         'TimesheetApproval',
         'vwTimesheetApprovals',
         '${flyway:defaultSchema}',
         1,
         1,
         0,
         1,
         0,
         0,
         0,
         1,
         1,
         1,
         1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add entity MJ_BizApps_Tasks: Timesheet Approvals to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                    ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '02c38b1a-6987-463d-8b6b-4c86e0887d42', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Approvals for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('02c38b1a-6987-463d-8b6b-4c86e0887d42' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('02c38b1a-6987-463d-8b6b-4c86e0887d42' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Approvals for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('02c38b1a-6987-463d-8b6b-4c86e0887d42' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('02c38b1a-6987-463d-8b6b-4c86e0887d42' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Approvals for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('02c38b1a-6987-463d-8b6b-4c86e0887d42' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('02c38b1a-6987-463d-8b6b-4c86e0887d42' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Time Approvers */

      INSERT INTO [${mjSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching],
         [TrackRecordChanges],
         [AuditRecordAccess],
         [AuditViewRuns],
         [AllowAllRowsAPI],
         [AllowCreateAPI],
         [AllowUpdateAPI],
         [AllowDeleteAPI],
         [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         'c82f6ef9-b9c4-4387-8c10-f5b59fa24133',
         'MJ_BizApps_Tasks: Time Approvers',
         'Time Approvers',
         'Configurable directory of who approves whose time, optionally scoped to a specific worker, root project task, or external entity record.',
         NULL,
         'TimeApprover',
         'vwTimeApprovers',
         '${flyway:defaultSchema}',
         1,
         1,
         0,
         1,
         0,
         0,
         0,
         1,
         1,
         1,
         1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add entity MJ_BizApps_Tasks: Time Approvers to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                    ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'c82f6ef9-b9c4-4387-8c10-f5b59fa24133', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Time Approvers for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('c82f6ef9-b9c4-4387-8c10-f5b59fa24133' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('c82f6ef9-b9c4-4387-8c10-f5b59fa24133' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Time Approvers for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('c82f6ef9-b9c4-4387-8c10-f5b59fa24133' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('c82f6ef9-b9c4-4387-8c10-f5b59fa24133' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Time Approvers for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('c82f6ef9-b9c4-4387-8c10-f5b59fa24133' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('c82f6ef9-b9c4-4387-8c10-f5b59fa24133' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Timesheet Links */

      INSERT INTO [${mjSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching],
         [TrackRecordChanges],
         [AuditRecordAccess],
         [AuditViewRuns],
         [AllowAllRowsAPI],
         [AllowCreateAPI],
         [AllowUpdateAPI],
         [AllowDeleteAPI],
         [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         'd594b91d-4de0-4d20-8d71-21f041fa505d',
         'MJ_BizApps_Tasks: Timesheet Links',
         'Timesheet Links',
         'Polymorphic links from a Timesheet to external records such as payroll batches, invoices, or expense reports.',
         NULL,
         'TimesheetLink',
         'vwTimesheetLinks',
         '${flyway:defaultSchema}',
         1,
         1,
         0,
         1,
         0,
         0,
         0,
         1,
         1,
         1,
         1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add entity MJ_BizApps_Tasks: Timesheet Links to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                    ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', 'd594b91d-4de0-4d20-8d71-21f041fa505d', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Links for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('d594b91d-4de0-4d20-8d71-21f041fa505d' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('d594b91d-4de0-4d20-8d71-21f041fa505d' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Links for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('d594b91d-4de0-4d20-8d71-21f041fa505d' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('d594b91d-4de0-4d20-8d71-21f041fa505d' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Links for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('d594b91d-4de0-4d20-8d71-21f041fa505d' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('d594b91d-4de0-4d20-8d71-21f041fa505d' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Task Time Entry Links */

      INSERT INTO [${mjSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching],
         [TrackRecordChanges],
         [AuditRecordAccess],
         [AuditViewRuns],
         [AllowAllRowsAPI],
         [AllowCreateAPI],
         [AllowUpdateAPI],
         [AllowDeleteAPI],
         [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         '5a25b67b-d67d-453f-8340-94bf69cf8cee',
         'MJ_BizApps_Tasks: Task Time Entry Links',
         'Task Time Entry Links',
         'Polymorphic links from a TaskTimeEntry to external records such as invoice lines, journal entry lines, commits, or pull requests.',
         NULL,
         'TaskTimeEntryLink',
         'vwTaskTimeEntryLinks',
         '${flyway:defaultSchema}',
         1,
         1,
         0,
         1,
         0,
         0,
         0,
         1,
         1,
         1,
         1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add entity MJ_BizApps_Tasks: Task Time Entry Links to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                    ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '5a25b67b-d67d-453f-8340-94bf69cf8cee', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Time Entry Links for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('5a25b67b-d67d-453f-8340-94bf69cf8cee' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('5a25b67b-d67d-453f-8340-94bf69cf8cee' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Time Entry Links for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('5a25b67b-d67d-453f-8340-94bf69cf8cee' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('5a25b67b-d67d-453f-8340-94bf69cf8cee' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Task Time Entry Links for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('5a25b67b-d67d-453f-8340-94bf69cf8cee' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('5a25b67b-d67d-453f-8340-94bf69cf8cee' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to create new entity MJ_BizApps_Tasks: Timesheet Schedules */

      INSERT INTO [${mjSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching],
         [TrackRecordChanges],
         [AuditRecordAccess],
         [AuditViewRuns],
         [AllowAllRowsAPI],
         [AllowCreateAPI],
         [AllowUpdateAPI],
         [AllowDeleteAPI],
         [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         '6a27830f-a203-4d3e-8adf-b1085e1f908c',
         'MJ_BizApps_Tasks: Timesheet Schedules',
         'Timesheet Schedules',
         'Effective-dated timesheet period cadence schedule, globally or scoped to a specific Person or external entity record.',
         NULL,
         'TimesheetSchedule',
         'vwTimesheetSchedules',
         '${flyway:defaultSchema}',
         1,
         1,
         0,
         1,
         0,
         0,
         0,
         1,
         1,
         1,
         1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add entity MJ_BizApps_Tasks: Timesheet Schedules to application ID: '22541055-8ED4-4850-8ACD-E5EE1887B15B' */
INSERT INTO [${mjSchema}].[ApplicationEntity]
                                    ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                    ('22541055-8ED4-4850-8ACD-E5EE1887B15B', '6a27830f-a203-4d3e-8adf-b1085e1f908c', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${mjSchema}].[ApplicationEntity] WHERE [ApplicationID] = '22541055-8ED4-4850-8ACD-E5EE1887B15B'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Schedules for role UI */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('6a27830f-a203-4d3e-8adf-b1085e1f908c' AS uniqueidentifier), CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('6a27830f-a203-4d3e-8adf-b1085e1f908c' AS uniqueidentifier) AND [RoleID] = CAST('E0AFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Schedules for role Developer */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('6a27830f-a203-4d3e-8adf-b1085e1f908c' AS uniqueidentifier), CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('6a27830f-a203-4d3e-8adf-b1085e1f908c' AS uniqueidentifier) AND [RoleID] = CAST('DEAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL generated to add new permission for entity MJ_BizApps_Tasks: Timesheet Schedules for role Integration */
INSERT INTO [${mjSchema}].[EntityPermission]
                ([EntityID], [RoleID], [Type], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt])
              SELECT CAST('6a27830f-a203-4d3e-8adf-b1085e1f908c' AS uniqueidentifier), CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier), 'Allow', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE()
              WHERE NOT EXISTS (
                SELECT 1 FROM [${mjSchema}].[EntityPermission]
                WHERE [EntityID] = CAST('6a27830f-a203-4d3e-8adf-b1085e1f908c' AS uniqueidentifier) AND [RoleID] = CAST('DFAFCCEC-6A37-EF11-86D4-000D3A4E707E' AS uniqueidentifier) AND [Type] = 'Allow'
              );

/* SQL text to update existing entities from schema */
EXEC [${mjSchema}].[spUpdateExistingEntitiesFromSchema] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskAgentRun */
ALTER TABLE [${flyway:defaultSchema}].[TaskAgentRun] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskAgentRun */
UPDATE [${flyway:defaultSchema}].[TaskAgentRun] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskAgentRun */
ALTER TABLE [${flyway:defaultSchema}].[TaskAgentRun] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskAgentRun */
ALTER TABLE [${flyway:defaultSchema}].[TaskAgentRun] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskAgentRun___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskAgentRun */
ALTER TABLE [${flyway:defaultSchema}].[TaskAgentRun] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskAgentRun */
UPDATE [${flyway:defaultSchema}].[TaskAgentRun] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskAgentRun */
ALTER TABLE [${flyway:defaultSchema}].[TaskAgentRun] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskAgentRun */
ALTER TABLE [${flyway:defaultSchema}].[TaskAgentRun] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskAgentRun___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TimesheetLink */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetLink] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TimesheetLink */
UPDATE [${flyway:defaultSchema}].[TimesheetLink] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TimesheetLink */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetLink] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TimesheetLink */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetLink] ADD CONSTRAINT [DF___mj_BizAppsTasks_TimesheetLink___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TimesheetLink */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetLink] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TimesheetLink */
UPDATE [${flyway:defaultSchema}].[TimesheetLink] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TimesheetLink */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetLink] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TimesheetLink */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetLink] ADD CONSTRAINT [DF___mj_BizAppsTasks_TimesheetLink___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTimer */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimer] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTimer */
UPDATE [${flyway:defaultSchema}].[TaskTimer] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTimer */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimer] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTimer */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimer] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTimer___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTimer */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimer] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTimer */
UPDATE [${flyway:defaultSchema}].[TaskTimer] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTimer */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimer] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTimer */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimer] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTimer___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TimesheetApproval */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetApproval] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TimesheetApproval */
UPDATE [${flyway:defaultSchema}].[TimesheetApproval] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TimesheetApproval */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetApproval] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TimesheetApproval */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetApproval] ADD CONSTRAINT [DF___mj_BizAppsTasks_TimesheetApproval___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TimesheetApproval */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetApproval] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TimesheetApproval */
UPDATE [${flyway:defaultSchema}].[TimesheetApproval] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TimesheetApproval */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetApproval] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TimesheetApproval */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetApproval] ADD CONSTRAINT [DF___mj_BizAppsTasks_TimesheetApproval___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.Timesheet */
ALTER TABLE [${flyway:defaultSchema}].[Timesheet] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.Timesheet */
UPDATE [${flyway:defaultSchema}].[Timesheet] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.Timesheet */
ALTER TABLE [${flyway:defaultSchema}].[Timesheet] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.Timesheet */
ALTER TABLE [${flyway:defaultSchema}].[Timesheet] ADD CONSTRAINT [DF___mj_BizAppsTasks_Timesheet___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.Timesheet */
ALTER TABLE [${flyway:defaultSchema}].[Timesheet] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.Timesheet */
UPDATE [${flyway:defaultSchema}].[Timesheet] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.Timesheet */
ALTER TABLE [${flyway:defaultSchema}].[Timesheet] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.Timesheet */
ALTER TABLE [${flyway:defaultSchema}].[Timesheet] ADD CONSTRAINT [DF___mj_BizAppsTasks_Timesheet___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTimeEntryLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimeEntryLink] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTimeEntryLink */
UPDATE [${flyway:defaultSchema}].[TaskTimeEntryLink] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTimeEntryLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimeEntryLink] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTimeEntryLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimeEntryLink] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTimeEntryLink___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTimeEntryLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimeEntryLink] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTimeEntryLink */
UPDATE [${flyway:defaultSchema}].[TaskTimeEntryLink] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTimeEntryLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimeEntryLink] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTimeEntryLink */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimeEntryLink] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTimeEntryLink___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TimesheetSchedule */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetSchedule] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TimesheetSchedule */
UPDATE [${flyway:defaultSchema}].[TimesheetSchedule] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TimesheetSchedule */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetSchedule] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TimesheetSchedule */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetSchedule] ADD CONSTRAINT [DF___mj_BizAppsTasks_TimesheetSchedule___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TimesheetSchedule */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetSchedule] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TimesheetSchedule */
UPDATE [${flyway:defaultSchema}].[TimesheetSchedule] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TimesheetSchedule */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetSchedule] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TimesheetSchedule */
ALTER TABLE [${flyway:defaultSchema}].[TimesheetSchedule] ADD CONSTRAINT [DF___mj_BizAppsTasks_TimesheetSchedule___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTimeEntry */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimeEntry] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTimeEntry */
UPDATE [${flyway:defaultSchema}].[TaskTimeEntry] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTimeEntry */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimeEntry] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TaskTimeEntry */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimeEntry] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTimeEntry___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTimeEntry */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimeEntry] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTimeEntry */
UPDATE [${flyway:defaultSchema}].[TaskTimeEntry] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTimeEntry */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimeEntry] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TaskTimeEntry */
ALTER TABLE [${flyway:defaultSchema}].[TaskTimeEntry] ADD CONSTRAINT [DF___mj_BizAppsTasks_TaskTimeEntry___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TimeApprover */
ALTER TABLE [${flyway:defaultSchema}].[TimeApprover] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TimeApprover */
UPDATE [${flyway:defaultSchema}].[TimeApprover] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TimeApprover */
ALTER TABLE [${flyway:defaultSchema}].[TimeApprover] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity ${flyway:defaultSchema}.TimeApprover */
ALTER TABLE [${flyway:defaultSchema}].[TimeApprover] ADD CONSTRAINT [DF___mj_BizAppsTasks_TimeApprover___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TimeApprover */
ALTER TABLE [${flyway:defaultSchema}].[TimeApprover] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TimeApprover */
UPDATE [${flyway:defaultSchema}].[TimeApprover] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TimeApprover */
ALTER TABLE [${flyway:defaultSchema}].[TimeApprover] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity ${flyway:defaultSchema}.TimeApprover */
ALTER TABLE [${flyway:defaultSchema}].[TimeApprover] ADD CONSTRAINT [DF___mj_BizAppsTasks_TimeApprover___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to insert 99 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '10a4264b-9519-4c9d-8f43-855a97d402a7' OR (EntityID = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '10a4264b-9519-4c9d-8f43-855a97d402a7',
            '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- Entity: MJ_BizApps_Tasks: Task Agent Runs
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
            'ID',
            'ID',
            'Primary key for the task agent run link.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '16554986-6995-435a-a9f6-62c837d5fd72' OR (EntityID = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND Name = 'TaskID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '16554986-6995-435a-a9f6-62c837d5fd72',
            '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- Entity: MJ_BizApps_Tasks: Task Agent Runs
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
            'TaskID',
            'Task ID',
            'The task the AI agent run contributed to.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ab51a173-82c1-4f42-86a6-8cc30ccd8048' OR (EntityID = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND Name = 'AIAgentRunID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ab51a173-82c1-4f42-86a6-8cc30ccd8048',
            '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- Entity: MJ_BizApps_Tasks: Task Agent Runs
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
            'AIAgentRunID',
            'AI Agent Run ID',
            'The MemberJunction AI Agent Run linked to the task.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            '5190AF93-4C39-4429-BDAA-0AEB492A0256',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8ad0134d-2f51-4fdd-baf2-4fe7cb8f8f82' OR (EntityID = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND Name = 'Role')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8ad0134d-2f51-4fdd-baf2-4fe7cb8f8f82',
            '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- Entity: MJ_BizApps_Tasks: Task Agent Runs
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
            'Role',
            'Role',
            'How the agent run contributed to the task: Executed, Assisted, Reviewed, Planned, or Triaged.',
            'nvarchar',
            60,
            0,
            0,
            0,
            'Executed',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '008c8596-40fc-49db-bea2-a6659a1d2de9' OR (EntityID = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND Name = 'Notes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '008c8596-40fc-49db-bea2-a6659a1d2de9',
            '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- Entity: MJ_BizApps_Tasks: Task Agent Runs
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
            'Notes',
            'Notes',
            'Optional notes describing what the agent run did for the task.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6e54ffef-dbd9-483c-a4c4-c9a56fc37326' OR (EntityID = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6e54ffef-dbd9-483c-a4c4-c9a56fc37326',
            '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- Entity: MJ_BizApps_Tasks: Task Agent Runs
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'cf1cfefe-a9c1-41ed-9a9f-557063415d94' OR (EntityID = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'cf1cfefe-a9c1-41ed-9a9f-557063415d94',
            '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- Entity: MJ_BizApps_Tasks: Task Agent Runs
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '008647c6-3662-4df7-8897-c6a98c0c5330' OR (EntityID = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '008647c6-3662-4df7-8897-c6a98c0c5330',
            'D594B91D-4DE0-4D20-8D71-21F041FA505D', -- Entity: MJ_BizApps_Tasks: Timesheet Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D594B91D-4DE0-4D20-8D71-21F041FA505D'),
            'ID',
            'ID',
            'Primary key for the timesheet link.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '19dcc9ea-6024-4c8c-a595-651b4d7915a7' OR (EntityID = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND Name = 'TimesheetID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '19dcc9ea-6024-4c8c-a595-651b4d7915a7',
            'D594B91D-4DE0-4D20-8D71-21F041FA505D', -- Entity: MJ_BizApps_Tasks: Timesheet Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D594B91D-4DE0-4D20-8D71-21F041FA505D'),
            'TimesheetID',
            'Timesheet ID',
            'The Timesheet being linked.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            'ED90EE09-0D39-4298-93DC-77C057FCE97A',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd14542b0-ed38-4ecd-83cf-6645eeb5be2e' OR (EntityID = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND Name = 'EntityID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd14542b0-ed38-4ecd-83cf-6645eeb5be2e',
            'D594B91D-4DE0-4D20-8D71-21F041FA505D', -- Entity: MJ_BizApps_Tasks: Timesheet Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D594B91D-4DE0-4D20-8D71-21F041FA505D'),
            'EntityID',
            'Entity ID',
            'Target MemberJunction Entity ID for the linked external record.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            'E0238F34-2837-EF11-86D4-6045BDEE16E6',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fa2e8a87-cb72-4491-ab69-706bd03f32da' OR (EntityID = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND Name = 'RecordID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'fa2e8a87-cb72-4491-ab69-706bd03f32da',
            'D594B91D-4DE0-4D20-8D71-21F041FA505D', -- Entity: MJ_BizApps_Tasks: Timesheet Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D594B91D-4DE0-4D20-8D71-21F041FA505D'),
            'RecordID',
            'Record ID',
            'Primary key value of the linked record in EntityID.',
            'nvarchar',
            900,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2ea93151-5257-4972-be84-6cb41d3541d8' OR (EntityID = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND Name = 'Relationship')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2ea93151-5257-4972-be84-6cb41d3541d8',
            'D594B91D-4DE0-4D20-8D71-21F041FA505D', -- Entity: MJ_BizApps_Tasks: Timesheet Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D594B91D-4DE0-4D20-8D71-21F041FA505D'),
            'Relationship',
            'Relationship',
            'Semantic relationship of the linked record to the timesheet: PayrollBatch, Invoice, ExpenseReport, or Related.',
            'nvarchar',
            60,
            0,
            0,
            0,
            'Related',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b2dbcb2d-38ba-49c7-9872-c6add8479fd8' OR (EntityID = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b2dbcb2d-38ba-49c7-9872-c6add8479fd8',
            'D594B91D-4DE0-4D20-8D71-21F041FA505D', -- Entity: MJ_BizApps_Tasks: Timesheet Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D594B91D-4DE0-4D20-8D71-21F041FA505D'),
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6d6c70c4-0895-4f55-bb81-e070940b5464' OR (EntityID = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6d6c70c4-0895-4f55-bb81-e070940b5464',
            'D594B91D-4DE0-4D20-8D71-21F041FA505D', -- Entity: MJ_BizApps_Tasks: Timesheet Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D594B91D-4DE0-4D20-8D71-21F041FA505D'),
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'dec85961-3349-4f5e-a436-d24fc71ef6ff' OR (EntityID = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'dec85961-3349-4f5e-a436-d24fc71ef6ff',
            '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- Entity: MJ_BizApps_Tasks: Task Timers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
            'ID',
            'ID',
            'Primary key for the running timer.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c331ddd2-06cc-4dea-833f-bdaeafc80db8' OR (EntityID = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND Name = 'TaskID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c331ddd2-06cc-4dea-833f-bdaeafc80db8',
            '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- Entity: MJ_BizApps_Tasks: Task Timers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
            'TaskID',
            'Task ID',
            'The task currently being timed.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '033e45df-d452-4846-bf76-537937eef114' OR (EntityID = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND Name = 'PersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '033e45df-d452-4846-bf76-537937eef114',
            '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- Entity: MJ_BizApps_Tasks: Task Timers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
            'PersonID',
            'Person ID',
            'The Person whose stopwatch is running (unique across TaskTimer).',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1ae44efe-9590-4af3-8546-3a2388b2ef24' OR (EntityID = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND Name = 'StartedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1ae44efe-9590-4af3-8546-3a2388b2ef24',
            '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- Entity: MJ_BizApps_Tasks: Task Timers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
            'StartedAt',
            'Started At',
            'Timestamp when the timer was started.',
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'sysdatetimeoffset()',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3df0d48b-c3ca-4578-9de3-0970425d1bba' OR (EntityID = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND Name = 'Notes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3df0d48b-c3ca-4578-9de3-0970425d1bba',
            '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- Entity: MJ_BizApps_Tasks: Task Timers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
            'Notes',
            'Notes',
            'Draft work notes carried over into the resulting TaskTimeEntry rows when the timer stops.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9c62fb30-1e7d-4ed3-b081-3fd0e9f38ae3' OR (EntityID = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND Name = 'IsBillable')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9c62fb30-1e7d-4ed3-b081-3fd0e9f38ae3',
            '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- Entity: MJ_BizApps_Tasks: Task Timers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
            'IsBillable',
            'Is Billable',
            'Billable flag carried over into the resulting TaskTimeEntry rows when the timer stops.',
            'bit',
            1,
            1,
            0,
            0,
            '(0)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '45e7a083-2d91-4c04-8442-ad5cde338a7f' OR (EntityID = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '45e7a083-2d91-4c04-8442-ad5cde338a7f',
            '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- Entity: MJ_BizApps_Tasks: Task Timers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4bc42f17-02da-4118-8f21-df320a41cb17' OR (EntityID = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4bc42f17-02da-4118-8f21-df320a41cb17',
            '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- Entity: MJ_BizApps_Tasks: Task Timers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4f2ae59e-b44e-457d-8f74-fb49960b042c' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4f2ae59e-b44e-457d-8f74-fb49960b042c',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            'ID',
            'ID',
            'Primary key for the timesheet approval part.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '31c7941c-e273-4217-a603-01a8e961bb25' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = 'TimesheetID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '31c7941c-e273-4217-a603-01a8e961bb25',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            'TimesheetID',
            'Timesheet ID',
            'The Timesheet this approval slice belongs to.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            'ED90EE09-0D39-4298-93DC-77C057FCE97A',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'bdbec7ef-0a27-480e-8dd3-b1697358cf3a' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = 'SubmissionRound')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'bdbec7ef-0a27-480e-8dd3-b1697358cf3a',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            'SubmissionRound',
            'Submission Round',
            'Submission round number (1 on initial submit, incremented on each resubmit).',
            'int',
            4,
            10,
            0,
            0,
            '(1)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '313378b3-a046-4a6e-a58d-7d1ce9486988' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = 'ScopeTaskID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '313378b3-a046-4a6e-a58d-7d1ce9486988',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            'ScopeTaskID',
            'Scope Task ID',
            'Root project task for this approval slice, or NULL for the whole-timesheet / unassigned slice.',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'da4b81fd-828e-4b52-b51e-a56a2216a124' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = 'ApprovalTaskID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'da4b81fd-828e-4b52-b51e-a56a2216a124',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            'ApprovalTaskID',
            'Approval Task ID',
            'The approval Task created in the Tasks inbox for this slice.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '42303ef6-dd3d-408e-af35-4ecb9cc2706e' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = 'Minutes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '42303ef6-dd3d-408e-af35-4ecb9cc2706e',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            'Minutes',
            'Minutes',
            'Total minutes in this approval slice at submission time.',
            'int',
            4,
            10,
            0,
            0,
            '(0)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '77571818-970e-4694-905e-b4b1b35aa43a' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = 'BillableMinutes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '77571818-970e-4694-905e-b4b1b35aa43a',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            'BillableMinutes',
            'Billable Minutes',
            'Total billable minutes in this approval slice at submission time.',
            'int',
            4,
            10,
            0,
            0,
            '(0)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '425a8f3d-b2c6-4e8b-bb5c-da1f4ba52a37' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = 'EntryCount')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '425a8f3d-b2c6-4e8b-bb5c-da1f4ba52a37',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            'EntryCount',
            'Entry Count',
            'Number of TaskTimeEntry rows included in this approval slice.',
            'int',
            4,
            10,
            0,
            0,
            '(0)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '30f4c2c5-5a50-4aeb-b2cb-e1751ebf4e23' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = 'SnapshotHash')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '30f4c2c5-5a50-4aeb-b2cb-e1751ebf4e23',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            'SnapshotHash',
            'Snapshot Hash',
            'Deterministic SHA-256 hex digest of the slice time entries, used to carry forward unchanged Approved parts across resubmissions.',
            'nvarchar',
            128,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '062734fe-ac90-42bb-b3ba-09fda28a517e' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = 'Status')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '062734fe-ac90-42bb-b3ba-09fda28a517e',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            'Status',
            'Status',
            'Current status of this approval slice: Pending, Approved, Rejected, or Canceled.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Pending',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8bee7526-7aff-4767-8ba2-6a752b8b7000' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = 'DecidedByPersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8bee7526-7aff-4767-8ba2-6a752b8b7000',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            'DecidedByPersonID',
            'Decided By Person ID',
            'The Person who recorded the approval or rejection decision.',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a0fa4544-0274-495b-b285-5de5dd6a92b3' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = 'DecidedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a0fa4544-0274-495b-b285-5de5dd6a92b3',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            'DecidedAt',
            'Decided At',
            'Timestamp when the decision on this slice was recorded.',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '71d9821c-22a1-4f42-996f-f28699998dce' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = 'DecisionNotes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '71d9821c-22a1-4f42-996f-f28699998dce',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            'DecisionNotes',
            'Decision Notes',
            'Notes or feedback provided by the approver when deciding this slice.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '24702025-cddd-4c55-bdcd-7b0fb9abf565' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '24702025-cddd-4c55-bdcd-7b0fb9abf565',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '254eb111-1fdb-4354-a0b8-8d7a996474b6' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '254eb111-1fdb-4354-a0b8-8d7a996474b6',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5bb85555-0b3c-4a59-88d5-c9308cd72a46' OR (EntityID = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5bb85555-0b3c-4a59-88d5-c9308cd72a46',
            'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- Entity: MJ_BizApps_Tasks: Timesheets
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
            'ID',
            'ID',
            'Primary key for the timesheet.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'c5d5c45e-61c7-45f9-afce-2a9798f84aa2' OR (EntityID = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND Name = 'PersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c5d5c45e-61c7-45f9-afce-2a9798f84aa2',
            'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- Entity: MJ_BizApps_Tasks: Timesheets
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
            'PersonID',
            'Person ID',
            'The Person whose time entries are covered by this timesheet.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4eb77aea-41c5-4fab-bdba-0d15c5ae3101' OR (EntityID = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND Name = 'PeriodStart')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4eb77aea-41c5-4fab-bdba-0d15c5ae3101',
            'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- Entity: MJ_BizApps_Tasks: Timesheets
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
            'PeriodStart',
            'Period Start',
            'Inclusive start date of the timesheet period.',
            'date',
            3,
            10,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f6c58764-9078-4ac5-9f88-b7f3685e2aae' OR (EntityID = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND Name = 'PeriodEnd')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f6c58764-9078-4ac5-9f88-b7f3685e2aae',
            'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- Entity: MJ_BizApps_Tasks: Timesheets
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
            'PeriodEnd',
            'Period End',
            'Inclusive end date of the timesheet period.',
            'date',
            3,
            10,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'dcafd61e-a2f4-4d42-819c-f37b9638cf35' OR (EntityID = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND Name = 'Status')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'dcafd61e-a2f4-4d42-819c-f37b9638cf35',
            'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- Entity: MJ_BizApps_Tasks: Timesheets
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
            'Status',
            'Status',
            'Lifecycle status of the timesheet: Draft, Submitted, Approved, or Rejected.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Draft',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'df49cc9a-4e5f-404a-9d32-9ca929abdc89' OR (EntityID = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND Name = 'SubmittedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'df49cc9a-4e5f-404a-9d32-9ca929abdc89',
            'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- Entity: MJ_BizApps_Tasks: Timesheets
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
            'SubmittedAt',
            'Submitted At',
            'Timestamp when the timesheet was most recently submitted.',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'bc31c246-345f-4a54-8c9f-a09f01295492' OR (EntityID = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND Name = 'SubmittedByUserID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'bc31c246-345f-4a54-8c9f-a09f01295492',
            'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- Entity: MJ_BizApps_Tasks: Timesheets
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
            'SubmittedByUserID',
            'Submitted By User ID',
            'The MemberJunction User who submitted the timesheet.',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            'E1238F34-2837-EF11-86D4-6045BDEE16E6',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '23a414b3-9872-4854-9977-be1fa4bed440' OR (EntityID = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND Name = 'TotalMinutes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '23a414b3-9872-4854-9977-be1fa4bed440',
            'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- Entity: MJ_BizApps_Tasks: Timesheets
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
            'TotalMinutes',
            'Total Minutes',
            'Total minutes across all time entries attached to this timesheet.',
            'int',
            4,
            10,
            0,
            0,
            '(0)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e129f157-61f0-4638-8e15-03719a49dd22' OR (EntityID = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND Name = 'BillableMinutes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e129f157-61f0-4638-8e15-03719a49dd22',
            'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- Entity: MJ_BizApps_Tasks: Timesheets
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
            'BillableMinutes',
            'Billable Minutes',
            'Total billable minutes across all time entries attached to this timesheet.',
            'int',
            4,
            10,
            0,
            0,
            '(0)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4f6d6e31-e5e6-4b69-81c1-e6c28c18f346' OR (EntityID = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND Name = 'Notes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4f6d6e31-e5e6-4b69-81c1-e6c28c18f346',
            'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- Entity: MJ_BizApps_Tasks: Timesheets
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
            'Notes',
            'Notes',
            'Worker notes or comments submitted with the timesheet.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9815c5be-a1a4-498f-a080-1bfc656490ff' OR (EntityID = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9815c5be-a1a4-498f-a080-1bfc656490ff',
            'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- Entity: MJ_BizApps_Tasks: Timesheets
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '34b24358-368d-4238-8063-4c664026eb73' OR (EntityID = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '34b24358-368d-4238-8063-4c664026eb73',
            'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- Entity: MJ_BizApps_Tasks: Timesheets
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '32c6e1e7-7717-47e7-99b7-5dd4efd42895' OR (EntityID = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '32c6e1e7-7717-47e7-99b7-5dd4efd42895',
            '5A25B67B-D67D-453F-8340-94BF69CF8CEE', -- Entity: MJ_BizApps_Tasks: Task Time Entry Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '5A25B67B-D67D-453F-8340-94BF69CF8CEE'),
            'ID',
            'ID',
            'Primary key for the task time entry link.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'ecfd46fe-63d5-445d-8282-3bc018676cba' OR (EntityID = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND Name = 'TaskTimeEntryID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ecfd46fe-63d5-445d-8282-3bc018676cba',
            '5A25B67B-D67D-453F-8340-94BF69CF8CEE', -- Entity: MJ_BizApps_Tasks: Task Time Entry Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '5A25B67B-D67D-453F-8340-94BF69CF8CEE'),
            'TaskTimeEntryID',
            'Task Time Entry ID',
            'The TaskTimeEntry being linked.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            'EA40801A-DF1B-443A-B0D3-EA0415645603',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '023bf220-43da-42b1-b24d-331243bdb452' OR (EntityID = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND Name = 'EntityID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '023bf220-43da-42b1-b24d-331243bdb452',
            '5A25B67B-D67D-453F-8340-94BF69CF8CEE', -- Entity: MJ_BizApps_Tasks: Task Time Entry Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '5A25B67B-D67D-453F-8340-94BF69CF8CEE'),
            'EntityID',
            'Entity ID',
            'Target MemberJunction Entity ID for the linked external record.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            'E0238F34-2837-EF11-86D4-6045BDEE16E6',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6721c788-1070-4dc1-876d-f67307aafeb7' OR (EntityID = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND Name = 'RecordID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6721c788-1070-4dc1-876d-f67307aafeb7',
            '5A25B67B-D67D-453F-8340-94BF69CF8CEE', -- Entity: MJ_BizApps_Tasks: Task Time Entry Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '5A25B67B-D67D-453F-8340-94BF69CF8CEE'),
            'RecordID',
            'Record ID',
            'Primary key value of the linked record in EntityID.',
            'nvarchar',
            900,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3d44d5b8-b4fe-4929-8980-7967f79e8e7d' OR (EntityID = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND Name = 'Relationship')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3d44d5b8-b4fe-4929-8980-7967f79e8e7d',
            '5A25B67B-D67D-453F-8340-94BF69CF8CEE', -- Entity: MJ_BizApps_Tasks: Task Time Entry Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '5A25B67B-D67D-453F-8340-94BF69CF8CEE'),
            'Relationship',
            'Relationship',
            'Semantic relationship of the linked record to the time entry: InvoiceLine, JournalEntryLine, Commit, PullRequest, or Related.',
            'nvarchar',
            60,
            0,
            0,
            0,
            'Related',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '3150f98d-8c90-4da3-a33b-b2ddaa8f7763' OR (EntityID = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3150f98d-8c90-4da3-a33b-b2ddaa8f7763',
            '5A25B67B-D67D-453F-8340-94BF69CF8CEE', -- Entity: MJ_BizApps_Tasks: Task Time Entry Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '5A25B67B-D67D-453F-8340-94BF69CF8CEE'),
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '798cd59a-52c7-4479-8bbf-d7fcdee5c871' OR (EntityID = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '798cd59a-52c7-4479-8bbf-d7fcdee5c871',
            '5A25B67B-D67D-453F-8340-94BF69CF8CEE', -- Entity: MJ_BizApps_Tasks: Task Time Entry Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '5A25B67B-D67D-453F-8340-94BF69CF8CEE'),
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'dcb405a1-7f31-4016-b177-eb813df88895' OR (EntityID = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'dcb405a1-7f31-4016-b177-eb813df88895',
            '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- Entity: MJ_BizApps_Tasks: Timesheet Schedules
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
            'ID',
            'ID',
            'Primary key for the timesheet schedule.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '73405dd0-fad3-4c48-948d-58d729e26521' OR (EntityID = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND Name = 'PersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '73405dd0-fad3-4c48-948d-58d729e26521',
            '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- Entity: MJ_BizApps_Tasks: Timesheet Schedules
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
            'PersonID',
            'Person ID',
            'Optional Person this schedule applies to (NULL for organization/entity-scoped or global schedules).',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2ce5f2b1-19bc-444f-8ebb-96263103b081' OR (EntityID = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND Name = 'ScopeEntityID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2ce5f2b1-19bc-444f-8ebb-96263103b081',
            '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- Entity: MJ_BizApps_Tasks: Timesheet Schedules
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
            'ScopeEntityID',
            'Scope Entity ID',
            'Optional MJ Entity ID when scoping the schedule to an organization or department record.',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            'E0238F34-2837-EF11-86D4-6045BDEE16E6',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd5c5fbf0-f90a-48cd-a06e-34cea9b924fe' OR (EntityID = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND Name = 'ScopeRecordID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd5c5fbf0-f90a-48cd-a06e-34cea9b924fe',
            '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- Entity: MJ_BizApps_Tasks: Timesheet Schedules
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
            'ScopeRecordID',
            'Scope Record ID',
            'Companion record ID in ScopeEntityID for entity-scoped schedules.',
            'nvarchar',
            900,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '8a2be0bf-64c1-4429-a821-8c8213fdc3c5' OR (EntityID = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND Name = 'Cadence')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '8a2be0bf-64c1-4429-a821-8c8213fdc3c5',
            '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- Entity: MJ_BizApps_Tasks: Timesheet Schedules
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
            'Cadence',
            'Cadence',
            'Timesheet period cadence: Weekly, BiWeekly, SemiMonthly, or Monthly.',
            'nvarchar',
            40,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e423a509-1f64-48d0-a6c9-e40fcaabbc39' OR (EntityID = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND Name = 'WeekStartDay')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e423a509-1f64-48d0-a6c9-e40fcaabbc39',
            '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- Entity: MJ_BizApps_Tasks: Timesheet Schedules
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
            'WeekStartDay',
            'Week Start Day',
            'First day of the work week for Weekly and BiWeekly cadences: Monday, Sunday, or Saturday.',
            'nvarchar',
            20,
            0,
            0,
            0,
            'Monday',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '89ea42e1-0e09-419d-8fe9-e2c67eca4bab' OR (EntityID = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND Name = 'BiWeeklyAnchorDate')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '89ea42e1-0e09-419d-8fe9-e2c67eca4bab',
            '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- Entity: MJ_BizApps_Tasks: Timesheet Schedules
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
            'BiWeeklyAnchorDate',
            'Bi Weekly Anchor Date',
            'Anchor date (which must fall on WeekStartDay) defining the 14-day boundary for BiWeekly cadences.',
            'date',
            3,
            10,
            0,
            0,
            '2026-01-05',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f01ac808-cef3-40e0-8693-cf9cbeb878a7' OR (EntityID = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND Name = 'EffectiveFrom')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f01ac808-cef3-40e0-8693-cf9cbeb878a7',
            '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- Entity: MJ_BizApps_Tasks: Timesheet Schedules
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
            'EffectiveFrom',
            'Effective From',
            'Inclusive start date from which this schedule is effective (must fall on a period boundary).',
            'date',
            3,
            10,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '63c8dc44-f85b-40c9-9b6b-a725f26a42f3' OR (EntityID = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND Name = 'EffectiveTo')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '63c8dc44-f85b-40c9-9b6b-a725f26a42f3',
            '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- Entity: MJ_BizApps_Tasks: Timesheet Schedules
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
            'EffectiveTo',
            'Effective To',
            'Optional inclusive end date through which this schedule is effective.',
            'date',
            3,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b94e0a7b-f022-4805-b0e9-3dd73fa0372e' OR (EntityID = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND Name = 'Notes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b94e0a7b-f022-4805-b0e9-3dd73fa0372e',
            '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- Entity: MJ_BizApps_Tasks: Timesheet Schedules
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
            'Notes',
            'Notes',
            'Optional notes explaining this schedule or cadence change.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'b9014bd1-90ee-4315-840f-a9a47168eb8a' OR (EntityID = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b9014bd1-90ee-4315-840f-a9a47168eb8a',
            '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- Entity: MJ_BizApps_Tasks: Timesheet Schedules
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd10e9b23-be52-4a0a-af35-619e08da1550' OR (EntityID = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd10e9b23-be52-4a0a-af35-619e08da1550',
            '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- Entity: MJ_BizApps_Tasks: Timesheet Schedules
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f0054c13-720c-49d9-9ebd-11802d49caac' OR (EntityID = '1E30141A-826F-4278-BAA9-BBE14D29E606' AND Name = 'RequiresAssigneeDecision')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f0054c13-720c-49d9-9ebd-11802d49caac',
            '1E30141A-826F-4278-BAA9-BBE14D29E606', -- Entity: MJ_BizApps_Tasks: Task Types
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '1E30141A-826F-4278-BAA9-BBE14D29E606'),
            'RequiresAssigneeDecision',
            'Requires Assignee Decision',
            'When true on an approval task type, only an assigned approver (and never the task creator unless exempt) may record a decision on tasks of this type, regardless of the global PreventSelfApproval setting.',
            'bit',
            1,
            1,
            0,
            0,
            '(0)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '11176ee4-de36-49c9-97ae-854962530dc8' OR (EntityID = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '11176ee4-de36-49c9-97ae-854962530dc8',
            'EA40801A-DF1B-443A-B0D3-EA0415645603', -- Entity: MJ_BizApps_Tasks: Task Time Entries
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
            'ID',
            'ID',
            'Primary key for the task time entry.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '91493f5a-6b8c-48b4-82dc-4455a88797a8' OR (EntityID = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND Name = 'TaskID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '91493f5a-6b8c-48b4-82dc-4455a88797a8',
            'EA40801A-DF1B-443A-B0D3-EA0415645603', -- Entity: MJ_BizApps_Tasks: Task Time Entries
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
            'TaskID',
            'Task ID',
            'The task this time entry is logged against.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '5cc9964f-5ca5-4be3-9237-9901052413b3' OR (EntityID = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND Name = 'PersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '5cc9964f-5ca5-4be3-9237-9901052413b3',
            'EA40801A-DF1B-443A-B0D3-EA0415645603', -- Entity: MJ_BizApps_Tasks: Task Time Entries
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
            'PersonID',
            'Person ID',
            'The Person who performed the work.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '74d80d59-9934-4656-bd13-3d919f088aca' OR (EntityID = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND Name = 'WorkDate')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '74d80d59-9934-4656-bd13-3d919f088aca',
            'EA40801A-DF1B-443A-B0D3-EA0415645603', -- Entity: MJ_BizApps_Tasks: Task Time Entries
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
            'WorkDate',
            'Work Date',
            'Business calendar date the work was performed on.',
            'date',
            3,
            10,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a4b7b796-99d1-4283-bc8a-94f6dcd24f4f' OR (EntityID = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND Name = 'Minutes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a4b7b796-99d1-4283-bc8a-94f6dcd24f4f',
            'EA40801A-DF1B-443A-B0D3-EA0415645603', -- Entity: MJ_BizApps_Tasks: Task Time Entries
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
            'Minutes',
            'Minutes',
            'Duration of work in whole minutes (1 to 1440).',
            'int',
            4,
            10,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a58eed88-9e28-49c6-aec3-795bff8193f9' OR (EntityID = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND Name = 'StartedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a58eed88-9e28-49c6-aec3-795bff8193f9',
            'EA40801A-DF1B-443A-B0D3-EA0415645603', -- Entity: MJ_BizApps_Tasks: Task Time Entries
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
            'StartedAt',
            'Started At',
            'Optional timestamp when the work interval started (populated for timer-backed entries).',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a2f0a401-c8f7-4d3d-ae20-f57201dc594d' OR (EntityID = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND Name = 'EndedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a2f0a401-c8f7-4d3d-ae20-f57201dc594d',
            'EA40801A-DF1B-443A-B0D3-EA0415645603', -- Entity: MJ_BizApps_Tasks: Task Time Entries
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
            'EndedAt',
            'Ended At',
            'Optional timestamp when the work interval ended (populated for timer-backed entries).',
            'datetimeoffset',
            10,
            34,
            7,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a9d9f3ea-2041-4314-9116-cb9073078f83' OR (EntityID = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND Name = 'Notes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a9d9f3ea-2041-4314-9116-cb9073078f83',
            'EA40801A-DF1B-443A-B0D3-EA0415645603', -- Entity: MJ_BizApps_Tasks: Task Time Entries
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
            'Notes',
            'Notes',
            'Narrative description of what was accomplished during this time entry.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '73b9b79b-bdb8-479f-8db1-4677da98f85f' OR (EntityID = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND Name = 'Source')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '73b9b79b-bdb8-479f-8db1-4677da98f85f',
            'EA40801A-DF1B-443A-B0D3-EA0415645603', -- Entity: MJ_BizApps_Tasks: Task Time Entries
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
            'Source',
            'Source',
            'How the time entry was created: Manual, Timer, Imported, or Agent.',
            'nvarchar',
            40,
            0,
            0,
            0,
            'Manual',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6e75e4ab-b38b-42cc-8958-af5d1bc5313c' OR (EntityID = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND Name = 'IsBillable')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6e75e4ab-b38b-42cc-8958-af5d1bc5313c',
            'EA40801A-DF1B-443A-B0D3-EA0415645603', -- Entity: MJ_BizApps_Tasks: Task Time Entries
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
            'IsBillable',
            'Is Billable',
            'Whether this time entry is billable to a client or external party.',
            'bit',
            1,
            1,
            0,
            0,
            '(0)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '27604c00-3920-4c53-a0a7-182421db2d65' OR (EntityID = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND Name = 'TimesheetID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '27604c00-3920-4c53-a0a7-182421db2d65',
            'EA40801A-DF1B-443A-B0D3-EA0415645603', -- Entity: MJ_BizApps_Tasks: Task Time Entries
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
            'TimesheetID',
            'Timesheet ID',
            'Optional Timesheet this time entry has been attached to.',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            'ED90EE09-0D39-4298-93DC-77C057FCE97A',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '97466ac9-28b2-4a28-9b47-e2490194426d' OR (EntityID = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '97466ac9-28b2-4a28-9b47-e2490194426d',
            'EA40801A-DF1B-443A-B0D3-EA0415645603', -- Entity: MJ_BizApps_Tasks: Task Time Entries
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '48e91c0a-bd0a-40a9-bd35-323bb43eceee' OR (EntityID = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '48e91c0a-bd0a-40a9-bd35-323bb43eceee',
            'EA40801A-DF1B-443A-B0D3-EA0415645603', -- Entity: MJ_BizApps_Tasks: Task Time Entries
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '975e4d65-8b74-4bda-9e6f-6d4413fa1d2b' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'LoggedMinutes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '975e4d65-8b74-4bda-9e6f-6d4413fa1d2b',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
            'LoggedMinutes',
            'Logged Minutes',
            NULL,
            'int',
            4,
            10,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '189e951c-1bde-450c-86b7-17db5a94c50a' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'AgentRunCount')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '189e951c-1bde-450c-86b7-17db5a94c50a',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
            'AgentRunCount',
            'Agent Run Count',
            NULL,
            'int',
            4,
            10,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'e897f9ea-75e9-4ff4-8cba-99031292ae72' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'AgentCost')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'e897f9ea-75e9-4ff4-8cba-99031292ae72',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
            'AgentCost',
            'Agent Cost',
            NULL,
            'decimal',
            17,
            38,
            8,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '633313c6-a992-4fe6-9da1-205fd09f2c30' OR (EntityID = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND Name = 'AgentTokens')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '633313c6-a992-4fe6-9da1-205fd09f2c30',
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', -- Entity: MJ_BizApps_Tasks: Tasks
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466'),
            'AgentTokens',
            'Agent Tokens',
            NULL,
            'int',
            4,
            10,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'efb188d4-046b-4904-b1cc-7ce66b6aadc2' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = 'ID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'efb188d4-046b-4904-b1cc-7ce66b6aadc2',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            'ID',
            'ID',
            'Primary key for the time approver rule.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '384549e1-5ddd-481c-a809-862c39893966' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = 'ApproverPersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '384549e1-5ddd-481c-a809-862c39893966',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            'ApproverPersonID',
            'Approver Person ID',
            'The Person who is granted time approval authority by this rule.',
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0c2c4d67-b8a8-442a-9ce8-e2f0d35a183e' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = 'WorkerPersonID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0c2c4d67-b8a8-442a-9ce8-e2f0d35a183e',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            'WorkerPersonID',
            'Worker Person ID',
            'Optional Worker Person whose time this rule applies to (NULL matches any worker).',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '690c2a28-5f12-47de-8580-12e6f0990ec7' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = 'ScopeTaskID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '690c2a28-5f12-47de-8580-12e6f0990ec7',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            'ScopeTaskID',
            'Scope Task ID',
            'Optional project/parent Task this rule scopes approval to (NULL matches any task).',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9e17e4c3-ca9c-4b4a-841c-d5efb5d6259c' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = 'IncludeDescendants')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9e17e4c3-ca9c-4b4a-841c-d5efb5d6259c',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            'IncludeDescendants',
            'Include Descendants',
            'When ScopeTaskID is set, whether sub-tasks beneath ScopeTaskID also match this rule.',
            'bit',
            1,
            1,
            0,
            0,
            '(1)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            1,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fe1bf4b9-32b1-4edc-9e13-dbe524f895a6' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = 'ScopeEntityID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'fe1bf4b9-32b1-4edc-9e13-dbe524f895a6',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            'ScopeEntityID',
            'Scope Entity ID',
            'Optional MJ Entity ID when scoping approval to tasks linked to an external record via TaskLink.',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            'E0238F34-2837-EF11-86D4-6045BDEE16E6',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '96bc903c-08e1-45ad-8a02-4078f80383d4' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = 'ScopeRecordID')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '96bc903c-08e1-45ad-8a02-4078f80383d4',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            'ScopeRecordID',
            'Scope Record ID',
            'Companion record ID in ScopeEntityID when scoping approval to tasks linked via TaskLink.',
            'nvarchar',
            900,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '49619251-166f-444d-9595-ba0e019604c6' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = 'EffectiveFrom')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '49619251-166f-444d-9595-ba0e019604c6',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            'EffectiveFrom',
            'Effective From',
            'Optional start date from which this approver rule is effective.',
            'date',
            3,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '18b4dfb6-d189-468c-9ad4-ec4a973093f9' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = 'EffectiveTo')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '18b4dfb6-d189-468c-9ad4-ec4a973093f9',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            'EffectiveTo',
            'Effective To',
            'Optional end date through which this approver rule is effective.',
            'date',
            3,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4b175a4f-ec87-44c5-8a07-7dde597d6130' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = 'IsActive')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4b175a4f-ec87-44c5-8a07-7dde597d6130',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            'IsActive',
            'Is Active',
            'Whether this approver rule is currently active.',
            'bit',
            1,
            1,
            0,
            0,
            '(1)',
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f6953759-6df8-45a6-902b-ca152e95439a' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = 'Notes')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f6953759-6df8-45a6-902b-ca152e95439a',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            'Notes',
            'Notes',
            'Optional administrative notes about this approver rule.',
            'nvarchar',
            -1,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '51d6a9a2-cf3f-4375-b6ab-f66d72c05424' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = '__mj_CreatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '51d6a9a2-cf3f-4375-b6ab-f66d72c05424',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9afd097d-bdb5-4663-a8e9-3481a153be6d' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = '__mj_UpdatedAt')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9afd097d-bdb5-4663-a8e9-3481a153be6d',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

/* SQL text to update existing entity fields from schema */
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to insert entity field value with ID 0f7adb8a-27f4-45b5-9ce4-9b8441ff54ed */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0f7adb8a-27f4-45b5-9ce4-9b8441ff54ed', '73B9B79B-BDB8-479F-8DB1-4677DA98F85F', 1, 'Agent', 'Agent', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 83d181db-a0af-412a-9a74-922e5086c460 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('83d181db-a0af-412a-9a74-922e5086c460', '73B9B79B-BDB8-479F-8DB1-4677DA98F85F', 2, 'Imported', 'Imported', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID ae1eeb3a-87ab-4f74-9f8d-c56f1098d625 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ae1eeb3a-87ab-4f74-9f8d-c56f1098d625', '73B9B79B-BDB8-479F-8DB1-4677DA98F85F', 3, 'Manual', 'Manual', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 9aef775a-feff-421f-aaa8-9e8de6fc3088 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9aef775a-feff-421f-aaa8-9e8de6fc3088', '73B9B79B-BDB8-479F-8DB1-4677DA98F85F', 4, 'Timer', 'Timer', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 73B9B79B-BDB8-479F-8DB1-4677DA98F85F */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='73B9B79B-BDB8-479F-8DB1-4677DA98F85F';

/* SQL text to insert entity field value with ID 1173df07-4c7e-4f5f-b2ec-a19b473dab36 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1173df07-4c7e-4f5f-b2ec-a19b473dab36', '8AD0134D-2F51-4FDD-BAF2-4FE7CB8F8F82', 1, 'Assisted', 'Assisted', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID ff4fb037-6572-48c2-b88f-8676a49c874a */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ff4fb037-6572-48c2-b88f-8676a49c874a', '8AD0134D-2F51-4FDD-BAF2-4FE7CB8F8F82', 2, 'Executed', 'Executed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID ee2ae9d4-43fd-49cd-a68e-be20dbf0c6ac */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ee2ae9d4-43fd-49cd-a68e-be20dbf0c6ac', '8AD0134D-2F51-4FDD-BAF2-4FE7CB8F8F82', 3, 'Planned', 'Planned', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID f7767307-fd6c-4f40-b083-c8f1ec1b56ff */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f7767307-fd6c-4f40-b083-c8f1ec1b56ff', '8AD0134D-2F51-4FDD-BAF2-4FE7CB8F8F82', 4, 'Reviewed', 'Reviewed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID d15da97e-9afb-428c-83ce-d8f954b7175c */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('d15da97e-9afb-428c-83ce-d8f954b7175c', '8AD0134D-2F51-4FDD-BAF2-4FE7CB8F8F82', 5, 'Triaged', 'Triaged', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 8AD0134D-2F51-4FDD-BAF2-4FE7CB8F8F82 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='8AD0134D-2F51-4FDD-BAF2-4FE7CB8F8F82';

/* SQL text to insert entity field value with ID 7c83f162-21a1-441f-b322-3a474c9491bd */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('7c83f162-21a1-441f-b322-3a474c9491bd', 'DCAFD61E-A2F4-4D42-819C-F37B9638CF35', 1, 'Approved', 'Approved', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 82ae3360-a5b5-4485-9410-ca14f79afa44 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('82ae3360-a5b5-4485-9410-ca14f79afa44', 'DCAFD61E-A2F4-4D42-819C-F37B9638CF35', 2, 'Draft', 'Draft', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID a75aa577-37bc-4b42-90e7-ed43ff91bc78 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a75aa577-37bc-4b42-90e7-ed43ff91bc78', 'DCAFD61E-A2F4-4D42-819C-F37B9638CF35', 3, 'Rejected', 'Rejected', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 6476977a-f0dd-450c-9e82-91cf26d60db4 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6476977a-f0dd-450c-9e82-91cf26d60db4', 'DCAFD61E-A2F4-4D42-819C-F37B9638CF35', 4, 'Submitted', 'Submitted', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID DCAFD61E-A2F4-4D42-819C-F37B9638CF35 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='DCAFD61E-A2F4-4D42-819C-F37B9638CF35';

/* SQL text to insert entity field value with ID 5f1ccd70-1333-4753-b13f-70821662790b */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('5f1ccd70-1333-4753-b13f-70821662790b', '062734FE-AC90-42BB-B3BA-09FDA28A517E', 1, 'Approved', 'Approved', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 942cddf9-f28e-4ad6-9a33-540e15a53f47 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('942cddf9-f28e-4ad6-9a33-540e15a53f47', '062734FE-AC90-42BB-B3BA-09FDA28A517E', 2, 'Canceled', 'Canceled', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 2771390d-69d9-4120-93bd-7cbdb2c5ed29 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('2771390d-69d9-4120-93bd-7cbdb2c5ed29', '062734FE-AC90-42BB-B3BA-09FDA28A517E', 3, 'Pending', 'Pending', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 3dbff4a8-79d5-49a8-bce4-ae0e191d4096 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('3dbff4a8-79d5-49a8-bce4-ae0e191d4096', '062734FE-AC90-42BB-B3BA-09FDA28A517E', 4, 'Rejected', 'Rejected', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 062734FE-AC90-42BB-B3BA-09FDA28A517E */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='062734FE-AC90-42BB-B3BA-09FDA28A517E';

/* SQL text to insert entity field value with ID ea3d3016-ebd1-4e4c-94ed-ef996514230d */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ea3d3016-ebd1-4e4c-94ed-ef996514230d', '2EA93151-5257-4972-BE84-6CB41D3541D8', 1, 'ExpenseReport', 'ExpenseReport', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID c731a73b-c7e7-4a38-a979-01550b305872 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c731a73b-c7e7-4a38-a979-01550b305872', '2EA93151-5257-4972-BE84-6CB41D3541D8', 2, 'Invoice', 'Invoice', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 308ce7c0-5108-4ffe-9ab2-25a7ceaf2e51 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('308ce7c0-5108-4ffe-9ab2-25a7ceaf2e51', '2EA93151-5257-4972-BE84-6CB41D3541D8', 3, 'PayrollBatch', 'PayrollBatch', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 422d0a4b-6e93-42c3-ac01-73aed562c6b0 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('422d0a4b-6e93-42c3-ac01-73aed562c6b0', '2EA93151-5257-4972-BE84-6CB41D3541D8', 4, 'Related', 'Related', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 2EA93151-5257-4972-BE84-6CB41D3541D8 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='2EA93151-5257-4972-BE84-6CB41D3541D8';

/* SQL text to insert entity field value with ID 32792ca1-bb61-4bc1-b627-fde08bcde748 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('32792ca1-bb61-4bc1-b627-fde08bcde748', '3D44D5B8-B4FE-4929-8980-7967F79E8E7D', 1, 'Commit', 'Commit', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b08ccc00-43d2-4582-bcbd-5ab274d045ba */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b08ccc00-43d2-4582-bcbd-5ab274d045ba', '3D44D5B8-B4FE-4929-8980-7967F79E8E7D', 2, 'InvoiceLine', 'InvoiceLine', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 6e6946ea-ec62-4a62-92be-9eb7f6744c6c */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6e6946ea-ec62-4a62-92be-9eb7f6744c6c', '3D44D5B8-B4FE-4929-8980-7967F79E8E7D', 3, 'JournalEntryLine', 'JournalEntryLine', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 9ac28ad0-0824-4326-a764-25e4448b75fb */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9ac28ad0-0824-4326-a764-25e4448b75fb', '3D44D5B8-B4FE-4929-8980-7967F79E8E7D', 4, 'PullRequest', 'PullRequest', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 1fbac371-f9d5-4389-9015-23e68e667f9f */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('1fbac371-f9d5-4389-9015-23e68e667f9f', '3D44D5B8-B4FE-4929-8980-7967F79E8E7D', 5, 'Related', 'Related', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 3D44D5B8-B4FE-4929-8980-7967F79E8E7D */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='3D44D5B8-B4FE-4929-8980-7967F79E8E7D';

/* SQL text to insert entity field value with ID 13852a60-9a05-43c8-912c-d6807380368d */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('13852a60-9a05-43c8-912c-d6807380368d', '8A2BE0BF-64C1-4429-A821-8C8213FDC3C5', 1, 'BiWeekly', 'BiWeekly', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID adb4881e-62b3-4577-9b7b-f95d822b7d61 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('adb4881e-62b3-4577-9b7b-f95d822b7d61', '8A2BE0BF-64C1-4429-A821-8C8213FDC3C5', 2, 'Monthly', 'Monthly', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 15f9974a-0b7a-4615-aa45-708e271149b7 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('15f9974a-0b7a-4615-aa45-708e271149b7', '8A2BE0BF-64C1-4429-A821-8C8213FDC3C5', 3, 'SemiMonthly', 'SemiMonthly', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 6edf9d40-3007-43c4-a3b5-a82b056ad0f8 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6edf9d40-3007-43c4-a3b5-a82b056ad0f8', '8A2BE0BF-64C1-4429-A821-8C8213FDC3C5', 4, 'Weekly', 'Weekly', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 8A2BE0BF-64C1-4429-A821-8C8213FDC3C5 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='8A2BE0BF-64C1-4429-A821-8C8213FDC3C5';

/* SQL text to insert entity field value with ID 73eb2c1e-7e5d-4133-935e-6ed0a1cde9d8 */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('73eb2c1e-7e5d-4133-935e-6ed0a1cde9d8', 'E423A509-1F64-48D0-A6C9-E40FCAABBC39', 1, 'Monday', 'Monday', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID f3147050-847b-4245-abb8-977e64bf72bf */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f3147050-847b-4245-abb8-977e64bf72bf', 'E423A509-1F64-48D0-A6C9-E40FCAABBC39', 2, 'Saturday', 'Saturday', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 110a599e-d733-403d-9095-a99030eeb2bf */
INSERT INTO [${mjSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('110a599e-d733-403d-9095-a99030eeb2bf', 'E423A509-1F64-48D0-A6C9-E40FCAABBC39', 3, 'Sunday', 'Sunday', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID E423A509-1F64-48D0-A6C9-E40FCAABBC39 */
UPDATE [${mjSchema}].[EntityField] SET ValueListType='List' WHERE ID='E423A509-1F64-48D0-A6C9-E40FCAABBC39';

/* Deterministic search-flag hygiene — clear AllowUserSearchAPI */

         UPDATE [${mjSchema}].[Entity]
         SET [AllowUserSearchAPI] = 0
         WHERE [ID] IN (
            SELECT e.[ID]
            FROM [${mjSchema}].[Entity] e
            WHERE e.[AllowUserSearchAPI] = 1
              AND e.[AutoUpdateAllowUserSearchAPI] = 1
              AND e.[VirtualEntity] = 0
              AND ISNULL(e.[FullTextSearchEnabled], 0) = 0
              AND e.[SchemaName] NOT IN ('${mjSchema}','__mj_BizAppsCommon','__mj_BizAppsContactCenter','__mj_BizAppsIssues','sys')
              AND NOT EXISTS (
               SELECT 1 FROM [${mjSchema}].[EntityField] f2
               WHERE f2.[EntityID] = e.[ID]
                 AND f2.[IncludeInUserSearchAPI] = 1
            )
         );


/* Create Entity Relationship: MJ: AI Agent Runs -> MJ_BizApps_Tasks: Task Agent Runs (One To Many via AIAgentRunID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '3f24065e-e1be-4b26-bb07-3efc77223db7' OR ([EntityID] = '5190AF93-4C39-4429-BDAA-0AEB492A0256' AND [RelatedEntityID] = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND [RelatedEntityJoinField] = 'AIAgentRunID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('3f24065e-e1be-4b26-bb07-3efc77223db7', '5190AF93-4C39-4429-BDAA-0AEB492A0256', '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', 'AIAgentRunID', 'One To Many', 1, 1, 17, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ: Entities -> MJ_BizApps_Tasks: Timesheet Links (One To Many via EntityID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '6d091fc6-c7bf-4b57-ba56-672af385e6c4' OR ([EntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [RelatedEntityID] = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND [RelatedEntityJoinField] = 'EntityID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('6d091fc6-c7bf-4b57-ba56-672af385e6c4', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'D594B91D-4DE0-4D20-8D71-21F041FA505D', 'EntityID', 'One To Many', 1, 1, 95, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Entities -> MJ_BizApps_Tasks: Task Time Entry Links (One To Many via EntityID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '51dfd298-ab46-4c16-9e74-11d1aa2cc82f' OR ([EntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [RelatedEntityID] = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND [RelatedEntityJoinField] = 'EntityID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('51dfd298-ab46-4c16-9e74-11d1aa2cc82f', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '5A25B67B-D67D-453F-8340-94BF69CF8CEE', 'EntityID', 'One To Many', 1, 1, 96, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Entities -> MJ_BizApps_Tasks: Timesheet Schedules (One To Many via ScopeEntityID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'bcefa591-b4a1-4847-aa18-ab4e80eda6d4' OR ([EntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [RelatedEntityID] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND [RelatedEntityJoinField] = 'ScopeEntityID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('bcefa591-b4a1-4847-aa18-ab4e80eda6d4', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '6A27830F-A203-4D3E-8ADF-B1085E1F908C', 'ScopeEntityID', 'One To Many', 1, 1, 97, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ: Entities -> MJ_BizApps_Tasks: Time Approvers (One To Many via ScopeEntityID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'ba097ef1-7e19-4730-9ee3-d804ad150177' OR ([EntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [RelatedEntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND [RelatedEntityJoinField] = 'ScopeEntityID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('ba097ef1-7e19-4730-9ee3-d804ad150177', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', 'ScopeEntityID', 'One To Many', 1, 1, 98, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ: Users -> MJ_BizApps_Tasks: Timesheets (One To Many via SubmittedByUserID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '33a3fa98-2b24-4f59-a28c-5e266cfd94bd' OR ([EntityID] = 'E1238F34-2837-EF11-86D4-6045BDEE16E6' AND [RelatedEntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND [RelatedEntityJoinField] = 'SubmittedByUserID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('33a3fa98-2b24-4f59-a28c-5e266cfd94bd', 'E1238F34-2837-EF11-86D4-6045BDEE16E6', 'ED90EE09-0D39-4298-93DC-77C057FCE97A', 'SubmittedByUserID', 'One To Many', 1, 1, 129, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Timesheets -> MJ_BizApps_Tasks: Timesheet Links (One To Many via TimesheetID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'c898e0a1-c95d-4af4-bbc0-9404c626d5fe' OR ([EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND [RelatedEntityID] = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND [RelatedEntityJoinField] = 'TimesheetID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('c898e0a1-c95d-4af4-bbc0-9404c626d5fe', 'ED90EE09-0D39-4298-93DC-77C057FCE97A', 'D594B91D-4DE0-4D20-8D71-21F041FA505D', 'TimesheetID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Timesheets -> MJ_BizApps_Tasks: Timesheet Approvals (One To Many via TimesheetID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'd6cc7803-b063-482e-9237-cb1a817af26c' OR ([EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND [RelatedEntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND [RelatedEntityJoinField] = 'TimesheetID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('d6cc7803-b063-482e-9237-cb1a817af26c', 'ED90EE09-0D39-4298-93DC-77C057FCE97A', '02C38B1A-6987-463D-8B6B-4C86E0887D42', 'TimesheetID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Timesheets -> MJ_BizApps_Tasks: Task Time Entries (One To Many via TimesheetID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '94ed04ef-6b63-4a47-b0ac-922e2c03acb7' OR ([EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND [RelatedEntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND [RelatedEntityJoinField] = 'TimesheetID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('94ed04ef-6b63-4a47-b0ac-922e2c03acb7', 'ED90EE09-0D39-4298-93DC-77C057FCE97A', 'EA40801A-DF1B-443A-B0D3-EA0415645603', 'TimesheetID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Task Timers (One To Many via PersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'a1656f17-b4f7-4e9d-a07b-8a2f17a47457' OR ([EntityID] = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND [RelatedEntityID] = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND [RelatedEntityJoinField] = 'PersonID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('a1656f17-b4f7-4e9d-a07b-8a2f17a47457', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', 'PersonID', 'One To Many', 1, 1, 17, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Timesheet Approvals (One To Many via DecidedByPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '93ad10c2-6775-411b-85d4-f3327194a94f' OR ([EntityID] = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND [RelatedEntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND [RelatedEntityJoinField] = 'DecidedByPersonID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('93ad10c2-6775-411b-85d4-f3327194a94f', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '02C38B1A-6987-463D-8B6B-4C86E0887D42', 'DecidedByPersonID', 'One To Many', 1, 1, 18, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Timesheets (One To Many via PersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '120b45a0-65e5-4282-a943-fe69dd97e4ef' OR ([EntityID] = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND [RelatedEntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND [RelatedEntityJoinField] = 'PersonID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('120b45a0-65e5-4282-a943-fe69dd97e4ef', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'ED90EE09-0D39-4298-93DC-77C057FCE97A', 'PersonID', 'One To Many', 1, 1, 19, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Timesheet Schedules (One To Many via PersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '10f6be5d-7b1c-48a5-b62c-614d04b3d67a' OR ([EntityID] = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND [RelatedEntityID] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND [RelatedEntityJoinField] = 'PersonID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('10f6be5d-7b1c-48a5-b62c-614d04b3d67a', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', '6A27830F-A203-4D3E-8ADF-B1085E1F908C', 'PersonID', 'One To Many', 1, 1, 20, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Task Time Entries (One To Many via PersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'e27e7264-14ea-45bd-a88e-b4960ca82d51' OR ([EntityID] = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND [RelatedEntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND [RelatedEntityJoinField] = 'PersonID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('e27e7264-14ea-45bd-a88e-b4960ca82d51', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'EA40801A-DF1B-443A-B0D3-EA0415645603', 'PersonID', 'One To Many', 1, 1, 21, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Time Approvers (One To Many via ApproverPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '859cdff4-cbcf-4e6f-b999-03d4c1f9e3db' OR ([EntityID] = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND [RelatedEntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND [RelatedEntityJoinField] = 'ApproverPersonID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('859cdff4-cbcf-4e6f-b999-03d4c1f9e3db', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', 'ApproverPersonID', 'One To Many', 1, 1, 22, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Common: People -> MJ_BizApps_Tasks: Time Approvers (One To Many via WorkerPersonID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '4fa8726c-45c6-4a38-8bca-6ccf383340a0' OR ([EntityID] = '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F' AND [RelatedEntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND [RelatedEntityJoinField] = 'WorkerPersonID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('4fa8726c-45c6-4a38-8bca-6ccf383340a0', '7A94ADA9-7880-4FAE-97D8-DB0E934C3F5F', 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', 'WorkerPersonID', 'One To Many', 1, 1, 23, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Task Time Entries -> MJ_BizApps_Tasks: Task Time Entry Links (One To Many via TaskTimeEntryID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'c2551a0b-b873-4efb-ba8c-ab7bbc3f58ef' OR ([EntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND [RelatedEntityID] = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND [RelatedEntityJoinField] = 'TaskTimeEntryID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('c2551a0b-b873-4efb-ba8c-ab7bbc3f58ef', 'EA40801A-DF1B-443A-B0D3-EA0415645603', '5A25B67B-D67D-453F-8340-94BF69CF8CEE', 'TaskTimeEntryID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Task Agent Runs (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '3b77b4dd-3c81-481a-a817-c425146af146' OR ([EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND [RelatedEntityID] = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND [RelatedEntityJoinField] = 'TaskID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('3b77b4dd-3c81-481a-a817-c425146af146', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', 'TaskID', 'One To Many', 1, 1, 12, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Task Timers (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '6b6f417c-7096-4932-b036-009850b541ba' OR ([EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND [RelatedEntityID] = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND [RelatedEntityJoinField] = 'TaskID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('6b6f417c-7096-4932-b036-009850b541ba', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', 'TaskID', 'One To Many', 1, 1, 13, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Timesheet Approvals (One To Many via ScopeTaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'a41b9caf-18f9-4ea6-95b0-c98c555c6d83' OR ([EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND [RelatedEntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND [RelatedEntityJoinField] = 'ScopeTaskID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('a41b9caf-18f9-4ea6-95b0-c98c555c6d83', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '02C38B1A-6987-463D-8B6B-4C86E0887D42', 'ScopeTaskID', 'One To Many', 1, 1, 14, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Timesheet Approvals (One To Many via ApprovalTaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '66644f1a-f908-4241-9e31-5f55928a5c54' OR ([EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND [RelatedEntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND [RelatedEntityJoinField] = 'ApprovalTaskID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('66644f1a-f908-4241-9e31-5f55928a5c54', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', '02C38B1A-6987-463D-8B6B-4C86E0887D42', 'ApprovalTaskID', 'One To Many', 1, 1, 15, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Task Time Entries (One To Many via TaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = 'b25b6bb5-0b36-4ee4-a80c-8d7d56adf0ef' OR ([EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND [RelatedEntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND [RelatedEntityJoinField] = 'TaskID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('b25b6bb5-0b36-4ee4-a80c-8d7d56adf0ef', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'EA40801A-DF1B-443A-B0D3-EA0415645603', 'TaskID', 'One To Many', 1, 1, 16, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: MJ_BizApps_Tasks: Tasks -> MJ_BizApps_Tasks: Time Approvers (One To Many via ScopeTaskID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[EntityRelationship] WHERE [ID] = '7929bd74-68ca-4723-9370-28f853808036' OR ([EntityID] = 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466' AND [RelatedEntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND [RelatedEntityJoinField] = 'ScopeTaskID')
   )
   BEGIN
      INSERT INTO [${mjSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('7929bd74-68ca-4723-9370-28f853808036', 'B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', 'ScopeTaskID', 'One To Many', 1, 1, 17, GETUTCDATE(), GETUTCDATE())
   END;

/* SQL text to sync schema info from database schemas */
EXEC [${mjSchema}].[spUpdateSchemaInfoFromDatabase] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* Index for Foreign Keys for TaskAgentRun */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Agent Runs
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskID in table TaskAgentRun
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskAgentRun_TaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskAgentRun]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskAgentRun_TaskID ON [${flyway:defaultSchema}].[TaskAgentRun] ([TaskID]);

-- Index for foreign key AIAgentRunID in table TaskAgentRun
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskAgentRun_AIAgentRunID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskAgentRun]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskAgentRun_AIAgentRunID ON [${flyway:defaultSchema}].[TaskAgentRun] ([AIAgentRunID]);

/* SQL text to update entity field related entity name field map for entity field ID 16554986-6995-435A-A9F6-62C837D5FD72 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='16554986-6995-435A-A9F6-62C837D5FD72', @RelatedEntityNameFieldMap='Task';

/* SQL text to update entity field related entity name field map for entity field ID AB51A173-82C1-4F42-86A6-8CC30CCD8048 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='AB51A173-82C1-4F42-86A6-8CC30CCD8048', @RelatedEntityNameFieldMap='AIAgentRun';

/* Base View SQL for MJ_BizApps_Tasks: Task Agent Runs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Agent Runs
-- Item: vwTaskAgentRuns
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Agent Runs
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskAgentRun
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskAgentRuns]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskAgentRuns];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskAgentRuns]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    MJAIAgentRun_AIAgentRunID.[RunName] AS [AIAgentRun]
FROM
    [${flyway:defaultSchema}].[TaskAgentRun] AS t
INNER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
INNER JOIN
    [${mjSchema}].[AIAgentRun] AS MJAIAgentRun_AIAgentRunID
  ON
    [t].[AIAgentRunID] = MJAIAgentRun_AIAgentRunID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskAgentRuns] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Agent Runs */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Agent Runs
-- Item: Permissions for vwTaskAgentRuns
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskAgentRuns] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskAgentRun]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskAgentRun];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskAgentRun]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @AIAgentRunID uniqueidentifier,
    @Role nvarchar(30) = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskAgentRun]
            (
                [ID],
                [TaskID],
                [AIAgentRunID],
                [Role],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TaskID,
                @AIAgentRunID,
                ISNULL(@Role, 'Executed'),
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskAgentRun]
            (
                [TaskID],
                [AIAgentRunID],
                [Role],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TaskID,
                @AIAgentRunID,
                ISNULL(@Role, 'Executed'),
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskAgentRuns] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskAgentRun] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Agent Runs */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskAgentRun] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskAgentRun]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskAgentRun];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskAgentRun]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier = NULL,
    @AIAgentRunID uniqueidentifier = NULL,
    @Role nvarchar(30) = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskAgentRun]
    SET
        [TaskID] = ISNULL(@TaskID, [TaskID]),
        [AIAgentRunID] = ISNULL(@AIAgentRunID, [AIAgentRunID]),
        [Role] = ISNULL(@Role, [Role]),
        [Notes] = CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, [Notes]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskAgentRuns] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskAgentRuns]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskAgentRun] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskAgentRun table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskAgentRun]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskAgentRun];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskAgentRun
ON [${flyway:defaultSchema}].[TaskAgentRun]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskAgentRun]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskAgentRun] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Agent Runs */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskAgentRun] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskAgentRun]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskAgentRun];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskAgentRun]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskAgentRun]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskAgentRun] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Agent Runs */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskAgentRun] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for TaskTimeEntry */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Time Entries
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskID in table TaskTimeEntry
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTimeEntry_TaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTimeEntry]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTimeEntry_TaskID ON [${flyway:defaultSchema}].[TaskTimeEntry] ([TaskID]);

-- Index for foreign key PersonID in table TaskTimeEntry
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTimeEntry_PersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTimeEntry]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTimeEntry_PersonID ON [${flyway:defaultSchema}].[TaskTimeEntry] ([PersonID]);

-- Index for foreign key TimesheetID in table TaskTimeEntry
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTimeEntry_TimesheetID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTimeEntry]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTimeEntry_TimesheetID ON [${flyway:defaultSchema}].[TaskTimeEntry] ([TimesheetID]);

/* SQL text to update entity field related entity name field map for entity field ID 91493F5A-6B8C-48B4-82DC-4455A88797A8 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='91493F5A-6B8C-48B4-82DC-4455A88797A8', @RelatedEntityNameFieldMap='Task';

/* Index for Foreign Keys for TaskTimeEntryLink */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Time Entry Links
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskTimeEntryID in table TaskTimeEntryLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTimeEntryLink_TaskTimeEntryID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTimeEntryLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTimeEntryLink_TaskTimeEntryID ON [${flyway:defaultSchema}].[TaskTimeEntryLink] ([TaskTimeEntryID]);

-- Index for foreign key EntityID in table TaskTimeEntryLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTimeEntryLink_EntityID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTimeEntryLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTimeEntryLink_EntityID ON [${flyway:defaultSchema}].[TaskTimeEntryLink] ([EntityID]);

/* SQL text to update entity field related entity name field map for entity field ID 023BF220-43DA-42B1-B24D-331243BDB452 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='023BF220-43DA-42B1-B24D-331243BDB452', @RelatedEntityNameFieldMap='Entity';

/* Index for Foreign Keys for TaskTimer */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Timers
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TaskID in table TaskTimer
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTimer_TaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTimer]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTimer_TaskID ON [${flyway:defaultSchema}].[TaskTimer] ([TaskID]);

-- Index for foreign key PersonID in table TaskTimer
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskTimer_PersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskTimer]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskTimer_PersonID ON [${flyway:defaultSchema}].[TaskTimer] ([PersonID]);

/* SQL text to update entity field related entity name field map for entity field ID C331DDD2-06CC-4DEA-833F-BDAEAFC80DB8 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='C331DDD2-06CC-4DEA-833F-BDAEAFC80DB8', @RelatedEntityNameFieldMap='Task';

/* Index for Foreign Keys for TaskType */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Types
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key OnAssignActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnAssignActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnAssignActionID ON [${flyway:defaultSchema}].[TaskType] ([OnAssignActionID]);

-- Index for foreign key OnCompleteActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnCompleteActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnCompleteActionID ON [${flyway:defaultSchema}].[TaskType] ([OnCompleteActionID]);

-- Index for foreign key OnOverdueActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnOverdueActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnOverdueActionID ON [${flyway:defaultSchema}].[TaskType] ([OnOverdueActionID]);

-- Index for foreign key OnPercentChangeActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnPercentChangeActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnPercentChangeActionID ON [${flyway:defaultSchema}].[TaskType] ([OnPercentChangeActionID]);

-- Index for foreign key OnRejectActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnRejectActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnRejectActionID ON [${flyway:defaultSchema}].[TaskType] ([OnRejectActionID]);

-- Index for foreign key OnCancelActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnCancelActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnCancelActionID ON [${flyway:defaultSchema}].[TaskType] ([OnCancelActionID]);

-- Index for foreign key OnCreateActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnCreateActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnCreateActionID ON [${flyway:defaultSchema}].[TaskType] ([OnCreateActionID]);

-- Index for foreign key OnStatusChangeActionID in table TaskType
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TaskType_OnStatusChangeActionID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TaskType]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TaskType_OnStatusChangeActionID ON [${flyway:defaultSchema}].[TaskType] ([OnStatusChangeActionID]);

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
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskType
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskTypes]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskTypes];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskTypes]
AS
SELECT
    t.*,
    MJAction_OnAssignActionID.[Name] AS [OnAssignAction],
    MJAction_OnCompleteActionID.[Name] AS [OnCompleteAction],
    MJAction_OnOverdueActionID.[Name] AS [OnOverdueAction],
    MJAction_OnPercentChangeActionID.[Name] AS [OnPercentChangeAction],
    MJAction_OnRejectActionID.[Name] AS [OnRejectAction],
    MJAction_OnCancelActionID.[Name] AS [OnCancelAction],
    MJAction_OnCreateActionID.[Name] AS [OnCreateAction],
    MJAction_OnStatusChangeActionID.[Name] AS [OnStatusChangeAction]
FROM
    [${flyway:defaultSchema}].[TaskType] AS t
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnAssignActionID
  ON
    [t].[OnAssignActionID] = MJAction_OnAssignActionID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnCompleteActionID
  ON
    [t].[OnCompleteActionID] = MJAction_OnCompleteActionID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnOverdueActionID
  ON
    [t].[OnOverdueActionID] = MJAction_OnOverdueActionID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnPercentChangeActionID
  ON
    [t].[OnPercentChangeActionID] = MJAction_OnPercentChangeActionID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnRejectActionID
  ON
    [t].[OnRejectActionID] = MJAction_OnRejectActionID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnCancelActionID
  ON
    [t].[OnCancelActionID] = MJAction_OnCancelActionID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnCreateActionID
  ON
    [t].[OnCreateActionID] = MJAction_OnCreateActionID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Action] AS MJAction_OnStatusChangeActionID
  ON
    [t].[OnStatusChangeActionID] = MJAction_OnStatusChangeActionID.[ID]
GO
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypes] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypes] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypes] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Types */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Types
-- Item: Permissions for vwTaskTypes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypes] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypes] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTaskTypes] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTypes] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskType]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(100),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @IconClass_Clear bit = 0,
    @IconClass nvarchar(100) = NULL,
    @DefaultPriority nvarchar(20) = NULL,
    @OnAssignActionID_Clear bit = 0,
    @OnAssignActionID uniqueidentifier = NULL,
    @OnCompleteActionID_Clear bit = 0,
    @OnCompleteActionID uniqueidentifier = NULL,
    @OnOverdueActionID_Clear bit = 0,
    @OnOverdueActionID uniqueidentifier = NULL,
    @OnPercentChangeActionID_Clear bit = 0,
    @OnPercentChangeActionID uniqueidentifier = NULL,
    @IsActive bit = NULL,
    @OnRejectActionID_Clear bit = 0,
    @OnRejectActionID uniqueidentifier = NULL,
    @OnCancelActionID_Clear bit = 0,
    @OnCancelActionID uniqueidentifier = NULL,
    @Code nvarchar(50),
    @OnCreateActionID_Clear bit = 0,
    @OnCreateActionID uniqueidentifier = NULL,
    @OnStatusChangeActionID_Clear bit = 0,
    @OnStatusChangeActionID uniqueidentifier = NULL,
    @IsApproval bit = NULL,
    @RequiresAssigneeDecision bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskType]
            (
                [ID],
                [Name],
                [Description],
                [IconClass],
                [DefaultPriority],
                [OnAssignActionID],
                [OnCompleteActionID],
                [OnOverdueActionID],
                [OnPercentChangeActionID],
                [IsActive],
                [OnRejectActionID],
                [OnCancelActionID],
                [Code],
                [OnCreateActionID],
                [OnStatusChangeActionID],
                [IsApproval],
                [RequiresAssigneeDecision]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, NULL) END,
                ISNULL(@DefaultPriority, 'Medium'),
                CASE WHEN @OnAssignActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnAssignActionID, NULL) END,
                CASE WHEN @OnCompleteActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCompleteActionID, NULL) END,
                CASE WHEN @OnOverdueActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnOverdueActionID, NULL) END,
                CASE WHEN @OnPercentChangeActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnPercentChangeActionID, NULL) END,
                ISNULL(@IsActive, 1),
                CASE WHEN @OnRejectActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnRejectActionID, NULL) END,
                CASE WHEN @OnCancelActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCancelActionID, NULL) END,
                @Code,
                CASE WHEN @OnCreateActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCreateActionID, NULL) END,
                CASE WHEN @OnStatusChangeActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnStatusChangeActionID, NULL) END,
                ISNULL(@IsApproval, 0),
                ISNULL(@RequiresAssigneeDecision, 0)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskType]
            (
                [Name],
                [Description],
                [IconClass],
                [DefaultPriority],
                [OnAssignActionID],
                [OnCompleteActionID],
                [OnOverdueActionID],
                [OnPercentChangeActionID],
                [IsActive],
                [OnRejectActionID],
                [OnCancelActionID],
                [Code],
                [OnCreateActionID],
                [OnStatusChangeActionID],
                [IsApproval],
                [RequiresAssigneeDecision]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, NULL) END,
                ISNULL(@DefaultPriority, 'Medium'),
                CASE WHEN @OnAssignActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnAssignActionID, NULL) END,
                CASE WHEN @OnCompleteActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCompleteActionID, NULL) END,
                CASE WHEN @OnOverdueActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnOverdueActionID, NULL) END,
                CASE WHEN @OnPercentChangeActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnPercentChangeActionID, NULL) END,
                ISNULL(@IsActive, 1),
                CASE WHEN @OnRejectActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnRejectActionID, NULL) END,
                CASE WHEN @OnCancelActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCancelActionID, NULL) END,
                @Code,
                CASE WHEN @OnCreateActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCreateActionID, NULL) END,
                CASE WHEN @OnStatusChangeActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnStatusChangeActionID, NULL) END,
                ISNULL(@IsApproval, 0),
                ISNULL(@RequiresAssigneeDecision, 0)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskTypes] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskType] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskType] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskType] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Types */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskType] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskType] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskType] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskType]
    @ID uniqueidentifier,
    @Name nvarchar(100) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @IconClass_Clear bit = 0,
    @IconClass nvarchar(100) = NULL,
    @DefaultPriority nvarchar(20) = NULL,
    @OnAssignActionID_Clear bit = 0,
    @OnAssignActionID uniqueidentifier = NULL,
    @OnCompleteActionID_Clear bit = 0,
    @OnCompleteActionID uniqueidentifier = NULL,
    @OnOverdueActionID_Clear bit = 0,
    @OnOverdueActionID uniqueidentifier = NULL,
    @OnPercentChangeActionID_Clear bit = 0,
    @OnPercentChangeActionID uniqueidentifier = NULL,
    @IsActive bit = NULL,
    @OnRejectActionID_Clear bit = 0,
    @OnRejectActionID uniqueidentifier = NULL,
    @OnCancelActionID_Clear bit = 0,
    @OnCancelActionID uniqueidentifier = NULL,
    @Code nvarchar(50) = NULL,
    @OnCreateActionID_Clear bit = 0,
    @OnCreateActionID uniqueidentifier = NULL,
    @OnStatusChangeActionID_Clear bit = 0,
    @OnStatusChangeActionID uniqueidentifier = NULL,
    @IsApproval bit = NULL,
    @RequiresAssigneeDecision bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskType]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [IconClass] = CASE WHEN @IconClass_Clear = 1 THEN NULL ELSE ISNULL(@IconClass, [IconClass]) END,
        [DefaultPriority] = ISNULL(@DefaultPriority, [DefaultPriority]),
        [OnAssignActionID] = CASE WHEN @OnAssignActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnAssignActionID, [OnAssignActionID]) END,
        [OnCompleteActionID] = CASE WHEN @OnCompleteActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCompleteActionID, [OnCompleteActionID]) END,
        [OnOverdueActionID] = CASE WHEN @OnOverdueActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnOverdueActionID, [OnOverdueActionID]) END,
        [OnPercentChangeActionID] = CASE WHEN @OnPercentChangeActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnPercentChangeActionID, [OnPercentChangeActionID]) END,
        [IsActive] = ISNULL(@IsActive, [IsActive]),
        [OnRejectActionID] = CASE WHEN @OnRejectActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnRejectActionID, [OnRejectActionID]) END,
        [OnCancelActionID] = CASE WHEN @OnCancelActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCancelActionID, [OnCancelActionID]) END,
        [Code] = ISNULL(@Code, [Code]),
        [OnCreateActionID] = CASE WHEN @OnCreateActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnCreateActionID, [OnCreateActionID]) END,
        [OnStatusChangeActionID] = CASE WHEN @OnStatusChangeActionID_Clear = 1 THEN NULL ELSE ISNULL(@OnStatusChangeActionID, [OnStatusChangeActionID]) END,
        [IsApproval] = ISNULL(@IsApproval, [IsApproval]),
        [RequiresAssigneeDecision] = ISNULL(@RequiresAssigneeDecision, [RequiresAssigneeDecision])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskTypes] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskTypes]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskType] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskType] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskType] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskType table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskType]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskType];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskType
ON [${flyway:defaultSchema}].[TaskType]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskType]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskType] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Types */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskType] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskType] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskType] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskType]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskType];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskType]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskType]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskType] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskType] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskType] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Types */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskType] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskType] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskType] TO [cdp_Developer], [cdp_Integration];

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
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskTimeEntryLink
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskTimeEntryLinks]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskTimeEntryLinks];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskTimeEntryLinks]
AS
SELECT
    t.*,
    MJEntity_EntityID.[Name] AS [Entity]
FROM
    [${flyway:defaultSchema}].[TaskTimeEntryLink] AS t
INNER JOIN
    [${mjSchema}].[Entity] AS MJEntity_EntityID
  ON
    [t].[EntityID] = MJEntity_EntityID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTimeEntryLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Time Entry Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Time Entry Links
-- Item: Permissions for vwTaskTimeEntryLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTimeEntryLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskTimeEntryLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTimeEntryLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTimeEntryLink]
    @ID uniqueidentifier = NULL,
    @TaskTimeEntryID uniqueidentifier,
    @EntityID uniqueidentifier,
    @RecordID nvarchar(450),
    @Relationship nvarchar(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskTimeEntryLink]
            (
                [ID],
                [TaskTimeEntryID],
                [EntityID],
                [RecordID],
                [Relationship]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TaskTimeEntryID,
                @EntityID,
                @RecordID,
                ISNULL(@Relationship, 'Related')
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskTimeEntryLink]
            (
                [TaskTimeEntryID],
                [EntityID],
                [RecordID],
                [Relationship]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TaskTimeEntryID,
                @EntityID,
                @RecordID,
                ISNULL(@Relationship, 'Related')
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskTimeEntryLinks] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTimeEntryLink] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Time Entry Links */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTimeEntryLink] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskTimeEntryLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTimeEntryLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTimeEntryLink]
    @ID uniqueidentifier,
    @TaskTimeEntryID uniqueidentifier = NULL,
    @EntityID uniqueidentifier = NULL,
    @RecordID nvarchar(450) = NULL,
    @Relationship nvarchar(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTimeEntryLink]
    SET
        [TaskTimeEntryID] = ISNULL(@TaskTimeEntryID, [TaskTimeEntryID]),
        [EntityID] = ISNULL(@EntityID, [EntityID]),
        [RecordID] = ISNULL(@RecordID, [RecordID]),
        [Relationship] = ISNULL(@Relationship, [Relationship])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskTimeEntryLinks] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskTimeEntryLinks]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTimeEntryLink] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTimeEntryLink table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskTimeEntryLink]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskTimeEntryLink];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskTimeEntryLink
ON [${flyway:defaultSchema}].[TaskTimeEntryLink]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTimeEntryLink]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskTimeEntryLink] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Time Entry Links */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTimeEntryLink] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskTimeEntryLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTimeEntryLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTimeEntryLink]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskTimeEntryLink]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTimeEntryLink] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Time Entry Links */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTimeEntryLink] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID 5CC9964F-5CA5-4BE3-9237-9901052413B3 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='5CC9964F-5CA5-4BE3-9237-9901052413B3', @RelatedEntityNameFieldMap='Person';

/* SQL text to update entity field related entity name field map for entity field ID 033E45DF-D452-4846-BF76-537937EEF114 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='033E45DF-D452-4846-BF76-537937EEF114', @RelatedEntityNameFieldMap='Person';

/* Base View SQL for MJ_BizApps_Tasks: Task Timers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Timers
-- Item: vwTaskTimers
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Task Timers
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskTimer
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskTimers]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskTimers];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskTimers]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    mjBizAppsCommonPerson_PersonID.[DisplayName] AS [Person]
FROM
    [${flyway:defaultSchema}].[TaskTimer] AS t
INNER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
INNER JOIN
    [__mj_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_PersonID
  ON
    [t].[PersonID] = mjBizAppsCommonPerson_PersonID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTimers] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Timers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Timers
-- Item: Permissions for vwTaskTimers
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTimers] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskTimer]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTimer];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTimer]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @PersonID uniqueidentifier,
    @StartedAt datetimeoffset = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL,
    @IsBillable bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskTimer]
            (
                [ID],
                [TaskID],
                [PersonID],
                [StartedAt],
                [Notes],
                [IsBillable]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TaskID,
                @PersonID,
                ISNULL(@StartedAt, sysdatetimeoffset()),
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END,
                ISNULL(@IsBillable, 0)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskTimer]
            (
                [TaskID],
                [PersonID],
                [StartedAt],
                [Notes],
                [IsBillable]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TaskID,
                @PersonID,
                ISNULL(@StartedAt, sysdatetimeoffset()),
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END,
                ISNULL(@IsBillable, 0)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskTimers] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTimer] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Timers */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTimer] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskTimer]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTimer];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTimer]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier = NULL,
    @PersonID uniqueidentifier = NULL,
    @StartedAt datetimeoffset = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL,
    @IsBillable bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTimer]
    SET
        [TaskID] = ISNULL(@TaskID, [TaskID]),
        [PersonID] = ISNULL(@PersonID, [PersonID]),
        [StartedAt] = ISNULL(@StartedAt, [StartedAt]),
        [Notes] = CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, [Notes]) END,
        [IsBillable] = ISNULL(@IsBillable, [IsBillable])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskTimers] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskTimers]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTimer] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTimer table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskTimer]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskTimer];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskTimer
ON [${flyway:defaultSchema}].[TaskTimer]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTimer]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskTimer] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Timers */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTimer] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskTimer]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTimer];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTimer]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskTimer]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTimer] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Timers */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTimer] TO [cdp_Developer], [cdp_Integration];

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
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TaskTimeEntry
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTaskTimeEntries]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTaskTimeEntries];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTaskTimeEntries]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_TaskID.[Name] AS [Task],
    mjBizAppsCommonPerson_PersonID.[DisplayName] AS [Person]
FROM
    [${flyway:defaultSchema}].[TaskTimeEntry] AS t
INNER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_TaskID
  ON
    [t].[TaskID] = mjBizAppsTasksTask_TaskID.[ID]
INNER JOIN
    [__mj_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_PersonID
  ON
    [t].[PersonID] = mjBizAppsCommonPerson_PersonID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTimeEntries] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Task Time Entries */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Task Time Entries
-- Item: Permissions for vwTaskTimeEntries
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwTaskTimeEntries] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTaskTimeEntry]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTimeEntry];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTaskTimeEntry]
    @ID uniqueidentifier = NULL,
    @TaskID uniqueidentifier,
    @PersonID uniqueidentifier,
    @WorkDate date,
    @Minutes int,
    @StartedAt_Clear bit = 0,
    @StartedAt datetimeoffset = NULL,
    @EndedAt_Clear bit = 0,
    @EndedAt datetimeoffset = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL,
    @Source nvarchar(20) = NULL,
    @IsBillable bit = NULL,
    @TimesheetID_Clear bit = 0,
    @TimesheetID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TaskTimeEntry]
            (
                [ID],
                [TaskID],
                [PersonID],
                [WorkDate],
                [Minutes],
                [StartedAt],
                [EndedAt],
                [Notes],
                [Source],
                [IsBillable],
                [TimesheetID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TaskID,
                @PersonID,
                @WorkDate,
                @Minutes,
                CASE WHEN @StartedAt_Clear = 1 THEN NULL ELSE ISNULL(@StartedAt, NULL) END,
                CASE WHEN @EndedAt_Clear = 1 THEN NULL ELSE ISNULL(@EndedAt, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END,
                ISNULL(@Source, 'Manual'),
                ISNULL(@IsBillable, 0),
                CASE WHEN @TimesheetID_Clear = 1 THEN NULL ELSE ISNULL(@TimesheetID, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TaskTimeEntry]
            (
                [TaskID],
                [PersonID],
                [WorkDate],
                [Minutes],
                [StartedAt],
                [EndedAt],
                [Notes],
                [Source],
                [IsBillable],
                [TimesheetID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TaskID,
                @PersonID,
                @WorkDate,
                @Minutes,
                CASE WHEN @StartedAt_Clear = 1 THEN NULL ELSE ISNULL(@StartedAt, NULL) END,
                CASE WHEN @EndedAt_Clear = 1 THEN NULL ELSE ISNULL(@EndedAt, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END,
                ISNULL(@Source, 'Manual'),
                ISNULL(@IsBillable, 0),
                CASE WHEN @TimesheetID_Clear = 1 THEN NULL ELSE ISNULL(@TimesheetID, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTaskTimeEntries] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTimeEntry] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Task Time Entries */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTaskTimeEntry] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTaskTimeEntry]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTimeEntry];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTaskTimeEntry]
    @ID uniqueidentifier,
    @TaskID uniqueidentifier = NULL,
    @PersonID uniqueidentifier = NULL,
    @WorkDate date = NULL,
    @Minutes int = NULL,
    @StartedAt_Clear bit = 0,
    @StartedAt datetimeoffset = NULL,
    @EndedAt_Clear bit = 0,
    @EndedAt datetimeoffset = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL,
    @Source nvarchar(20) = NULL,
    @IsBillable bit = NULL,
    @TimesheetID_Clear bit = 0,
    @TimesheetID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTimeEntry]
    SET
        [TaskID] = ISNULL(@TaskID, [TaskID]),
        [PersonID] = ISNULL(@PersonID, [PersonID]),
        [WorkDate] = ISNULL(@WorkDate, [WorkDate]),
        [Minutes] = ISNULL(@Minutes, [Minutes]),
        [StartedAt] = CASE WHEN @StartedAt_Clear = 1 THEN NULL ELSE ISNULL(@StartedAt, [StartedAt]) END,
        [EndedAt] = CASE WHEN @EndedAt_Clear = 1 THEN NULL ELSE ISNULL(@EndedAt, [EndedAt]) END,
        [Notes] = CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, [Notes]) END,
        [Source] = ISNULL(@Source, [Source]),
        [IsBillable] = ISNULL(@IsBillable, [IsBillable]),
        [TimesheetID] = CASE WHEN @TimesheetID_Clear = 1 THEN NULL ELSE ISNULL(@TimesheetID, [TimesheetID]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTaskTimeEntries] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTaskTimeEntries]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTimeEntry] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TaskTimeEntry table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTaskTimeEntry]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTaskTimeEntry];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTaskTimeEntry
ON [${flyway:defaultSchema}].[TaskTimeEntry]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TaskTimeEntry]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TaskTimeEntry] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Task Time Entries */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTaskTimeEntry] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTaskTimeEntry]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTimeEntry];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTaskTimeEntry]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TaskTimeEntry]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTimeEntry] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Task Time Entries */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTaskTimeEntry] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for Task */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TypeID in table Task
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Task_TypeID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Task]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Task_TypeID ON [${flyway:defaultSchema}].[Task] ([TypeID]);

-- Index for foreign key CategoryID in table Task
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Task_CategoryID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Task]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Task_CategoryID ON [${flyway:defaultSchema}].[Task] ([CategoryID]);

-- Index for foreign key ParentID in table Task
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Task_ParentID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Task]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Task_ParentID ON [${flyway:defaultSchema}].[Task] ([ParentID]);

-- Index for foreign key CreatedByPersonID in table Task
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Task_CreatedByPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Task]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Task_CreatedByPersonID ON [${flyway:defaultSchema}].[Task] ([CreatedByPersonID]);

-- Index for foreign key TaskTypeStatusID in table Task
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Task_TaskTypeStatusID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Task]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Task_TaskTypeStatusID ON [${flyway:defaultSchema}].[Task] ([TaskTypeStatusID]);

/* Index for Foreign Keys for TimeApprover */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Time Approvers
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key ApproverPersonID in table TimeApprover
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TimeApprover_ApproverPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TimeApprover]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TimeApprover_ApproverPersonID ON [${flyway:defaultSchema}].[TimeApprover] ([ApproverPersonID]);

-- Index for foreign key WorkerPersonID in table TimeApprover
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TimeApprover_WorkerPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TimeApprover]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TimeApprover_WorkerPersonID ON [${flyway:defaultSchema}].[TimeApprover] ([WorkerPersonID]);

-- Index for foreign key ScopeTaskID in table TimeApprover
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TimeApprover_ScopeTaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TimeApprover]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TimeApprover_ScopeTaskID ON [${flyway:defaultSchema}].[TimeApprover] ([ScopeTaskID]);

-- Index for foreign key ScopeEntityID in table TimeApprover
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TimeApprover_ScopeEntityID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TimeApprover]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TimeApprover_ScopeEntityID ON [${flyway:defaultSchema}].[TimeApprover] ([ScopeEntityID]);

/* SQL text to update entity field related entity name field map for entity field ID 384549E1-5DDD-481C-A809-862C39893966 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='384549E1-5DDD-481C-A809-862C39893966', @RelatedEntityNameFieldMap='ApproverPerson';

/* Index for Foreign Keys for TimesheetApproval */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Approvals
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TimesheetID in table TimesheetApproval
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TimesheetApproval_TimesheetID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TimesheetApproval]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TimesheetApproval_TimesheetID ON [${flyway:defaultSchema}].[TimesheetApproval] ([TimesheetID]);

-- Index for foreign key ScopeTaskID in table TimesheetApproval
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TimesheetApproval_ScopeTaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TimesheetApproval]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TimesheetApproval_ScopeTaskID ON [${flyway:defaultSchema}].[TimesheetApproval] ([ScopeTaskID]);

-- Index for foreign key ApprovalTaskID in table TimesheetApproval
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TimesheetApproval_ApprovalTaskID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TimesheetApproval]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TimesheetApproval_ApprovalTaskID ON [${flyway:defaultSchema}].[TimesheetApproval] ([ApprovalTaskID]);

-- Index for foreign key DecidedByPersonID in table TimesheetApproval
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TimesheetApproval_DecidedByPersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TimesheetApproval]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TimesheetApproval_DecidedByPersonID ON [${flyway:defaultSchema}].[TimesheetApproval] ([DecidedByPersonID]);

/* SQL text to update entity field related entity name field map for entity field ID 313378B3-A046-4A6E-A58D-7D1CE9486988 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='313378B3-A046-4A6E-A58D-7D1CE9486988', @RelatedEntityNameFieldMap='ScopeTask';

/* Index for Foreign Keys for TimesheetLink */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Links
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key TimesheetID in table TimesheetLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TimesheetLink_TimesheetID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TimesheetLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TimesheetLink_TimesheetID ON [${flyway:defaultSchema}].[TimesheetLink] ([TimesheetID]);

-- Index for foreign key EntityID in table TimesheetLink
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TimesheetLink_EntityID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TimesheetLink]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TimesheetLink_EntityID ON [${flyway:defaultSchema}].[TimesheetLink] ([EntityID]);

/* SQL text to update entity field related entity name field map for entity field ID D14542B0-ED38-4ECD-83CF-6645EEB5BE2E */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='D14542B0-ED38-4ECD-83CF-6645EEB5BE2E', @RelatedEntityNameFieldMap='Entity';

/* Index for Foreign Keys for TimesheetSchedule */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Schedules
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key PersonID in table TimesheetSchedule
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TimesheetSchedule_PersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TimesheetSchedule]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TimesheetSchedule_PersonID ON [${flyway:defaultSchema}].[TimesheetSchedule] ([PersonID]);

-- Index for foreign key ScopeEntityID in table TimesheetSchedule
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_TimesheetSchedule_ScopeEntityID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[TimesheetSchedule]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_TimesheetSchedule_ScopeEntityID ON [${flyway:defaultSchema}].[TimesheetSchedule] ([ScopeEntityID]);

/* SQL text to update entity field related entity name field map for entity field ID 73405DD0-FAD3-4C48-948D-58D729E26521 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='73405DD0-FAD3-4C48-948D-58D729E26521', @RelatedEntityNameFieldMap='Person';

/* Index for Foreign Keys for Timesheet */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheets
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key PersonID in table Timesheet
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Timesheet_PersonID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Timesheet]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Timesheet_PersonID ON [${flyway:defaultSchema}].[Timesheet] ([PersonID]);

-- Index for foreign key SubmittedByUserID in table Timesheet
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Timesheet_SubmittedByUserID' 
    AND object_id = OBJECT_ID('[${flyway:defaultSchema}].[Timesheet]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Timesheet_SubmittedByUserID ON [${flyway:defaultSchema}].[Timesheet] ([SubmittedByUserID]);

/* SQL text to update entity field related entity name field map for entity field ID C5D5C45E-61C7-45F9-AFCE-2A9798F84AA2 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='C5D5C45E-61C7-45F9-AFCE-2A9798F84AA2', @RelatedEntityNameFieldMap='Person';

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
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  Task
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTasksGenerated]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTasksGenerated];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTasksGenerated]
AS
SELECT
    t.*,
    mjBizAppsTasksTaskType_TypeID.[Name] AS [Type],
    mjBizAppsTasksTaskCategory_CategoryID.[Name] AS [Category],
    mjBizAppsTasksTask_ParentID.[Name] AS [Parent],
    mjBizAppsCommonPerson_CreatedByPersonID.[DisplayName] AS [CreatedByPerson],
    mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID.[Name] AS [TaskTypeStatus]
FROM
    [${flyway:defaultSchema}].[Task] AS t
INNER JOIN
    [${flyway:defaultSchema}].[TaskType] AS mjBizAppsTasksTaskType_TypeID
  ON
    [t].[TypeID] = mjBizAppsTasksTaskType_TypeID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskCategory] AS mjBizAppsTasksTaskCategory_CategoryID
  ON
    [t].[CategoryID] = mjBizAppsTasksTaskCategory_CategoryID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_ParentID
  ON
    [t].[ParentID] = mjBizAppsTasksTask_ParentID.[ID]
LEFT OUTER JOIN
    [__mj_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_CreatedByPersonID
  ON
    [t].[CreatedByPersonID] = mjBizAppsCommonPerson_CreatedByPersonID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[TaskTypeStatus] AS mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID
  ON
    [t].[TaskTypeStatusID] = mjBizAppsTasksTaskTypeStatus_TaskTypeStatusID.[ID]
GO
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTasks]', 'V') IS NOT NULL
BEGIN
    EXEC sp_executesql N'REVOKE SELECT ON [${flyway:defaultSchema}].[vwTasks] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTasks] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTasks] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTasks] TO [cdp_UI], [cdp_Developer], [cdp_Integration]';
END;

/* Refresh layered base view for MJ_BizApps_Tasks: Tasks after its inner view changed */
EXEC sp_refreshview '${flyway:defaultSchema}.vwTasksGenerated';
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTasks]', 'V') IS NOT NULL
BEGIN
    EXEC sp_executesql N'EXEC sp_refreshview ''${flyway:defaultSchema}.vwTasks'';';
END

GO

/* Base View Permissions SQL for MJ_BizApps_Tasks: Tasks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Tasks
-- Item: Permissions for vwTasks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

IF OBJECT_ID('[${flyway:defaultSchema}].[vwTasks]', 'V') IS NOT NULL
BEGIN
    EXEC sp_executesql N'REVOKE SELECT ON [${flyway:defaultSchema}].[vwTasks] FROM [cdp_Developer]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTasks] FROM [cdp_Integration]
REVOKE SELECT ON [${flyway:defaultSchema}].[vwTasks] FROM [cdp_UI]
GRANT SELECT ON [${flyway:defaultSchema}].[vwTasks] TO [cdp_UI], [cdp_Developer], [cdp_Integration]';
END;

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTask]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTask];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTask]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(255),
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @TypeID uniqueidentifier,
    @CategoryID_Clear bit = 0,
    @CategoryID uniqueidentifier = NULL,
    @ParentID_Clear bit = 0,
    @ParentID uniqueidentifier = NULL,
    @Status nvarchar(50) = NULL,
    @Priority nvarchar(20) = NULL,
    @StartedAt_Clear bit = 0,
    @StartedAt datetimeoffset = NULL,
    @DueAt_Clear bit = 0,
    @DueAt datetimeoffset = NULL,
    @CompletedAt_Clear bit = 0,
    @CompletedAt datetimeoffset = NULL,
    @HoursEstimated_Clear bit = 0,
    @HoursEstimated decimal(8, 2) = NULL,
    @HoursActual_Clear bit = 0,
    @HoursActual decimal(8, 2) = NULL,
    @PercentComplete int = NULL,
    @Sequence int = NULL,
    @BlockedReason_Clear bit = 0,
    @BlockedReason nvarchar(MAX) = NULL,
    @CompletionNotes_Clear bit = 0,
    @CompletionNotes nvarchar(MAX) = NULL,
    @CreatedByPersonID_Clear bit = 0,
    @CreatedByPersonID uniqueidentifier = NULL,
    @OverdueNotifiedAt_Clear bit = 0,
    @OverdueNotifiedAt datetimeoffset = NULL,
    @TaskTypeStatusID_Clear bit = 0,
    @TaskTypeStatusID uniqueidentifier = NULL,
    @PredictedSLABreachProbability_Clear bit = 0,
    @PredictedSLABreachProbability decimal(5, 4) = NULL,
    @PredictedSLARiskBand_Clear bit = 0,
    @PredictedSLARiskBand nvarchar(20) = NULL,
    @PredictedSLAScoredAt_Clear bit = 0,
    @PredictedSLAScoredAt datetimeoffset = NULL,
    @HealthStatus_Clear bit = 0,
    @HealthStatus nvarchar(20) = NULL,
    @ConfidenceScore_Clear bit = 0,
    @ConfidenceScore int = NULL,
    @BaselineValue_Clear bit = 0,
    @BaselineValue decimal(18, 4) = NULL,
    @TargetValue_Clear bit = 0,
    @TargetValue decimal(18, 4) = NULL,
    @CurrentValue_Clear bit = 0,
    @CurrentValue decimal(18, 4) = NULL,
    @UnitOfMeasure_Clear bit = 0,
    @UnitOfMeasure nvarchar(50) = NULL,
    @MetricDirection_Clear bit = 0,
    @MetricDirection nvarchar(20) = NULL,
    @RollupWeight decimal(8, 2) = NULL,
    @PlanningPeriod_Clear bit = 0,
    @PlanningPeriod nvarchar(50) = NULL,
    @CheckInCadence_Clear bit = 0,
    @CheckInCadence nvarchar(20) = NULL,
    @LastCheckInAt_Clear bit = 0,
    @LastCheckInAt datetimeoffset = NULL,
    @NextCheckInDueAt_Clear bit = 0,
    @NextCheckInDueAt datetimeoffset = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[Task]
            (
                [ID],
                [Name],
                [Description],
                [TypeID],
                [CategoryID],
                [ParentID],
                [Status],
                [Priority],
                [StartedAt],
                [DueAt],
                [CompletedAt],
                [HoursEstimated],
                [HoursActual],
                [PercentComplete],
                [Sequence],
                [BlockedReason],
                [CompletionNotes],
                [CreatedByPersonID],
                [OverdueNotifiedAt],
                [TaskTypeStatusID],
                [PredictedSLABreachProbability],
                [PredictedSLARiskBand],
                [PredictedSLAScoredAt],
                [HealthStatus],
                [ConfidenceScore],
                [BaselineValue],
                [TargetValue],
                [CurrentValue],
                [UnitOfMeasure],
                [MetricDirection],
                [RollupWeight],
                [PlanningPeriod],
                [CheckInCadence],
                [LastCheckInAt],
                [NextCheckInDueAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                @TypeID,
                CASE WHEN @CategoryID_Clear = 1 THEN NULL ELSE ISNULL(@CategoryID, NULL) END,
                CASE WHEN @ParentID_Clear = 1 THEN NULL ELSE ISNULL(@ParentID, NULL) END,
                ISNULL(@Status, 'Open'),
                ISNULL(@Priority, 'Medium'),
                CASE WHEN @StartedAt_Clear = 1 THEN NULL ELSE ISNULL(@StartedAt, NULL) END,
                CASE WHEN @DueAt_Clear = 1 THEN NULL ELSE ISNULL(@DueAt, NULL) END,
                CASE WHEN @CompletedAt_Clear = 1 THEN NULL ELSE ISNULL(@CompletedAt, NULL) END,
                CASE WHEN @HoursEstimated_Clear = 1 THEN NULL ELSE ISNULL(@HoursEstimated, NULL) END,
                CASE WHEN @HoursActual_Clear = 1 THEN NULL ELSE ISNULL(@HoursActual, NULL) END,
                ISNULL(@PercentComplete, 0),
                ISNULL(@Sequence, 100),
                CASE WHEN @BlockedReason_Clear = 1 THEN NULL ELSE ISNULL(@BlockedReason, NULL) END,
                CASE WHEN @CompletionNotes_Clear = 1 THEN NULL ELSE ISNULL(@CompletionNotes, NULL) END,
                CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, NULL) END,
                CASE WHEN @OverdueNotifiedAt_Clear = 1 THEN NULL ELSE ISNULL(@OverdueNotifiedAt, NULL) END,
                CASE WHEN @TaskTypeStatusID_Clear = 1 THEN NULL ELSE ISNULL(@TaskTypeStatusID, NULL) END,
                CASE WHEN @PredictedSLABreachProbability_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLABreachProbability, NULL) END,
                CASE WHEN @PredictedSLARiskBand_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLARiskBand, NULL) END,
                CASE WHEN @PredictedSLAScoredAt_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLAScoredAt, NULL) END,
                CASE WHEN @HealthStatus_Clear = 1 THEN NULL ELSE ISNULL(@HealthStatus, NULL) END,
                CASE WHEN @ConfidenceScore_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceScore, NULL) END,
                CASE WHEN @BaselineValue_Clear = 1 THEN NULL ELSE ISNULL(@BaselineValue, NULL) END,
                CASE WHEN @TargetValue_Clear = 1 THEN NULL ELSE ISNULL(@TargetValue, NULL) END,
                CASE WHEN @CurrentValue_Clear = 1 THEN NULL ELSE ISNULL(@CurrentValue, NULL) END,
                CASE WHEN @UnitOfMeasure_Clear = 1 THEN NULL ELSE ISNULL(@UnitOfMeasure, NULL) END,
                CASE WHEN @MetricDirection_Clear = 1 THEN NULL ELSE ISNULL(@MetricDirection, NULL) END,
                ISNULL(@RollupWeight, 1.00),
                CASE WHEN @PlanningPeriod_Clear = 1 THEN NULL ELSE ISNULL(@PlanningPeriod, NULL) END,
                CASE WHEN @CheckInCadence_Clear = 1 THEN NULL ELSE ISNULL(@CheckInCadence, NULL) END,
                CASE WHEN @LastCheckInAt_Clear = 1 THEN NULL ELSE ISNULL(@LastCheckInAt, NULL) END,
                CASE WHEN @NextCheckInDueAt_Clear = 1 THEN NULL ELSE ISNULL(@NextCheckInDueAt, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[Task]
            (
                [Name],
                [Description],
                [TypeID],
                [CategoryID],
                [ParentID],
                [Status],
                [Priority],
                [StartedAt],
                [DueAt],
                [CompletedAt],
                [HoursEstimated],
                [HoursActual],
                [PercentComplete],
                [Sequence],
                [BlockedReason],
                [CompletionNotes],
                [CreatedByPersonID],
                [OverdueNotifiedAt],
                [TaskTypeStatusID],
                [PredictedSLABreachProbability],
                [PredictedSLARiskBand],
                [PredictedSLAScoredAt],
                [HealthStatus],
                [ConfidenceScore],
                [BaselineValue],
                [TargetValue],
                [CurrentValue],
                [UnitOfMeasure],
                [MetricDirection],
                [RollupWeight],
                [PlanningPeriod],
                [CheckInCadence],
                [LastCheckInAt],
                [NextCheckInDueAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, NULL) END,
                @TypeID,
                CASE WHEN @CategoryID_Clear = 1 THEN NULL ELSE ISNULL(@CategoryID, NULL) END,
                CASE WHEN @ParentID_Clear = 1 THEN NULL ELSE ISNULL(@ParentID, NULL) END,
                ISNULL(@Status, 'Open'),
                ISNULL(@Priority, 'Medium'),
                CASE WHEN @StartedAt_Clear = 1 THEN NULL ELSE ISNULL(@StartedAt, NULL) END,
                CASE WHEN @DueAt_Clear = 1 THEN NULL ELSE ISNULL(@DueAt, NULL) END,
                CASE WHEN @CompletedAt_Clear = 1 THEN NULL ELSE ISNULL(@CompletedAt, NULL) END,
                CASE WHEN @HoursEstimated_Clear = 1 THEN NULL ELSE ISNULL(@HoursEstimated, NULL) END,
                CASE WHEN @HoursActual_Clear = 1 THEN NULL ELSE ISNULL(@HoursActual, NULL) END,
                ISNULL(@PercentComplete, 0),
                ISNULL(@Sequence, 100),
                CASE WHEN @BlockedReason_Clear = 1 THEN NULL ELSE ISNULL(@BlockedReason, NULL) END,
                CASE WHEN @CompletionNotes_Clear = 1 THEN NULL ELSE ISNULL(@CompletionNotes, NULL) END,
                CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, NULL) END,
                CASE WHEN @OverdueNotifiedAt_Clear = 1 THEN NULL ELSE ISNULL(@OverdueNotifiedAt, NULL) END,
                CASE WHEN @TaskTypeStatusID_Clear = 1 THEN NULL ELSE ISNULL(@TaskTypeStatusID, NULL) END,
                CASE WHEN @PredictedSLABreachProbability_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLABreachProbability, NULL) END,
                CASE WHEN @PredictedSLARiskBand_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLARiskBand, NULL) END,
                CASE WHEN @PredictedSLAScoredAt_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLAScoredAt, NULL) END,
                CASE WHEN @HealthStatus_Clear = 1 THEN NULL ELSE ISNULL(@HealthStatus, NULL) END,
                CASE WHEN @ConfidenceScore_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceScore, NULL) END,
                CASE WHEN @BaselineValue_Clear = 1 THEN NULL ELSE ISNULL(@BaselineValue, NULL) END,
                CASE WHEN @TargetValue_Clear = 1 THEN NULL ELSE ISNULL(@TargetValue, NULL) END,
                CASE WHEN @CurrentValue_Clear = 1 THEN NULL ELSE ISNULL(@CurrentValue, NULL) END,
                CASE WHEN @UnitOfMeasure_Clear = 1 THEN NULL ELSE ISNULL(@UnitOfMeasure, NULL) END,
                CASE WHEN @MetricDirection_Clear = 1 THEN NULL ELSE ISNULL(@MetricDirection, NULL) END,
                ISNULL(@RollupWeight, 1.00),
                CASE WHEN @PlanningPeriod_Clear = 1 THEN NULL ELSE ISNULL(@PlanningPeriod, NULL) END,
                CASE WHEN @CheckInCadence_Clear = 1 THEN NULL ELSE ISNULL(@CheckInCadence, NULL) END,
                CASE WHEN @LastCheckInAt_Clear = 1 THEN NULL ELSE ISNULL(@LastCheckInAt, NULL) END,
                CASE WHEN @NextCheckInDueAt_Clear = 1 THEN NULL ELSE ISNULL(@NextCheckInDueAt, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTasks] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_Integration]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_UI]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Tasks */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_Integration]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] FROM [cdp_UI]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTask] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTask]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTask];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTask]
    @ID uniqueidentifier,
    @Name nvarchar(255) = NULL,
    @Description_Clear bit = 0,
    @Description nvarchar(MAX) = NULL,
    @TypeID uniqueidentifier = NULL,
    @CategoryID_Clear bit = 0,
    @CategoryID uniqueidentifier = NULL,
    @ParentID_Clear bit = 0,
    @ParentID uniqueidentifier = NULL,
    @Status nvarchar(50) = NULL,
    @Priority nvarchar(20) = NULL,
    @StartedAt_Clear bit = 0,
    @StartedAt datetimeoffset = NULL,
    @DueAt_Clear bit = 0,
    @DueAt datetimeoffset = NULL,
    @CompletedAt_Clear bit = 0,
    @CompletedAt datetimeoffset = NULL,
    @HoursEstimated_Clear bit = 0,
    @HoursEstimated decimal(8, 2) = NULL,
    @HoursActual_Clear bit = 0,
    @HoursActual decimal(8, 2) = NULL,
    @PercentComplete int = NULL,
    @Sequence int = NULL,
    @BlockedReason_Clear bit = 0,
    @BlockedReason nvarchar(MAX) = NULL,
    @CompletionNotes_Clear bit = 0,
    @CompletionNotes nvarchar(MAX) = NULL,
    @CreatedByPersonID_Clear bit = 0,
    @CreatedByPersonID uniqueidentifier = NULL,
    @OverdueNotifiedAt_Clear bit = 0,
    @OverdueNotifiedAt datetimeoffset = NULL,
    @TaskTypeStatusID_Clear bit = 0,
    @TaskTypeStatusID uniqueidentifier = NULL,
    @PredictedSLABreachProbability_Clear bit = 0,
    @PredictedSLABreachProbability decimal(5, 4) = NULL,
    @PredictedSLARiskBand_Clear bit = 0,
    @PredictedSLARiskBand nvarchar(20) = NULL,
    @PredictedSLAScoredAt_Clear bit = 0,
    @PredictedSLAScoredAt datetimeoffset = NULL,
    @HealthStatus_Clear bit = 0,
    @HealthStatus nvarchar(20) = NULL,
    @ConfidenceScore_Clear bit = 0,
    @ConfidenceScore int = NULL,
    @BaselineValue_Clear bit = 0,
    @BaselineValue decimal(18, 4) = NULL,
    @TargetValue_Clear bit = 0,
    @TargetValue decimal(18, 4) = NULL,
    @CurrentValue_Clear bit = 0,
    @CurrentValue decimal(18, 4) = NULL,
    @UnitOfMeasure_Clear bit = 0,
    @UnitOfMeasure nvarchar(50) = NULL,
    @MetricDirection_Clear bit = 0,
    @MetricDirection nvarchar(20) = NULL,
    @RollupWeight decimal(8, 2) = NULL,
    @PlanningPeriod_Clear bit = 0,
    @PlanningPeriod nvarchar(50) = NULL,
    @CheckInCadence_Clear bit = 0,
    @CheckInCadence nvarchar(20) = NULL,
    @LastCheckInAt_Clear bit = 0,
    @LastCheckInAt datetimeoffset = NULL,
    @NextCheckInDueAt_Clear bit = 0,
    @NextCheckInDueAt datetimeoffset = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[Task]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [Description] = CASE WHEN @Description_Clear = 1 THEN NULL ELSE ISNULL(@Description, [Description]) END,
        [TypeID] = ISNULL(@TypeID, [TypeID]),
        [CategoryID] = CASE WHEN @CategoryID_Clear = 1 THEN NULL ELSE ISNULL(@CategoryID, [CategoryID]) END,
        [ParentID] = CASE WHEN @ParentID_Clear = 1 THEN NULL ELSE ISNULL(@ParentID, [ParentID]) END,
        [Status] = ISNULL(@Status, [Status]),
        [Priority] = ISNULL(@Priority, [Priority]),
        [StartedAt] = CASE WHEN @StartedAt_Clear = 1 THEN NULL ELSE ISNULL(@StartedAt, [StartedAt]) END,
        [DueAt] = CASE WHEN @DueAt_Clear = 1 THEN NULL ELSE ISNULL(@DueAt, [DueAt]) END,
        [CompletedAt] = CASE WHEN @CompletedAt_Clear = 1 THEN NULL ELSE ISNULL(@CompletedAt, [CompletedAt]) END,
        [HoursEstimated] = CASE WHEN @HoursEstimated_Clear = 1 THEN NULL ELSE ISNULL(@HoursEstimated, [HoursEstimated]) END,
        [HoursActual] = CASE WHEN @HoursActual_Clear = 1 THEN NULL ELSE ISNULL(@HoursActual, [HoursActual]) END,
        [PercentComplete] = ISNULL(@PercentComplete, [PercentComplete]),
        [Sequence] = ISNULL(@Sequence, [Sequence]),
        [BlockedReason] = CASE WHEN @BlockedReason_Clear = 1 THEN NULL ELSE ISNULL(@BlockedReason, [BlockedReason]) END,
        [CompletionNotes] = CASE WHEN @CompletionNotes_Clear = 1 THEN NULL ELSE ISNULL(@CompletionNotes, [CompletionNotes]) END,
        [CreatedByPersonID] = CASE WHEN @CreatedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@CreatedByPersonID, [CreatedByPersonID]) END,
        [OverdueNotifiedAt] = CASE WHEN @OverdueNotifiedAt_Clear = 1 THEN NULL ELSE ISNULL(@OverdueNotifiedAt, [OverdueNotifiedAt]) END,
        [TaskTypeStatusID] = CASE WHEN @TaskTypeStatusID_Clear = 1 THEN NULL ELSE ISNULL(@TaskTypeStatusID, [TaskTypeStatusID]) END,
        [PredictedSLABreachProbability] = CASE WHEN @PredictedSLABreachProbability_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLABreachProbability, [PredictedSLABreachProbability]) END,
        [PredictedSLARiskBand] = CASE WHEN @PredictedSLARiskBand_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLARiskBand, [PredictedSLARiskBand]) END,
        [PredictedSLAScoredAt] = CASE WHEN @PredictedSLAScoredAt_Clear = 1 THEN NULL ELSE ISNULL(@PredictedSLAScoredAt, [PredictedSLAScoredAt]) END,
        [HealthStatus] = CASE WHEN @HealthStatus_Clear = 1 THEN NULL ELSE ISNULL(@HealthStatus, [HealthStatus]) END,
        [ConfidenceScore] = CASE WHEN @ConfidenceScore_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceScore, [ConfidenceScore]) END,
        [BaselineValue] = CASE WHEN @BaselineValue_Clear = 1 THEN NULL ELSE ISNULL(@BaselineValue, [BaselineValue]) END,
        [TargetValue] = CASE WHEN @TargetValue_Clear = 1 THEN NULL ELSE ISNULL(@TargetValue, [TargetValue]) END,
        [CurrentValue] = CASE WHEN @CurrentValue_Clear = 1 THEN NULL ELSE ISNULL(@CurrentValue, [CurrentValue]) END,
        [UnitOfMeasure] = CASE WHEN @UnitOfMeasure_Clear = 1 THEN NULL ELSE ISNULL(@UnitOfMeasure, [UnitOfMeasure]) END,
        [MetricDirection] = CASE WHEN @MetricDirection_Clear = 1 THEN NULL ELSE ISNULL(@MetricDirection, [MetricDirection]) END,
        [RollupWeight] = ISNULL(@RollupWeight, [RollupWeight]),
        [PlanningPeriod] = CASE WHEN @PlanningPeriod_Clear = 1 THEN NULL ELSE ISNULL(@PlanningPeriod, [PlanningPeriod]) END,
        [CheckInCadence] = CASE WHEN @CheckInCadence_Clear = 1 THEN NULL ELSE ISNULL(@CheckInCadence, [CheckInCadence]) END,
        [LastCheckInAt] = CASE WHEN @LastCheckInAt_Clear = 1 THEN NULL ELSE ISNULL(@LastCheckInAt, [LastCheckInAt]) END,
        [NextCheckInDueAt] = CASE WHEN @NextCheckInDueAt_Clear = 1 THEN NULL ELSE ISNULL(@NextCheckInDueAt, [NextCheckInDueAt]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTasks] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTasks]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_Integration]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_UI]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] TO [cdp_UI], [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Task table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTask]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTask];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTask
ON [${flyway:defaultSchema}].[Task]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[Task]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[Task] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Tasks */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_Integration]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] FROM [cdp_UI]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTask] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTask]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTask];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTask]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[Task]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Tasks */

REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] FROM [cdp_Developer]
REVOKE EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] FROM [cdp_Integration]
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTask] TO [cdp_Developer], [cdp_Integration];

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
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TimesheetLink
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTimesheetLinks]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTimesheetLinks];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTimesheetLinks]
AS
SELECT
    t.*,
    MJEntity_EntityID.[Name] AS [Entity]
FROM
    [${flyway:defaultSchema}].[TimesheetLink] AS t
INNER JOIN
    [${mjSchema}].[Entity] AS MJEntity_EntityID
  ON
    [t].[EntityID] = MJEntity_EntityID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwTimesheetLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Timesheet Links */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Links
-- Item: Permissions for vwTimesheetLinks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwTimesheetLinks] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTimesheetLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTimesheetLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTimesheetLink]
    @ID uniqueidentifier = NULL,
    @TimesheetID uniqueidentifier,
    @EntityID uniqueidentifier,
    @RecordID nvarchar(450),
    @Relationship nvarchar(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TimesheetLink]
            (
                [ID],
                [TimesheetID],
                [EntityID],
                [RecordID],
                [Relationship]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TimesheetID,
                @EntityID,
                @RecordID,
                ISNULL(@Relationship, 'Related')
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TimesheetLink]
            (
                [TimesheetID],
                [EntityID],
                [RecordID],
                [Relationship]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TimesheetID,
                @EntityID,
                @RecordID,
                ISNULL(@Relationship, 'Related')
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTimesheetLinks] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTimesheetLink] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Timesheet Links */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTimesheetLink] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTimesheetLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTimesheetLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTimesheetLink]
    @ID uniqueidentifier,
    @TimesheetID uniqueidentifier = NULL,
    @EntityID uniqueidentifier = NULL,
    @RecordID nvarchar(450) = NULL,
    @Relationship nvarchar(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TimesheetLink]
    SET
        [TimesheetID] = ISNULL(@TimesheetID, [TimesheetID]),
        [EntityID] = ISNULL(@EntityID, [EntityID]),
        [RecordID] = ISNULL(@RecordID, [RecordID]),
        [Relationship] = ISNULL(@Relationship, [Relationship])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTimesheetLinks] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTimesheetLinks]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTimesheetLink] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TimesheetLink table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTimesheetLink]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTimesheetLink];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTimesheetLink
ON [${flyway:defaultSchema}].[TimesheetLink]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TimesheetLink]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TimesheetLink] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Timesheet Links */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTimesheetLink] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTimesheetLink]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTimesheetLink];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTimesheetLink]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TimesheetLink]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTimesheetLink] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Timesheet Links */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTimesheetLink] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID BC31C246-345F-4A54-8C9F-A09F01295492 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='BC31C246-345F-4A54-8C9F-A09F01295492', @RelatedEntityNameFieldMap='SubmittedByUser';

/* SQL text to update entity field related entity name field map for entity field ID DA4B81FD-828E-4B52-B51E-A56A2216A124 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='DA4B81FD-828E-4B52-B51E-A56A2216A124', @RelatedEntityNameFieldMap='ApprovalTask';

/* SQL text to update entity field related entity name field map for entity field ID 0C2C4D67-B8A8-442A-9CE8-E2F0D35A183E */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='0C2C4D67-B8A8-442A-9CE8-E2F0D35A183E', @RelatedEntityNameFieldMap='WorkerPerson';

/* SQL text to update entity field related entity name field map for entity field ID 2CE5F2B1-19BC-444F-8EBB-96263103B081 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='2CE5F2B1-19BC-444F-8EBB-96263103B081', @RelatedEntityNameFieldMap='ScopeEntity';

/* Base View SQL for MJ_BizApps_Tasks: Timesheet Schedules */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Schedules
-- Item: vwTimesheetSchedules
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Timesheet Schedules
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TimesheetSchedule
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTimesheetSchedules]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTimesheetSchedules];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTimesheetSchedules]
AS
SELECT
    t.*,
    mjBizAppsCommonPerson_PersonID.[DisplayName] AS [Person],
    MJEntity_ScopeEntityID.[Name] AS [ScopeEntity]
FROM
    [${flyway:defaultSchema}].[TimesheetSchedule] AS t
LEFT OUTER JOIN
    [__mj_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_PersonID
  ON
    [t].[PersonID] = mjBizAppsCommonPerson_PersonID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Entity] AS MJEntity_ScopeEntityID
  ON
    [t].[ScopeEntityID] = MJEntity_ScopeEntityID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwTimesheetSchedules] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Timesheet Schedules */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Schedules
-- Item: Permissions for vwTimesheetSchedules
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwTimesheetSchedules] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTimesheetSchedule]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTimesheetSchedule];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTimesheetSchedule]
    @ID uniqueidentifier = NULL,
    @PersonID_Clear bit = 0,
    @PersonID uniqueidentifier = NULL,
    @ScopeEntityID_Clear bit = 0,
    @ScopeEntityID uniqueidentifier = NULL,
    @ScopeRecordID_Clear bit = 0,
    @ScopeRecordID nvarchar(450) = NULL,
    @Cadence nvarchar(20),
    @WeekStartDay nvarchar(10) = NULL,
    @BiWeeklyAnchorDate date = NULL,
    @EffectiveFrom date,
    @EffectiveTo_Clear bit = 0,
    @EffectiveTo date = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TimesheetSchedule]
            (
                [ID],
                [PersonID],
                [ScopeEntityID],
                [ScopeRecordID],
                [Cadence],
                [WeekStartDay],
                [BiWeeklyAnchorDate],
                [EffectiveFrom],
                [EffectiveTo],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                CASE WHEN @PersonID_Clear = 1 THEN NULL ELSE ISNULL(@PersonID, NULL) END,
                CASE WHEN @ScopeEntityID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeEntityID, NULL) END,
                CASE WHEN @ScopeRecordID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeRecordID, NULL) END,
                @Cadence,
                ISNULL(@WeekStartDay, 'Monday'),
                ISNULL(@BiWeeklyAnchorDate, '2026-01-05'),
                @EffectiveFrom,
                CASE WHEN @EffectiveTo_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveTo, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TimesheetSchedule]
            (
                [PersonID],
                [ScopeEntityID],
                [ScopeRecordID],
                [Cadence],
                [WeekStartDay],
                [BiWeeklyAnchorDate],
                [EffectiveFrom],
                [EffectiveTo],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                CASE WHEN @PersonID_Clear = 1 THEN NULL ELSE ISNULL(@PersonID, NULL) END,
                CASE WHEN @ScopeEntityID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeEntityID, NULL) END,
                CASE WHEN @ScopeRecordID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeRecordID, NULL) END,
                @Cadence,
                ISNULL(@WeekStartDay, 'Monday'),
                ISNULL(@BiWeeklyAnchorDate, '2026-01-05'),
                @EffectiveFrom,
                CASE WHEN @EffectiveTo_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveTo, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTimesheetSchedules] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTimesheetSchedule] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Timesheet Schedules */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTimesheetSchedule] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTimesheetSchedule]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTimesheetSchedule];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTimesheetSchedule]
    @ID uniqueidentifier,
    @PersonID_Clear bit = 0,
    @PersonID uniqueidentifier = NULL,
    @ScopeEntityID_Clear bit = 0,
    @ScopeEntityID uniqueidentifier = NULL,
    @ScopeRecordID_Clear bit = 0,
    @ScopeRecordID nvarchar(450) = NULL,
    @Cadence nvarchar(20) = NULL,
    @WeekStartDay nvarchar(10) = NULL,
    @BiWeeklyAnchorDate date = NULL,
    @EffectiveFrom date = NULL,
    @EffectiveTo_Clear bit = 0,
    @EffectiveTo date = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TimesheetSchedule]
    SET
        [PersonID] = CASE WHEN @PersonID_Clear = 1 THEN NULL ELSE ISNULL(@PersonID, [PersonID]) END,
        [ScopeEntityID] = CASE WHEN @ScopeEntityID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeEntityID, [ScopeEntityID]) END,
        [ScopeRecordID] = CASE WHEN @ScopeRecordID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeRecordID, [ScopeRecordID]) END,
        [Cadence] = ISNULL(@Cadence, [Cadence]),
        [WeekStartDay] = ISNULL(@WeekStartDay, [WeekStartDay]),
        [BiWeeklyAnchorDate] = ISNULL(@BiWeeklyAnchorDate, [BiWeeklyAnchorDate]),
        [EffectiveFrom] = ISNULL(@EffectiveFrom, [EffectiveFrom]),
        [EffectiveTo] = CASE WHEN @EffectiveTo_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveTo, [EffectiveTo]) END,
        [Notes] = CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, [Notes]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTimesheetSchedules] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTimesheetSchedules]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTimesheetSchedule] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TimesheetSchedule table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTimesheetSchedule]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTimesheetSchedule];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTimesheetSchedule
ON [${flyway:defaultSchema}].[TimesheetSchedule]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TimesheetSchedule]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TimesheetSchedule] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Timesheet Schedules */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTimesheetSchedule] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTimesheetSchedule]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTimesheetSchedule];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTimesheetSchedule]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TimesheetSchedule]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTimesheetSchedule] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Timesheet Schedules */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTimesheetSchedule] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID 690C2A28-5F12-47DE-8580-12E6F0990EC7 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='690C2A28-5F12-47DE-8580-12E6F0990EC7', @RelatedEntityNameFieldMap='ScopeTask';

/* SQL text to update entity field related entity name field map for entity field ID 8BEE7526-7AFF-4767-8BA2-6A752B8B7000 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='8BEE7526-7AFF-4767-8BA2-6A752B8B7000', @RelatedEntityNameFieldMap='DecidedByPerson';

/* Base View SQL for MJ_BizApps_Tasks: Timesheets */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheets
-- Item: vwTimesheets
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Timesheets
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  Timesheet
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTimesheets]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTimesheets];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTimesheets]
AS
SELECT
    t.*,
    mjBizAppsCommonPerson_PersonID.[DisplayName] AS [Person],
    MJUser_SubmittedByUserID.[Name] AS [SubmittedByUser]
FROM
    [${flyway:defaultSchema}].[Timesheet] AS t
INNER JOIN
    [__mj_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_PersonID
  ON
    [t].[PersonID] = mjBizAppsCommonPerson_PersonID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[User] AS MJUser_SubmittedByUserID
  ON
    [t].[SubmittedByUserID] = MJUser_SubmittedByUserID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwTimesheets] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Timesheets */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheets
-- Item: Permissions for vwTimesheets
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwTimesheets] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTimesheet]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTimesheet];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTimesheet]
    @ID uniqueidentifier = NULL,
    @PersonID uniqueidentifier,
    @PeriodStart date,
    @PeriodEnd date,
    @Status nvarchar(20) = NULL,
    @SubmittedAt_Clear bit = 0,
    @SubmittedAt datetimeoffset = NULL,
    @SubmittedByUserID_Clear bit = 0,
    @SubmittedByUserID uniqueidentifier = NULL,
    @TotalMinutes int = NULL,
    @BillableMinutes int = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[Timesheet]
            (
                [ID],
                [PersonID],
                [PeriodStart],
                [PeriodEnd],
                [Status],
                [SubmittedAt],
                [SubmittedByUserID],
                [TotalMinutes],
                [BillableMinutes],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @PersonID,
                @PeriodStart,
                @PeriodEnd,
                ISNULL(@Status, 'Draft'),
                CASE WHEN @SubmittedAt_Clear = 1 THEN NULL ELSE ISNULL(@SubmittedAt, NULL) END,
                CASE WHEN @SubmittedByUserID_Clear = 1 THEN NULL ELSE ISNULL(@SubmittedByUserID, NULL) END,
                ISNULL(@TotalMinutes, 0),
                ISNULL(@BillableMinutes, 0),
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[Timesheet]
            (
                [PersonID],
                [PeriodStart],
                [PeriodEnd],
                [Status],
                [SubmittedAt],
                [SubmittedByUserID],
                [TotalMinutes],
                [BillableMinutes],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @PersonID,
                @PeriodStart,
                @PeriodEnd,
                ISNULL(@Status, 'Draft'),
                CASE WHEN @SubmittedAt_Clear = 1 THEN NULL ELSE ISNULL(@SubmittedAt, NULL) END,
                CASE WHEN @SubmittedByUserID_Clear = 1 THEN NULL ELSE ISNULL(@SubmittedByUserID, NULL) END,
                ISNULL(@TotalMinutes, 0),
                ISNULL(@BillableMinutes, 0),
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTimesheets] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTimesheet] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Timesheets */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTimesheet] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTimesheet]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTimesheet];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTimesheet]
    @ID uniqueidentifier,
    @PersonID uniqueidentifier = NULL,
    @PeriodStart date = NULL,
    @PeriodEnd date = NULL,
    @Status nvarchar(20) = NULL,
    @SubmittedAt_Clear bit = 0,
    @SubmittedAt datetimeoffset = NULL,
    @SubmittedByUserID_Clear bit = 0,
    @SubmittedByUserID uniqueidentifier = NULL,
    @TotalMinutes int = NULL,
    @BillableMinutes int = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[Timesheet]
    SET
        [PersonID] = ISNULL(@PersonID, [PersonID]),
        [PeriodStart] = ISNULL(@PeriodStart, [PeriodStart]),
        [PeriodEnd] = ISNULL(@PeriodEnd, [PeriodEnd]),
        [Status] = ISNULL(@Status, [Status]),
        [SubmittedAt] = CASE WHEN @SubmittedAt_Clear = 1 THEN NULL ELSE ISNULL(@SubmittedAt, [SubmittedAt]) END,
        [SubmittedByUserID] = CASE WHEN @SubmittedByUserID_Clear = 1 THEN NULL ELSE ISNULL(@SubmittedByUserID, [SubmittedByUserID]) END,
        [TotalMinutes] = ISNULL(@TotalMinutes, [TotalMinutes]),
        [BillableMinutes] = ISNULL(@BillableMinutes, [BillableMinutes]),
        [Notes] = CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, [Notes]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTimesheets] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTimesheets]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTimesheet] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Timesheet table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTimesheet]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTimesheet];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTimesheet
ON [${flyway:defaultSchema}].[Timesheet]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[Timesheet]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[Timesheet] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Timesheets */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTimesheet] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTimesheet]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTimesheet];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTimesheet]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[Timesheet]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTimesheet] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Timesheets */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTimesheet] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID FE1BF4B9-32B1-4EDC-9E13-DBE524F895A6 */
EXEC [${mjSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='FE1BF4B9-32B1-4EDC-9E13-DBE524F895A6', @RelatedEntityNameFieldMap='ScopeEntity';

/* Base View SQL for MJ_BizApps_Tasks: Timesheet Approvals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Approvals
-- Item: vwTimesheetApprovals
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      MJ_BizApps_Tasks: Timesheet Approvals
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TimesheetApproval
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTimesheetApprovals]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTimesheetApprovals];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTimesheetApprovals]
AS
SELECT
    t.*,
    mjBizAppsTasksTask_ScopeTaskID.[Name] AS [ScopeTask],
    mjBizAppsTasksTask_ApprovalTaskID.[Name] AS [ApprovalTask],
    mjBizAppsCommonPerson_DecidedByPersonID.[DisplayName] AS [DecidedByPerson]
FROM
    [${flyway:defaultSchema}].[TimesheetApproval] AS t
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_ScopeTaskID
  ON
    [t].[ScopeTaskID] = mjBizAppsTasksTask_ScopeTaskID.[ID]
INNER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_ApprovalTaskID
  ON
    [t].[ApprovalTaskID] = mjBizAppsTasksTask_ApprovalTaskID.[ID]
LEFT OUTER JOIN
    [__mj_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_DecidedByPersonID
  ON
    [t].[DecidedByPersonID] = mjBizAppsCommonPerson_DecidedByPersonID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwTimesheetApprovals] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Timesheet Approvals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Timesheet Approvals
-- Item: Permissions for vwTimesheetApprovals
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwTimesheetApprovals] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTimesheetApproval]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTimesheetApproval];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTimesheetApproval]
    @ID uniqueidentifier = NULL,
    @TimesheetID uniqueidentifier,
    @SubmissionRound int = NULL,
    @ScopeTaskID_Clear bit = 0,
    @ScopeTaskID uniqueidentifier = NULL,
    @ApprovalTaskID uniqueidentifier,
    @Minutes int = NULL,
    @BillableMinutes int = NULL,
    @EntryCount int = NULL,
    @SnapshotHash nvarchar(64),
    @Status nvarchar(20) = NULL,
    @DecidedByPersonID_Clear bit = 0,
    @DecidedByPersonID uniqueidentifier = NULL,
    @DecidedAt_Clear bit = 0,
    @DecidedAt datetimeoffset = NULL,
    @DecisionNotes_Clear bit = 0,
    @DecisionNotes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TimesheetApproval]
            (
                [ID],
                [TimesheetID],
                [SubmissionRound],
                [ScopeTaskID],
                [ApprovalTaskID],
                [Minutes],
                [BillableMinutes],
                [EntryCount],
                [SnapshotHash],
                [Status],
                [DecidedByPersonID],
                [DecidedAt],
                [DecisionNotes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @TimesheetID,
                ISNULL(@SubmissionRound, 1),
                CASE WHEN @ScopeTaskID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeTaskID, NULL) END,
                @ApprovalTaskID,
                ISNULL(@Minutes, 0),
                ISNULL(@BillableMinutes, 0),
                ISNULL(@EntryCount, 0),
                @SnapshotHash,
                ISNULL(@Status, 'Pending'),
                CASE WHEN @DecidedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@DecidedByPersonID, NULL) END,
                CASE WHEN @DecidedAt_Clear = 1 THEN NULL ELSE ISNULL(@DecidedAt, NULL) END,
                CASE WHEN @DecisionNotes_Clear = 1 THEN NULL ELSE ISNULL(@DecisionNotes, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TimesheetApproval]
            (
                [TimesheetID],
                [SubmissionRound],
                [ScopeTaskID],
                [ApprovalTaskID],
                [Minutes],
                [BillableMinutes],
                [EntryCount],
                [SnapshotHash],
                [Status],
                [DecidedByPersonID],
                [DecidedAt],
                [DecisionNotes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @TimesheetID,
                ISNULL(@SubmissionRound, 1),
                CASE WHEN @ScopeTaskID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeTaskID, NULL) END,
                @ApprovalTaskID,
                ISNULL(@Minutes, 0),
                ISNULL(@BillableMinutes, 0),
                ISNULL(@EntryCount, 0),
                @SnapshotHash,
                ISNULL(@Status, 'Pending'),
                CASE WHEN @DecidedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@DecidedByPersonID, NULL) END,
                CASE WHEN @DecidedAt_Clear = 1 THEN NULL ELSE ISNULL(@DecidedAt, NULL) END,
                CASE WHEN @DecisionNotes_Clear = 1 THEN NULL ELSE ISNULL(@DecisionNotes, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTimesheetApprovals] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTimesheetApproval] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Timesheet Approvals */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTimesheetApproval] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTimesheetApproval]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTimesheetApproval];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTimesheetApproval]
    @ID uniqueidentifier,
    @TimesheetID uniqueidentifier = NULL,
    @SubmissionRound int = NULL,
    @ScopeTaskID_Clear bit = 0,
    @ScopeTaskID uniqueidentifier = NULL,
    @ApprovalTaskID uniqueidentifier = NULL,
    @Minutes int = NULL,
    @BillableMinutes int = NULL,
    @EntryCount int = NULL,
    @SnapshotHash nvarchar(64) = NULL,
    @Status nvarchar(20) = NULL,
    @DecidedByPersonID_Clear bit = 0,
    @DecidedByPersonID uniqueidentifier = NULL,
    @DecidedAt_Clear bit = 0,
    @DecidedAt datetimeoffset = NULL,
    @DecisionNotes_Clear bit = 0,
    @DecisionNotes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TimesheetApproval]
    SET
        [TimesheetID] = ISNULL(@TimesheetID, [TimesheetID]),
        [SubmissionRound] = ISNULL(@SubmissionRound, [SubmissionRound]),
        [ScopeTaskID] = CASE WHEN @ScopeTaskID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeTaskID, [ScopeTaskID]) END,
        [ApprovalTaskID] = ISNULL(@ApprovalTaskID, [ApprovalTaskID]),
        [Minutes] = ISNULL(@Minutes, [Minutes]),
        [BillableMinutes] = ISNULL(@BillableMinutes, [BillableMinutes]),
        [EntryCount] = ISNULL(@EntryCount, [EntryCount]),
        [SnapshotHash] = ISNULL(@SnapshotHash, [SnapshotHash]),
        [Status] = ISNULL(@Status, [Status]),
        [DecidedByPersonID] = CASE WHEN @DecidedByPersonID_Clear = 1 THEN NULL ELSE ISNULL(@DecidedByPersonID, [DecidedByPersonID]) END,
        [DecidedAt] = CASE WHEN @DecidedAt_Clear = 1 THEN NULL ELSE ISNULL(@DecidedAt, [DecidedAt]) END,
        [DecisionNotes] = CASE WHEN @DecisionNotes_Clear = 1 THEN NULL ELSE ISNULL(@DecisionNotes, [DecisionNotes]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTimesheetApprovals] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTimesheetApprovals]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTimesheetApproval] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TimesheetApproval table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTimesheetApproval]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTimesheetApproval];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTimesheetApproval
ON [${flyway:defaultSchema}].[TimesheetApproval]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TimesheetApproval]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TimesheetApproval] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Timesheet Approvals */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTimesheetApproval] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTimesheetApproval]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTimesheetApproval];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTimesheetApproval]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TimesheetApproval]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTimesheetApproval] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Timesheet Approvals */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTimesheetApproval] TO [cdp_Developer], [cdp_Integration];

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
-----               SCHEMA:      ${flyway:defaultSchema}
-----               BASE TABLE:  TimeApprover
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTimeApprovers]', 'V') IS NOT NULL
    DROP VIEW [${flyway:defaultSchema}].[vwTimeApprovers];
GO

CREATE VIEW [${flyway:defaultSchema}].[vwTimeApprovers]
AS
SELECT
    t.*,
    mjBizAppsCommonPerson_ApproverPersonID.[DisplayName] AS [ApproverPerson],
    mjBizAppsCommonPerson_WorkerPersonID.[DisplayName] AS [WorkerPerson],
    mjBizAppsTasksTask_ScopeTaskID.[Name] AS [ScopeTask],
    MJEntity_ScopeEntityID.[Name] AS [ScopeEntity]
FROM
    [${flyway:defaultSchema}].[TimeApprover] AS t
INNER JOIN
    [__mj_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_ApproverPersonID
  ON
    [t].[ApproverPersonID] = mjBizAppsCommonPerson_ApproverPersonID.[ID]
LEFT OUTER JOIN
    [__mj_BizAppsCommon].[Person] AS mjBizAppsCommonPerson_WorkerPersonID
  ON
    [t].[WorkerPersonID] = mjBizAppsCommonPerson_WorkerPersonID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Task] AS mjBizAppsTasksTask_ScopeTaskID
  ON
    [t].[ScopeTaskID] = mjBizAppsTasksTask_ScopeTaskID.[ID]
LEFT OUTER JOIN
    [${mjSchema}].[Entity] AS MJEntity_ScopeEntityID
  ON
    [t].[ScopeEntityID] = MJEntity_ScopeEntityID.[ID]
GO
GRANT SELECT ON [${flyway:defaultSchema}].[vwTimeApprovers] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for MJ_BizApps_Tasks: Time Approvers */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: MJ_BizApps_Tasks: Time Approvers
-- Item: Permissions for vwTimeApprovers
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [${flyway:defaultSchema}].[vwTimeApprovers] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spCreateTimeApprover]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spCreateTimeApprover];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spCreateTimeApprover]
    @ID uniqueidentifier = NULL,
    @ApproverPersonID uniqueidentifier,
    @WorkerPersonID_Clear bit = 0,
    @WorkerPersonID uniqueidentifier = NULL,
    @ScopeTaskID_Clear bit = 0,
    @ScopeTaskID uniqueidentifier = NULL,
    @IncludeDescendants bit = NULL,
    @ScopeEntityID_Clear bit = 0,
    @ScopeEntityID uniqueidentifier = NULL,
    @ScopeRecordID_Clear bit = 0,
    @ScopeRecordID nvarchar(450) = NULL,
    @EffectiveFrom_Clear bit = 0,
    @EffectiveFrom date = NULL,
    @EffectiveTo_Clear bit = 0,
    @EffectiveTo date = NULL,
    @IsActive bit = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [${flyway:defaultSchema}].[TimeApprover]
            (
                [ID],
                [ApproverPersonID],
                [WorkerPersonID],
                [ScopeTaskID],
                [IncludeDescendants],
                [ScopeEntityID],
                [ScopeRecordID],
                [EffectiveFrom],
                [EffectiveTo],
                [IsActive],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @ApproverPersonID,
                CASE WHEN @WorkerPersonID_Clear = 1 THEN NULL ELSE ISNULL(@WorkerPersonID, NULL) END,
                CASE WHEN @ScopeTaskID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeTaskID, NULL) END,
                ISNULL(@IncludeDescendants, 1),
                CASE WHEN @ScopeEntityID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeEntityID, NULL) END,
                CASE WHEN @ScopeRecordID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeRecordID, NULL) END,
                CASE WHEN @EffectiveFrom_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveFrom, NULL) END,
                CASE WHEN @EffectiveTo_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveTo, NULL) END,
                ISNULL(@IsActive, 1),
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [${flyway:defaultSchema}].[TimeApprover]
            (
                [ApproverPersonID],
                [WorkerPersonID],
                [ScopeTaskID],
                [IncludeDescendants],
                [ScopeEntityID],
                [ScopeRecordID],
                [EffectiveFrom],
                [EffectiveTo],
                [IsActive],
                [Notes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ApproverPersonID,
                CASE WHEN @WorkerPersonID_Clear = 1 THEN NULL ELSE ISNULL(@WorkerPersonID, NULL) END,
                CASE WHEN @ScopeTaskID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeTaskID, NULL) END,
                ISNULL(@IncludeDescendants, 1),
                CASE WHEN @ScopeEntityID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeEntityID, NULL) END,
                CASE WHEN @ScopeRecordID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeRecordID, NULL) END,
                CASE WHEN @EffectiveFrom_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveFrom, NULL) END,
                CASE WHEN @EffectiveTo_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveTo, NULL) END,
                ISNULL(@IsActive, 1),
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [${flyway:defaultSchema}].[vwTimeApprovers] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTimeApprover] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for MJ_BizApps_Tasks: Time Approvers */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spCreateTimeApprover] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spUpdateTimeApprover]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spUpdateTimeApprover];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spUpdateTimeApprover]
    @ID uniqueidentifier,
    @ApproverPersonID uniqueidentifier = NULL,
    @WorkerPersonID_Clear bit = 0,
    @WorkerPersonID uniqueidentifier = NULL,
    @ScopeTaskID_Clear bit = 0,
    @ScopeTaskID uniqueidentifier = NULL,
    @IncludeDescendants bit = NULL,
    @ScopeEntityID_Clear bit = 0,
    @ScopeEntityID uniqueidentifier = NULL,
    @ScopeRecordID_Clear bit = 0,
    @ScopeRecordID nvarchar(450) = NULL,
    @EffectiveFrom_Clear bit = 0,
    @EffectiveFrom date = NULL,
    @EffectiveTo_Clear bit = 0,
    @EffectiveTo date = NULL,
    @IsActive bit = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TimeApprover]
    SET
        [ApproverPersonID] = ISNULL(@ApproverPersonID, [ApproverPersonID]),
        [WorkerPersonID] = CASE WHEN @WorkerPersonID_Clear = 1 THEN NULL ELSE ISNULL(@WorkerPersonID, [WorkerPersonID]) END,
        [ScopeTaskID] = CASE WHEN @ScopeTaskID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeTaskID, [ScopeTaskID]) END,
        [IncludeDescendants] = ISNULL(@IncludeDescendants, [IncludeDescendants]),
        [ScopeEntityID] = CASE WHEN @ScopeEntityID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeEntityID, [ScopeEntityID]) END,
        [ScopeRecordID] = CASE WHEN @ScopeRecordID_Clear = 1 THEN NULL ELSE ISNULL(@ScopeRecordID, [ScopeRecordID]) END,
        [EffectiveFrom] = CASE WHEN @EffectiveFrom_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveFrom, [EffectiveFrom]) END,
        [EffectiveTo] = CASE WHEN @EffectiveTo_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveTo, [EffectiveTo]) END,
        [IsActive] = ISNULL(@IsActive, [IsActive]),
        [Notes] = CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, [Notes]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [${flyway:defaultSchema}].[vwTimeApprovers] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [${flyway:defaultSchema}].[vwTimeApprovers]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTimeApprover] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the TimeApprover table
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[trgUpdateTimeApprover]', 'TR') IS NOT NULL
    DROP TRIGGER [${flyway:defaultSchema}].[trgUpdateTimeApprover];
GO
CREATE TRIGGER [${flyway:defaultSchema}].trgUpdateTimeApprover
ON [${flyway:defaultSchema}].[TimeApprover]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [${flyway:defaultSchema}].[TimeApprover]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [${flyway:defaultSchema}].[TimeApprover] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for MJ_BizApps_Tasks: Time Approvers */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spUpdateTimeApprover] TO [cdp_Developer], [cdp_Integration];

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
------------------------------------------------------------
IF OBJECT_ID('[${flyway:defaultSchema}].[spDeleteTimeApprover]', 'P') IS NOT NULL
    DROP PROCEDURE [${flyway:defaultSchema}].[spDeleteTimeApprover];
GO

CREATE PROCEDURE [${flyway:defaultSchema}].[spDeleteTimeApprover]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [${flyway:defaultSchema}].[TimeApprover]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTimeApprover] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for MJ_BizApps_Tasks: Time Approvers */

GRANT EXECUTE ON [${flyway:defaultSchema}].[spDeleteTimeApprover] TO [cdp_Developer], [cdp_Integration];

/* SQL text to insert 19 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '93c49e82-2719-4156-aa8a-2645ce9317cc' OR (EntityID = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND Name = 'Task')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '93c49e82-2719-4156-aa8a-2645ce9317cc',
            '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- Entity: MJ_BizApps_Tasks: Task Agent Runs
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
            'Task',
            'Task',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0b1cb8a1-257d-4980-80aa-3654015f2fb1' OR (EntityID = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3' AND Name = 'AIAgentRun')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0b1cb8a1-257d-4980-80aa-3654015f2fb1',
            '03A6558C-487B-4A91-B7C6-0BC1B54A65F3', -- Entity: MJ_BizApps_Tasks: Task Agent Runs
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '03A6558C-487B-4A91-B7C6-0BC1B54A65F3'),
            'AIAgentRun',
            'AI Agent Run',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'f2ca7c2b-347d-44aa-b01e-a7ed26e7aca0' OR (EntityID = 'D594B91D-4DE0-4D20-8D71-21F041FA505D' AND Name = 'Entity')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'f2ca7c2b-347d-44aa-b01e-a7ed26e7aca0',
            'D594B91D-4DE0-4D20-8D71-21F041FA505D', -- Entity: MJ_BizApps_Tasks: Timesheet Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'D594B91D-4DE0-4D20-8D71-21F041FA505D'),
            'Entity',
            'Entity',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '4616ffe0-a43a-48c7-bef1-910f560dada2' OR (EntityID = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND Name = 'Task')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '4616ffe0-a43a-48c7-bef1-910f560dada2',
            '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- Entity: MJ_BizApps_Tasks: Task Timers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
            'Task',
            'Task',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1b8bd14f-5709-461b-991d-454184621fe7' OR (EntityID = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51' AND Name = 'Person')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1b8bd14f-5709-461b-991d-454184621fe7',
            '87C6F7FF-3752-48D2-B382-30B9A4D1CF51', -- Entity: MJ_BizApps_Tasks: Task Timers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '87C6F7FF-3752-48D2-B382-30B9A4D1CF51'),
            'Person',
            'Person',
            NULL,
            'nvarchar',
            500,
            0,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'fbe84ae0-8109-43e3-875e-6ec1278b3316' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = 'ScopeTask')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'fbe84ae0-8109-43e3-875e-6ec1278b3316',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            'ScopeTask',
            'Scope Task',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '159ae0e7-0b53-4c67-95c0-be5e5df4d5f8' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = 'ApprovalTask')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '159ae0e7-0b53-4c67-95c0-be5e5df4d5f8',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            'ApprovalTask',
            'Approval Task',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '6cf66121-2c7f-4838-9b36-c6827c669a27' OR (EntityID = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND Name = 'DecidedByPerson')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '6cf66121-2c7f-4838-9b36-c6827c669a27',
            '02C38B1A-6987-463D-8B6B-4C86E0887D42', -- Entity: MJ_BizApps_Tasks: Timesheet Approvals
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '02C38B1A-6987-463D-8B6B-4C86E0887D42'),
            'DecidedByPerson',
            'Decided By Person',
            NULL,
            'nvarchar',
            500,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2c5fc472-6a98-42c4-b0c6-2b3aa529c0c3' OR (EntityID = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND Name = 'Person')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2c5fc472-6a98-42c4-b0c6-2b3aa529c0c3',
            'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- Entity: MJ_BizApps_Tasks: Timesheets
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
            'Person',
            'Person',
            NULL,
            'nvarchar',
            500,
            0,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'd98d52d7-a33a-43fc-aeff-1b2255a297c3' OR (EntityID = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND Name = 'SubmittedByUser')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd98d52d7-a33a-43fc-aeff-1b2255a297c3',
            'ED90EE09-0D39-4298-93DC-77C057FCE97A', -- Entity: MJ_BizApps_Tasks: Timesheets
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A'),
            'SubmittedByUser',
            'Submitted By User',
            NULL,
            'nvarchar',
            200,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'a3a97216-e31f-4599-b84c-9ee673e76515' OR (EntityID = '5A25B67B-D67D-453F-8340-94BF69CF8CEE' AND Name = 'Entity')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'a3a97216-e31f-4599-b84c-9ee673e76515',
            '5A25B67B-D67D-453F-8340-94BF69CF8CEE', -- Entity: MJ_BizApps_Tasks: Task Time Entry Links
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '5A25B67B-D67D-453F-8340-94BF69CF8CEE'),
            'Entity',
            'Entity',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '73b0b7c5-fc7f-4254-b4a4-bfadbd47c74f' OR (EntityID = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND Name = 'Person')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '73b0b7c5-fc7f-4254-b4a4-bfadbd47c74f',
            '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- Entity: MJ_BizApps_Tasks: Timesheet Schedules
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
            'Person',
            'Person',
            NULL,
            'nvarchar',
            500,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '0c906264-ec3d-4e70-9bfe-e0b6d90a2cd7' OR (EntityID = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND Name = 'ScopeEntity')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '0c906264-ec3d-4e70-9bfe-e0b6d90a2cd7',
            '6A27830F-A203-4D3E-8ADF-B1085E1F908C', -- Entity: MJ_BizApps_Tasks: Timesheet Schedules
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C'),
            'ScopeEntity',
            'Scope Entity',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = 'cc0edc1e-0322-4974-8f85-9d6c0d066070' OR (EntityID = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND Name = 'Task')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'cc0edc1e-0322-4974-8f85-9d6c0d066070',
            'EA40801A-DF1B-443A-B0D3-EA0415645603', -- Entity: MJ_BizApps_Tasks: Task Time Entries
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
            'Task',
            'Task',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '2d457cbe-bb88-4e3b-bc1b-2fa99139c399' OR (EntityID = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND Name = 'Person')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2d457cbe-bb88-4e3b-bc1b-2fa99139c399',
            'EA40801A-DF1B-443A-B0D3-EA0415645603', -- Entity: MJ_BizApps_Tasks: Task Time Entries
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'EA40801A-DF1B-443A-B0D3-EA0415645603'),
            'Person',
            'Person',
            NULL,
            'nvarchar',
            500,
            0,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '9f773da1-6235-49d5-ba9d-1fbd466be64c' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = 'ApproverPerson')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '9f773da1-6235-49d5-ba9d-1fbd466be64c',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            'ApproverPerson',
            'Approver Person',
            NULL,
            'nvarchar',
            500,
            0,
            0,
            0,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '05a327a0-e5da-422a-a9d4-0c0da669f5b6' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = 'WorkerPerson')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '05a327a0-e5da-422a-a9d4-0c0da669f5b6',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            'WorkerPerson',
            'Worker Person',
            NULL,
            'nvarchar',
            500,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '08912325-9de8-41c5-a838-16dbe5e5395b' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = 'ScopeTask')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '08912325-9de8-41c5-a838-16dbe5e5395b',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            'ScopeTask',
            'Scope Task',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${mjSchema}].[EntityField] WHERE ID = '1a236b60-be82-457d-9a37-724d713f2d51' OR (EntityID = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND Name = 'ScopeEntity')) BEGIN
         INSERT INTO [${mjSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '1a236b60-be82-457d-9a37-724d713f2d51',
            'C82F6EF9-B9C4-4387-8C10-F5B59FA24133', -- Entity: MJ_BizApps_Tasks: Time Approvers
            (SELECT COALESCE(MAX([Sequence]), 0) + 1 FROM [${mjSchema}].[EntityField] WHERE [EntityID] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133'),
            'ScopeEntity',
            'Scope Entity',
            NULL,
            'nvarchar',
            510,
            0,
            0,
            1,
            NULL,
            0,
            0,
            1,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

/* SQL text to update existing entity fields from schema (11 scoped entities) */
EXEC [${mjSchema}].[spUpdateExistingEntityFieldsFromSchema] @ExcludedSchemaNames='', @EntityIDs='EA40801A-DF1B-443A-B0D3-EA0415645603,87C6F7FF-3752-48D2-B382-30B9A4D1CF51,03A6558C-487B-4A91-B7C6-0BC1B54A65F3,ED90EE09-0D39-4298-93DC-77C057FCE97A,02C38B1A-6987-463D-8B6B-4C86E0887D42,C82F6EF9-B9C4-4387-8C10-F5B59FA24133,D594B91D-4DE0-4D20-8D71-21F041FA505D,5A25B67B-D67D-453F-8340-94BF69CF8CEE,6A27830F-A203-4D3E-8ADF-B1085E1F908C,1E30141A-826F-4278-BAA9-BBE14D29E606,B348FFA2-B1A7-4AC2-B6FD-F4E0C0697466', @IncludedSchemaNames='${flyway:defaultSchema}';

/* SQL text to set default column width where needed */
EXEC [${mjSchema}].[spSetDefaultColumnWidthWhereNeeded] @ExcludedSchemaNames='', @IncludedSchemaNames='${flyway:defaultSchema}';

/* Refresh custom base views for modified entities so schema changes are picked up */
EXEC sp_refreshview '${flyway:defaultSchema}.vwTasksGenerated';
IF OBJECT_ID('[${flyway:defaultSchema}].[vwTasks]', 'V') IS NOT NULL
BEGIN
    EXEC sp_executesql N'EXEC sp_refreshview ''${flyway:defaultSchema}.vwTasks'';';
END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Task Time Entries */
-- CHECK constraint for MJ_BizApps_Tasks: Task Time Entries: Field: Minutes was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = 'A4B7B796-99D1-4283-BC8A-94F6DCD24F4F'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('4d68f0b7-5e82-46cb-8f6d-cf5206324661', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([Minutes]>(0) AND [Minutes]<=(1440))', 'public ValidateMinutesRange(result: ValidationResult) {
	if (this.Minutes != null && (this.Minutes <= 0 || this.Minutes > 1440)) {
		result.Errors.push(new ValidationErrorInfo(
			"Minutes",
			"Minutes worked must be greater than 0 and cannot exceed 1440 (24 hours).",
			this.Minutes,
			ValidationErrorType.Failure
		));
	}
}', 'Minutes worked must be greater than 0 and cannot exceed 1,440 minutes (24 hours) in a single entry.', 'ValidateMinutesRange', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', 'A4B7B796-99D1-4283-BC8A-94F6DCD24F4F')
   END;

-- CHECK constraint for MJ_BizApps_Tasks: Task Time Entries @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = 'EA40801A-DF1B-443A-B0D3-EA0415645603' AND [Name] = 'ValidateEndedAtOnOrAfterStartedAt'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('06e594ab-c050-4f25-9c59-6247458dabb9', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([StartedAt] IS NULL OR [EndedAt] IS NULL OR [EndedAt]>=[StartedAt])', 'public ValidateEndedAtOnOrAfterStartedAt(result: ValidationResult) {
	if (this.StartedAt != null && this.EndedAt != null && new Date(this.EndedAt).getTime() < new Date(this.StartedAt).getTime()) {
		result.Errors.push(new ValidationErrorInfo(
			"EndedAt",
			"End time must be on or after the start time.",
			this.EndedAt,
			ValidationErrorType.Failure
		));
	}
}', 'If both start and end times are recorded, the end time must be at or after the start time.', 'ValidateEndedAtOnOrAfterStartedAt', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'EA40801A-DF1B-443A-B0D3-EA0415645603')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Time Approvers */
-- CHECK constraint for MJ_BizApps_Tasks: Time Approvers @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND [Name] = 'ValidateEffectiveToOnOrAfterEffectiveFrom'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('a0801bd1-273f-4a08-b7c8-fdff05499bbd', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([EffectiveFrom] IS NULL OR [EffectiveTo] IS NULL OR [EffectiveTo]>=[EffectiveFrom])', 'public ValidateEffectiveToOnOrAfterEffectiveFrom(result: ValidationResult) {
	if (this.EffectiveFrom != null && this.EffectiveTo != null && this.EffectiveTo < this.EffectiveFrom) {
		result.Errors.push(new ValidationErrorInfo(
			"EffectiveTo",
			"Effective To date must be on or after the Effective From date.",
			this.EffectiveTo,
			ValidationErrorType.Failure
		));
	}
}', 'The effective end date must be on or after the effective start date when both dates are provided.', 'ValidateEffectiveToOnOrAfterEffectiveFrom', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133')
   END;

-- CHECK constraint for MJ_BizApps_Tasks: Time Approvers @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND [Name] = 'ValidateScopeEntityAndRecordPair'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('ecf8dd64-969b-40e3-8dd3-f258b6156f47', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([ScopeEntityID] IS NULL AND [ScopeRecordID] IS NULL OR [ScopeEntityID] IS NOT NULL AND [ScopeRecordID] IS NOT NULL)', '	public ValidateScopeEntityAndRecordPair(result: ValidationResult) {
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
	}', 'Scope entity and scope record must either both be specified or both be left empty to ensure consistent scoping.', 'ValidateScopeEntityAndRecordPair', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133')
   END;

-- CHECK constraint for MJ_BizApps_Tasks: Time Approvers @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133' AND [Name] = 'ValidateWorkerPersonIDNotEqualToApproverPersonID'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('ac25be0a-e5d9-4e19-bb6e-299226e53b5b', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([WorkerPersonID] IS NULL OR [WorkerPersonID]<>[ApproverPersonID])', 'public ValidateWorkerPersonIDNotEqualToApproverPersonID(result: ValidationResult) {
	if (this.WorkerPersonID != null && this.WorkerPersonID === this.ApproverPersonID) {
		result.Errors.push(new ValidationErrorInfo(
			"WorkerPersonID",
			"The worker cannot be the same person as the approver.",
			this.WorkerPersonID,
			ValidationErrorType.Failure
		));
	}
}', 'The worker person cannot be the same as the approver person.', 'ValidateWorkerPersonIDNotEqualToApproverPersonID', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'C82F6EF9-B9C4-4387-8C10-F5B59FA24133')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Timesheet Approvals */
-- CHECK constraint for MJ_BizApps_Tasks: Timesheet Approvals: Field: SubmissionRound was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'DF238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = 'BDBEC7EF-0A27-480E-8DD3-B1697358CF3A'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('d785b476-2c17-48c0-80aa-161448170f7a', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([SubmissionRound]>=(1))', '	public ValidateSubmissionRoundMinimum(result: ValidationResult) {
		if (this.SubmissionRound != null && this.SubmissionRound < 1) {
			result.Errors.push(new ValidationErrorInfo(
				"SubmissionRound",
				"Submission round must be at least 1.",
				this.SubmissionRound,
				ValidationErrorType.Failure
			));
		}
	}', 'Submission round must be 1 or greater.', 'ValidateSubmissionRoundMinimum', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', 'BDBEC7EF-0A27-480E-8DD3-B1697358CF3A')
   END;

-- CHECK constraint for MJ_BizApps_Tasks: Timesheet Approvals @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = '02C38B1A-6987-463D-8B6B-4C86E0887D42' AND [Name] = 'ValidateTimesheetMinutesAndEntryCount'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('5dee8e6a-e17e-4e11-a81f-e5e5568e865c', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([Minutes]>=(0) AND [BillableMinutes]>=(0) AND [BillableMinutes]<=[Minutes] AND [EntryCount]>=(0))', 'public ValidateTimesheetMinutesAndEntryCount(result: ValidationResult) {
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
}', 'Minutes, billable minutes, and entry count must all be non-negative (zero or greater), and billable minutes cannot exceed the total minutes recorded.', 'ValidateTimesheetMinutesAndEntryCount', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '02C38B1A-6987-463D-8B6B-4C86E0887D42')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Timesheet Schedules */
-- CHECK constraint for MJ_BizApps_Tasks: Timesheet Schedules @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND [Name] = 'ValidateEffectiveToOnOrAfterEffectiveFrom'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('e2cb08d9-6e2c-41d6-ae13-c31c1406eefd', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([EffectiveTo] IS NULL OR [EffectiveTo]>=[EffectiveFrom])', 'public ValidateEffectiveToOnOrAfterEffectiveFrom(result: ValidationResult) {
	if (this.EffectiveTo != null && this.EffectiveFrom != null && this.EffectiveTo < this.EffectiveFrom) {
		result.Errors.push(new ValidationErrorInfo(
			"EffectiveTo",
			"Effective To date must be on or after the Effective From date.",
			this.EffectiveTo,
			ValidationErrorType.Failure
		));
	}
}', 'Effective to date must be on or after the effective from date, ensuring the validity period is chronologically correct.', 'ValidateEffectiveToOnOrAfterEffectiveFrom', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '6A27830F-A203-4D3E-8ADF-B1085E1F908C')
   END;

-- CHECK constraint for MJ_BizApps_Tasks: Timesheet Schedules @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND [Name] = 'ValidatePersonIDAndScopeEntityIDMutualExclusivity'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('deddd970-bb49-4b24-8b7a-705312645809', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([PersonID] IS NULL OR [ScopeEntityID] IS NULL)', '	public ValidatePersonIDAndScopeEntityIDMutualExclusivity(result: ValidationResult) {
		if (this.PersonID != null && this.ScopeEntityID != null) {
			result.Errors.push(new ValidationErrorInfo(
				"PersonID",
				"A record cannot have both a Person and a Scope Entity specified.",
				this.PersonID,
				ValidationErrorType.Failure
			));
		}
	}', 'A record cannot be assigned to both a specific person and a scope entity at the same time; at least one of these assignments must remain empty.', 'ValidatePersonIDAndScopeEntityIDMutualExclusivity', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '6A27830F-A203-4D3E-8ADF-B1085E1F908C')
   END;

-- CHECK constraint for MJ_BizApps_Tasks: Timesheet Schedules @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = '6A27830F-A203-4D3E-8ADF-B1085E1F908C' AND [Name] = 'ValidateScopeEntityIDAndScopeRecordIDCoexistence'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('03bc9ac8-7625-454b-abc1-f20b8987ea2e', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([ScopeEntityID] IS NULL AND [ScopeRecordID] IS NULL OR [ScopeEntityID] IS NOT NULL AND [ScopeRecordID] IS NOT NULL)', 'public ValidateScopeEntityIDAndScopeRecordIDCoexistence(result: ValidationResult) {
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
}', 'Scope entity and scope record must either both be provided or both be left empty.', 'ValidateScopeEntityIDAndScopeRecordIDCoexistence', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '6A27830F-A203-4D3E-8ADF-B1085E1F908C')
   END;

/* Generated Validation Functions for MJ_BizApps_Tasks: Timesheets */
-- CHECK constraint for MJ_BizApps_Tasks: Timesheets @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND [Name] = 'ValidatePeriodEndOnOrAfterPeriodStart'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('3a1c7393-0742-4cdf-940d-c4919d4d4311', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([PeriodEnd]>=[PeriodStart])', 'public ValidatePeriodEndOnOrAfterPeriodStart(result: ValidationResult) {
	if (this.PeriodStart != null && this.PeriodEnd != null && this.PeriodEnd < this.PeriodStart) {
		result.Errors.push(new ValidationErrorInfo(
			"PeriodEnd",
			"The period end date must be on or after the period start date.",
			this.PeriodEnd,
			ValidationErrorType.Failure
		));
	}
}', 'Period end date must be on or after the period start date.', 'ValidatePeriodEndOnOrAfterPeriodStart', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'ED90EE09-0D39-4298-93DC-77C057FCE97A')
   END;

-- CHECK constraint for MJ_BizApps_Tasks: Timesheets @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
IF NOT EXISTS (
      SELECT 1 FROM [${mjSchema}].[GeneratedCode] WHERE [CategoryID] = (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators') AND [LinkedEntityID] = 'E0238F34-2837-EF11-86D4-6045BDEE16E6' AND [LinkedRecordPrimaryKey] = 'ED90EE09-0D39-4298-93DC-77C057FCE97A' AND [Name] = 'ValidateTotalAndBillableMinutes'
   )
   BEGIN
      INSERT INTO [${mjSchema}].[GeneratedCode] ([ID], [CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
VALUES ('a79faf46-3ce9-45c1-811c-83495b1c93c0', (SELECT [ID] FROM [${mjSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4B500A24-0259-4EFF-9E34-24E9F5EC9DAB', GETUTCDATE(), 'TypeScript', 'Approved', '([TotalMinutes]>=(0) AND [BillableMinutes]>=(0) AND [BillableMinutes]<=[TotalMinutes])', 'public ValidateTotalAndBillableMinutes(result: ValidationResult) {
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
}', 'Total minutes and billable minutes must both be zero or positive, and billable minutes cannot exceed total minutes.', 'ValidateTotalAndBillableMinutes', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', 'ED90EE09-0D39-4298-93DC-77C057FCE97A')
   END;

