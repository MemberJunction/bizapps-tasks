# @mj-biz-apps/tasks-core

Client- and server-safe core services, settings, and pure business logic for BizApps Tasks.

## Exports

### Task Services
- `TaskService`: Progress calculation, parent rollup reconciliation, and task queries.
- `TaskAssignmentService`: Polymorphic assignee management for people and AI agents.
- `TaskTemplateService`: Multi-item template instantiation with dependency offsetting.
- `TaskOrchestrationService`: Task decision workflows, approval task creation, and stage transition orchestration.

### Application Settings (`TasksSettings`)
- `TasksSettings`: Client- and server-safe reader over `ApplicationSettingEngine` for all Tasks application settings:
  - `IsTimeTrackingEnabled()`, `IsTimesheetsEnabled()`
  - `GetTimesheetCadence()`, `GetTimesheetWeekStartDay()`, `GetTimesheetBiWeeklyAnchorDate()`
  - `GetTimesheetApprovalRouting()`, `IsLockApprovedTimeEntriesEnabled()`
  - `GetMaxDailyLoggedMinutes()`, `GetTimeEntryRoundingMinutes()`
  - `IsTimesheetSchedulesSelfServiceEnabled()`, `IsTimesheetResubmitReapprovesAllEnabled()`
  - `GetTimesheetApproverRelationshipType()`, `GetTimesheetApproverRole()`

### Time Entry & Agent Effort Rules
- `ValidateAndNormalizeTimeEntry()` (`TimeEntryRules`): Pure R1–R8 validation, timestamp-to-duration derivation (`R4`), increment rounding (`R3`), daily cap validation (`R5`), timesheet period lock checks (`R6`/`R7`), and external record link lock checks (`R8`).
- `SplitTimerSpanByBusinessDay()`: Cross-midnight timer span splitter in the business time zone (`D5`).
- `FormatDurationMinutes()`, `ParseDurationInput()`, `RoundMinutesUp()`: Duration formatting and parsing utilities (`1h 30m`, `1:30`, `1.5`, `90m`).
- `ComputeAgentRunRollup()`, `ClassifyAgentRunLinkCandidate()`: Deduplicated AI agent run cost/token/duration rollups (`COALESCE(TotalCostRollup, TotalCost)`) and ancestor/descendant overlap classification (`A2`, `D7`).

### Timesheet Periods (`TimesheetPeriodService`)
- `ComputeCalendarPeriod()`: Pure period calculator for `Weekly`, `BiWeekly`, `SemiMonthly`, and `Monthly` cadences.
- `ApplyTransitionFloor()`: Non-overlapping transition period adjustment when a person's schedule changes after a submitted timesheet (`D11`).
- `TimesheetPeriodService`: Resolves a person's effective `TimesheetSchedule` and covering `Timesheet` period.
