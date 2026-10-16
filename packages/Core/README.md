# @mj-biz-apps/tasks-core

Core services and business logic for BizApps Tasks.

## Services

- `TaskService`: Progress calculation, parent rollup reconciliation, and task queries.
- `TaskAssignmentService`: Polymorphic assignee management for people and AI agents.
- `TaskTemplateService`: Multi-item template instantiation with dependency offsetting.
- `TaskOrchestrationService`: Task decision workflows and stage transition orchestration.
- `MeetingService`: a meeting from a type (the type's length, location, visibility and agenda template), its attendees and links, and the organizer's moves: start, end, cancel. The rules are the entity server's; the service reports its refusal.
- `MeetingSeriesService`: a series' occurrences, made ahead of time up to a horizon and named by their slot; an untouched future occurrence takes the series' current values and the attendees and links it gained; a moved, started or cancelled one is left alone; one materialization per series at a time.
- `MeetingAgendaService`: the type's template applied to a meeting's agenda, items reordered, and unfinished items carried forward to the next meeting.
- `MeetingCalendarFile`: the meeting as an `.ics` file (REQUEST or CANCEL), built on the server with no calendar provider.

## The meetings rules (`src/meetings`)

Pure functions the services and the entity servers share: `meetingStatusMoveAllowed` and friends (Draft → Scheduled → InProgress → Completed; Scheduled and Postponed either way; anything but Completed can be Cancelled), `meetingTimeProblem` and `isValidTimeZone`, `expandOccurrences` (an RFC 5545 RRULE run over wall-clock times in the series' IANA zone, through `rrule` and `luxon`), `agendaParentProblem`, `orderAgenda` and `agendaDurationTotal`, `parseAgendaTemplate`, `buildMeetingIcs` (escaped, folded at 75 octets), `personIdForUser` / `userIdForPerson` (the user's own link to People first, the deprecated `People.LinkedUserID` second), and `callerAdministersMeetings`.
