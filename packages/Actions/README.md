# @mj-biz-apps/tasks-actions

Server-side MemberJunction Action implementations (`BaseAction` subclasses) for BizApps Tasks.

## Actions

- `PostTaskAssignmentToTeamsAction` (`@RegisterClass(BaseAction, 'Tasks.PostAssignmentToTeams')`)
  - Posts adaptive card notifications to a Microsoft Teams channel webhook when a task is assigned.
- `LinkAgentRunToTaskAction` (`@RegisterClass(BaseAction, 'LinkAgentRunToTaskAction')`)
  - Links an `MJ: AI Agent Runs` execution (`AgentRunID`) to a task (`TaskID`) with optional `Notes` by creating a `MJ_BizApps_Tasks: Task Agent Runs` record (`TaskAgentRunEntityServer`), returning `TaskAgentRunID` as an output parameter.
  - Enforces caller ownership (`AIAgentRun.UserID`) or the `Tasks: Manage Time Entries` authorization, and automatically deduplicates ancestor/descendant agent run links (`A2`/`D7`).
- `PublishMeetingNoteAsMJDocAction` (`@RegisterClass(BaseAction, 'Tasks.PublishMeetingNoteAsMJDoc')`) & `PublishMeetingNoteAsMJDoc()`
  - Deterministically promotes a Category B `MJ_BizApps_Tasks: Meeting Notes` record to a versioned `MJ: Artifacts` + `MJ: Artifact Versions` MJ Doc while strictly preserving `MeetingNote.Body` and `MeetingNote.ProposedTasks` JSON.
  - Creates a new `MJ: Artifact` + `VersionNumber = 1` and links `MeetingNote.ArtifactID` on first publish (with compensating cleanup on downstream failure), and appends `VersionNumber = max + 1` idempotently on subsequent publishes without duplicating `MJ: Artifacts`.
  - Propagates `ContextUser` into every `GetEntityObject` / `RunView` call, enforces typed policy guards (`checkTypedPolicyGuard`), and rejects missing `ContextUser` (`PERMISSION_DENIED`), invalid UUIDs, or empty `Body` (`VALIDATION_ERROR`).
