# @mj-biz-apps/tasks-entities

Strongly-typed entity models and validation classes for BizApps Tasks.

## Entities

### Core Task & Workflow Entities
- `TaskEntity` (`MJ_BizApps_Tasks: Tasks`) — Primary task entity with cycle detection, status transition validation, `ApproverPersonID`, and rollup fields (`LoggedMinutes`, `BillableMinutes`, `TotalLoggedMinutes`, `TotalBillableMinutes`, `AgentRunCount`, `AgentTotalCost`).
- `TaskTypeEntity` (`MJ_BizApps_Tasks: Task Types`) — Work item classification with unique `Code` (including `TIMESHEET_APPROVAL`), `IsApproval`, and lifecycle action hooks (`OnCreateActionID`, `OnStatusChangeActionID`).
- `TaskTypeStatusEntity` (`MJ_BizApps_Tasks: Task Type Status`) — Dynamic domain stages per task type with `MacroStatus`, `Sequence`, `IsDefault`, `IsTerminal`, and stage action hooks (`OnEnterActionID`, `OnExitActionID`).
- `TaskCategoryEntity` (`MJ_BizApps_Tasks: Task Categories`) — Hierarchical task categories.
- `TaskAssignmentEntity` (`MJ_BizApps_Tasks: Task Assignments`) — Polymorphic task assignment (`AssigneeEntityID` + `AssigneeRecordID`).
- `TaskDependencyEntity` (`MJ_BizApps_Tasks: Task Dependencies`) — Graph edges between tasks with cycle validation.
- `TaskDecisionEntity` (`MJ_BizApps_Tasks: Task Decisions`) — Approval and decision outcomes.
- `TaskTemplateEntity` (`MJ_BizApps_Tasks: Task Templates`) — Reusable task structures.
- `TaskActivityEntity` (`MJ_BizApps_Tasks: Task Activities`) — Server-authoritative audit log.

### Time Tracking, AI Agent Effort & Timesheet Entities
- `mjBizAppsTasksTaskTimeEntryEntity` (`MJ_BizApps_Tasks: Task Time Entries`) — Completed human time entries (`TaskID`, `PersonID`, `WorkDate`, `Minutes`, `IsBillable`, `Source`, `SourceSystem`, `ExternalID`).
- `mjBizAppsTasksTaskTimerEntity` (`MJ_BizApps_Tasks: Task Timers`) — Running task timers (at most one per `PersonID` via filtered unique index).
- `mjBizAppsTasksTaskAgentRunEntity` (`MJ_BizApps_Tasks: Task Agent Runs`) — Links `MJ: AI Agent Runs` to tasks for autonomous effort and cost rollups.
- `mjBizAppsTasksTaskTimeEntryLinkEntity` (`MJ_BizApps_Tasks: Task Time Entry Links`) — Polymorphic external record links (`LinkedEntityID` + `LinkedRecordID`) that lock referenced time entries (`R8`).
- `mjBizAppsTasksTimesheetScheduleEntity` (`MJ_BizApps_Tasks: Timesheet Schedules`) — Per-person period cadence overrides (`Weekly`, `BiWeekly`, `SemiMonthly`, `Monthly`).
- `mjBizAppsTasksTimesheetEntity` (`MJ_BizApps_Tasks: Timesheets`) — Period timesheets (`Draft`, `Submitted`, `Approved`, `Rejected`).
- `mjBizAppsTasksTimesheetApprovalEntity` (`MJ_BizApps_Tasks: Timesheet Approvals`) — Per-project/scope approval parts within a `Timesheet` submission round.
- `mjBizAppsTasksTimesheetLinkEntity` (`MJ_BizApps_Tasks: Timesheet Links`) — Polymorphic external record links (`LinkedEntityID` + `LinkedRecordID`) on timesheets.
- `mjBizAppsTasksTimeApproverEntity` (`MJ_BizApps_Tasks: Time Approvers`) — Polymorphic time approver rules (`ScopeEntityID` + `ScopeRecordID`, `IncludeDescendants`).
