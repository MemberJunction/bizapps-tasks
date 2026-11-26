# @mj-biz-apps/tasks-core

Client- and server-safe core services, settings, and pure business logic for BizApps Tasks.

## Exports

### Task Services
- `TaskService`: Progress calculation, parent rollup reconciliation, and task queries.
- `TaskAssignmentService`: Polymorphic assignee management for people and AI agents.
- `TaskTemplateService`: Multi-item template instantiation with dependency offsetting.
- `TaskOrchestrationService`: Task decision workflows, approval task creation, and stage transition orchestration.
- `MeetingService`: a meeting from a type (the type's length, location, visibility and agenda template), its attendees and links, and the organizer's moves: start, end, cancel. The rules are the entity server's; the service reports its refusal.
- `MeetingSeriesService`: a series' occurrences, made ahead of time up to a horizon and named by their slot; an untouched future occurrence takes the series' current values and the attendees and links it gained, and moves with the series when its time or rule changes (keeping its identity, agenda and answers) rather than being cancelled and remade: on its own day when the time changed, to the nearest new slot in order when the weekday did; a moved, started or cancelled one is left alone; one whose slot is gone with no new slot to take is cancelled; a cancelled series cancels every occurrence not yet held, moved or not; one materialization per series at a time.
- `MeetingAgendaService`: the type's template applied to a meeting's agenda, items reordered, and unfinished items carried forward to the next meeting.
- `MeetingCalendarFile`: the meeting as an `.ics` file (REQUEST or CANCEL), built on the server with no calendar provider.

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

### Task Workspace Helpers & Remotable Operations (`src/tasks`)
- `TasksBulkUpdateOperation` (`BizAppsTasks.BulkUpdateTasks`): Typed `BaseRemotableOperation` shell for server-side bulk updates (Reassign People/MJ Roles, Redate exact/shift ±N days/clear, Status, Priority, Organization, Category, Start Date, Task Type, Workflow Stage, and idempotent Tag linking).
- `TasksInstantiateTemplateOperation` (`BizAppsTasks.InstantiateTemplate`): Typed `BaseRemotableOperation` shell for server-side hierarchical playbook template instantiation with relative offsets, role mappings, dependencies, and target `OrganizationID`.
- `ParseQuickTaskInput`: Natural-language task parser (`tomorrow`, `@Assignee`, `#Tag`, `!priority`, `~2h`).
- `ClassifyTaskHorizon`, `ComputeTaskUrgencyCounts`, `ComputeChildRollups`, `ComputeCriticalPathTaskIds`, `GroupTasksIntoMilestones`: Pure workspace bucketing, WBS rollup, DAG critical-path, and mobile milestone helpers.
- `MatchesDueDateFilter`, `MatchesAssigneeFilter`: Unified Due Date (`overdue`, `today`, `week`, `month`, `none`) and Assignee (`__me__`, `__unassigned__`, `person:<id>`, `role:<id>`) predicates shared across Tree List, Board, and Gantt Timeline.

### MJ Docs Dual-Read Resolution (`ArtifactDualReadResolver`)
- `ArtifactDualReadResolver` (`BaseSingleton<ArtifactDualReadResolver>`): Batched dual-read resolver for `WorkReport` (Category A) and `MeetingNote` (Category B) records carrying nullable `ArtifactID` FKs to `MJ: Artifacts`.
  - `ResolveBatch(records, options)` / `ResolveSingle(record, options)`: Deduplicates and validates UUIDs (`ValidateAndDeduplicateArtifactIDs`), chunks SQL `IN (...)` filters via `TasksLimitsResolver.Instance.GetCurrentLimits().ResourceGuards.SqlInClauseChunkSize`, queries `MJ: Artifacts` and latest `MJ: Artifact Versions` with `ResultType: 'simple'` (propagating `ContextUser`), supports header-only mode (`IncludeContent: false`), and falls back deterministically to legacy `Body` (`no_artifact_id`, `invalid_artifact_id`, `artifact_not_accessible`, `version_not_accessible`, `empty_artifact_content`).
  - `WorkReportService` view models expose `ArtifactID`, `ArtifactName`, `ArtifactVersionNumber`, and `ResolvedContentSource` alongside preserved `Body`.

## The meetings rules (`src/meetings`)

Pure functions the services and the entity servers share: `meetingStatusMoveAllowed` and friends (Draft → Scheduled → InProgress → Completed; Scheduled and Postponed either way; anything but Completed can be Cancelled), `meetingTimeProblem` and `isValidTimeZone`, `expandOccurrences` (an RFC 5545 RRULE run over wall-clock times in the series' IANA zone, through `rrule` and `luxon`), `agendaParentProblem`, `orderAgenda` and `agendaDurationTotal`, `parseAgendaTemplate`, `buildMeetingIcs` (escaped, folded at 75 octets), `personIdForUser` / `userIdForPerson` (the user's own link to People first, the deprecated `People.LinkedUserID` second), and `callerAdministersMeetings`.
