# @mj-biz-apps/tasks-entities-server

Authoritative server-side entity subclasses and approval engines for BizApps Tasks.

## Entity Server Subclasses

- `TaskEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Tasks')`)
  - **Dynamic Status Synchronization**: Auto-syncs `TaskTypeStatusID` $\leftrightarrow$ `Status` (`MacroStatus`) and auto-assigns default stage on task creation.
  - **Terminal Completion**: Automatically populates `CompletedAt` and sets `PercentComplete = 100` upon entering terminal statuses.
  - **Audit Logging**: Writes server-authoritative `Task Activities` on creation, status change, progress update, priority change, and due date changes.
  - **Subtask Progress Rollup**: Reconciles parent progress upon child save.
  - **Time Entry Delete Guard**: Refuses deleting a task that has logged `TaskTimeEntry` rows, reporting the exact entry count.
  - **Timesheet Approval Outcome Reconciliation**: When a task of type `TIMESHEET_APPROVAL` reaches a terminal status (`Completed`, `Cancelled`, `Blocked`), updates its `TimesheetApproval` part and parent `Timesheet` inside the save pipeline.
  - **Lifecycle Action Hooks**: Dispatches asynchronous, non-blocking Action execution for `OnCreateActionID`, `OnStatusChangeActionID`, `OnEnterActionID`, `OnExitActionID`, `OnCompleteActionID`, `OnCancelActionID`, `OnRejectActionID`, and `OnPercentChangeActionID`.
- `TaskDecisionEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Decisions')`)
  - Enforces the no-self-approval rule (`D13`) against both `Task.CreatedByPersonID` and `Timesheet.PersonID` (for `TIMESHEET_APPROVAL` tasks), and requires deciders to be assigned approvers when the task has assignments.
- `TaskTimeEntryEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Time Entries')`)
  - Enforces `TimeTrackingEnabled`, `R1`–`R8` validation rules, ownership vs. `Tasks: Manage Time Entries` authorization, timesheet period locks (`R6`/`R7`), and `TaskTimeEntryLink` locks (`R8`).
- `TaskTimerEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Timers')`)
  - Enforces timer ownership (`PersonID`) and `Tasks: Manage Time Entries` override on save and delete.
- `TaskAgentRunEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Agent Runs')`)
  - Validates that the caller started the `AIAgentRun` (or holds `Tasks: Manage Time Entries`) and prevents double-counting (`A2`/`D7`) by pruning descendant run links when an ancestor run is linked or no-oping when an ancestor is already linked.
- `TaskTimeEntryLinkEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Time Entry Links')`)
- `TimesheetLinkEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Timesheet Links')`)
- `TimesheetScheduleEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Timesheet Schedules')`)
- `TimeApproverEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Time Approvers')`)

## Server Services & Extension Points

- `TaskTimerServer`: Transactional `StartTimer` (stopping any previous running timer in the same transaction) and `StopTimer` (splitting cross-midnight timers by business day in `BusinessTimeZoneEngine`).
- `TimesheetEngine` (`BaseSingleton`): Implements `SubmitTimesheet`, `WithdrawTimesheet`, `ReopenTimesheet`, `GetTaskEffort`, and `ReconcileStaleTimesheetApprovals`.
- `BaseTimeApproverResolver`: `ClassFactory` extension point allowing downstream BizApps to resolve external parent scopes for a task (`ResolveScopesForTask`). Ships with `TaskLinkScopeApproverResolver` (`@RegisterClass(BaseTimeApproverResolver, 'TaskLinkScopeApproverResolver', 50)`).
- `UserHasTasksAuthorization`: Evaluates hierarchical `Tasks: Manage Time Entries` and `Tasks: Manage Timesheets` authorizations.
