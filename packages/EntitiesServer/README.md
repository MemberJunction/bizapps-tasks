# @mj-biz-apps/tasks-entities-server

Authoritative server-side entity subclasses for BizApps Tasks.

## Classes

- `TaskEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Tasks')`)
  - **Dynamic Status Synchronization**: Auto-syncs `TaskTypeStatusID` $\leftrightarrow$ `Status` (`MacroStatus`) and auto-assigns default stage on task creation.
  - **Terminal Completion**: Automatically populates `CompletedAt` and sets `PercentComplete = 100` upon entering terminal statuses.
  - **Audit Logging**: Writes server-authoritative `Task Activities` on creation, status change, progress update, priority change, and due date changes.
  - **Subtask Progress Rollup**: Reconciles parent progress upon child save.
  - **Lifecycle Action Hooks**: Dispatches asynchronous, non-blocking Action execution for `OnCreateActionID`, `OnStatusChangeActionID`, `OnEnterActionID`, `OnExitActionID`, `OnCompleteActionID`, `OnCancelActionID`, `OnRejectActionID`, and `OnPercentChangeActionID` with universal task event payloads.
