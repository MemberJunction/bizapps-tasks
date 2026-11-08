# @mj-biz-apps/tasks-server

Server runtime bootstrap, Remote Operations (`BaseRemoteOperation`), GraphQL resolvers, and scheduled background jobs for BizApps Tasks.

## Exports

### Bootstrap & Background Jobs
- `LoadBizAppsTasksServer()`: Server bootstrap loader registering entity server subclasses, actions, Remote Operations, notification handlers, and scheduled jobs.
- `OverdueTaskNotificationJob`: Scheduled job detecting overdue tasks, raising notification events, and sweeping stale `Pending` timesheet approval parts (`ReconcileStaleTimesheetApprovals`).
- `TaskNotificationHandler`: Event listener reacting to task assignment and state changes.

### Remote Operations (`BaseRemoteOperation` Subclasses)
All 6 time-tracking and timesheet operations are registered via `@RegisterClass(BaseRemoteOperation, ...)` and exposed over `ExecuteRemoteOperation`:
- `TasksStartTimerOperation` (`Tasks.StartTimer`): Starts a timer on a task, stopping any existing running timer for the person in the same transaction.
- `TasksStopTimerOperation` (`Tasks.StopTimer`): Stops a running timer, splitting cross-midnight spans by business day or discarding short timers under `DiscardIfUnderSeconds`.
- `TasksSubmitTimesheetOperation` (`Tasks.SubmitTimesheet`): Submits a period timesheet, partitioning entries by root project, resolving approvers, and creating `TIMESHEET_APPROVAL` tasks.
- `TasksWithdrawTimesheetOperation` (`Tasks.WithdrawTimesheet`): Withdraws a `Submitted` timesheet back to `Draft` and cancels pending approval tasks.
- `TasksReopenTimesheetOperation` (`Tasks.ReopenTimesheet`): Reopens an `Approved` timesheet back to `Draft` (requires `Tasks: Manage Timesheets` and a non-empty `Reason`, audited in `TaskActivity`).
- `TasksGetTaskEffortOperation` (`Tasks.GetTaskEffort`): Returns deduplicated direct and subtree human minutes, billable minutes, and AI agent run count, duration, tokens, and cost for a task.
