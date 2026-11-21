---
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-actions": minor
"@mj-biz-apps/tasks-server": minor
"@mj-biz-apps/tasks-ng": minor
---

Chief of Staff review hardening for BizApps Tasks — `Task.Visibility` + Tasks RLS, coalesced per-user event wakes, canonical `Agent Task` non-blocking dispatch, and Meetings/Work Reports briefings:

- **Manifest version range**: Update `mj-app.json` `mjVersionRange` to `">=6.3.0-edge.1 <7.0.0"`.
- **`Task.Visibility` & full Tasks RLS (SQL Server + PostgreSQL)**:
  - Add migration `V202611211100__v1.16.x__Task_Visibility.sql` adding `Visibility NVARCHAR(20) NOT NULL DEFAULT 'Standard'` (`'Standard' | 'Private'`) with CodeGen entity/schema/GraphQL/form updates.
  - Add `Tasks: Visible Tasks` and `Tasks: Rows Of Visible Tasks` RLS filters (both SQL Server `FilterText` and PostgreSQL `PlatformVariants`) and bind `ReadRLSFilterID` to the `UI` role on `Tasks`, `Task Assignments`, `Task Check Ins`, `Task Comments`, and `Task Activities`.
  - Wire strongly-typed `Visibility` into `Create Task`, `Update Task`, `Get Task`, and `Find Tasks` (including defense-in-depth `Scope = 'Team'` visibility filtering) and verify Private task isolation in unit tests and `TSK-09`.
- **Coalesced per-user event wakes (`tasks-inbox`, `meetings-transcript`)**:
  - Replace per-task wake keys (`task-assigned-*`, `task-unblocked-*`, `agent-task-*`) with a single coalesced per-user `tasks-inbox` workstream key.
  - Trigger coalesced `tasks-inbox` wakes post-commit from `TaskAssignmentEntityServer` (new assignment/reassignment) and `TaskEntityServer` (direct unblock & downstream dependency unblock) via `ChiefOfStaffWakeRegistry` so UI edits, `BulkUpdateTasks`, and CoS actions all coalesce cleanly without duplicate per-task wakes.
  - Trigger coalesced `meetings-transcript` wakes post-commit from `MeetingEntityServer` (transition to `Completed` or transcript attached) and `MeetingNoteEntityServer` (transcript/note saved).
  - Route other attendees' meeting commitments in `ProcessMeetingTranscriptAction` and `AcceptMeetingCommitmentsAction` to each attendee's Chief of Staff via `tasks-inbox`.
- **Canonical `Agent Task` (`AGENT_TASK`) & non-blocking execution**:
  - Seed the canonical `Agent Task` (`Code: 'AGENT_TASK'`) task type wired to `Execute Assigned Agent` on `OnAssignActionID`.
  - Add non-blocking `Async` dispatch mode (`ResultCode: 'DISPATCHED'`) to `ExecuteAssignedAgentAction` and pass `AgentID` + `Async: 'true'` from `TaskNotificationHandler.handleAssignmentSave` for AI Agent assignees so save hooks never stall on long-running agent runs.
- **Deterministic Briefing Collectors for Meetings & Work Reports**:
  - Add `Get My Meetings Briefing` (`GetMyMeetingsBriefingAction`) and `Get My Work Reports Briefing` (`GetMyWorkReportsBriefingAction`), bind both to their respective CoS skills (`Role: 'Briefing'`, `ExposeToModel: false`), and update V2 teardown scripts.
