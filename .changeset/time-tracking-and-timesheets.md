---
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-actions": minor
"@mj-biz-apps/tasks-server": minor
"@mj-biz-apps/tasks-ng": minor
---

Add end-to-end Time Tracking, AI Agent Effort attribution, and Timesheets with per-project approval workflows:

- **Schema & Entities**: 9 new entities (`TaskTimeEntry`, `TaskTimer`, `TaskAgentRun`, `Timesheet`, `TimesheetApproval`, `TimeApprover`, `TimesheetLink`, `TaskTimeEntryLink`, `TimesheetSchedule`), `TaskType.RequiresAssigneeDecision`, and `vwTasks` virtual effort columns (`LoggedMinutes`, `AgentRunCount`, `AgentCost`, `AgentTokens`).
- **Core (`@mj-biz-apps/tasks-core`)**: Shared `TasksSettings` reader, pure functions for business-day timer splitting, period calculation across `Weekly`/`BiWeekly`/`SemiMonthly`/`Monthly` cadences, time-entry lock refusal, ancestor-deduplicated agent run rollups, approver resolution, deterministic SHA-256 part snapshot hashing, and `TimeTrackingService`.
- **Server (`@mj-biz-apps/tasks-entities-server`, `@mj-biz-apps/tasks-actions`, `@mj-biz-apps/tasks-server`)**: `BaseTimeApproverResolver` extension point, 9 server entity classes, `LinkAgentRunToTaskAction`, 6 transactional Remote Operations (`Tasks.StartTimer`, `Tasks.StopTimer`, `Tasks.GetTaskEffort`, `Tasks.SubmitTimesheet`, `Tasks.WithdrawTimesheet`, `Tasks.ReopenTimesheet`), and `TimesheetApprovalReconcileJob`.
- **Angular (`@mj-biz-apps/tasks-ng`)**: Running-timer header chip, Start/Stop timer controls, Log Time dialog, Task Effort section + Link Agent Run dialog, Task Time form panel, `MyTimeSectionResource` weekly & period timesheet view, `TimeApproversComponent`, and `BaseApprovalSubjectPanel` + `TimesheetPartApprovalPanelComponent`.
