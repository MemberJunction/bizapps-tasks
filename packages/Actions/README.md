# @mj-biz-apps/tasks-actions

Server-side MemberJunction Action implementations (`BaseAction` subclasses) for BizApps Tasks.

## Actions

- `PostTaskAssignmentToTeamsAction` (`@RegisterClass(BaseAction, 'Tasks.PostAssignmentToTeams')`)
  - Posts adaptive card notifications to a Microsoft Teams channel webhook when a task is assigned.
- `LinkAgentRunToTaskAction` (`@RegisterClass(BaseAction, 'LinkAgentRunToTaskAction')`)
  - Links an `MJ: AI Agent Runs` execution (`AgentRunID`) to a task (`TaskID`) with optional `Notes` by creating a `MJ_BizApps_Tasks: Task Agent Runs` record (`TaskAgentRunEntityServer`), returning `TaskAgentRunID` as an output parameter.
  - Enforces caller ownership (`AIAgentRun.UserID`) or the `Tasks: Manage Time Entries` authorization, and automatically deduplicates ancestor/descendant agent run links (`A2`/`D7`).
