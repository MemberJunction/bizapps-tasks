# @mj-biz-apps/tasks-entities-server

Authoritative server-side entity subclasses for BizApps Tasks.

## Classes

- `TaskEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Tasks')`)
  - **Dynamic Status Synchronization**: Auto-syncs `TaskTypeStatusID` $\leftrightarrow$ `Status` (`MacroStatus`) and auto-assigns default stage on task creation.
  - **Terminal Completion**: Automatically populates `CompletedAt` and sets `PercentComplete = 100` upon entering terminal statuses.
  - **Audit Logging**: Writes server-authoritative `Task Activities` on creation, status change, progress update, priority change, and due date changes.
  - **Subtask Progress Rollup**: Reconciles parent progress upon child save.
  - **Lifecycle Action Hooks**: Dispatches asynchronous, non-blocking Action execution for `OnCreateActionID`, `OnStatusChangeActionID`, `OnEnterActionID`, `OnExitActionID`, `OnCompleteActionID`, `OnCancelActionID`, `OnRejectActionID`, and `OnPercentChangeActionID` with universal task event payloads.

- `TaskDecisionEntityServer` (`@RegisterClass(BaseEntity, 'MJ_BizApps_Tasks: Task Decisions')`)
  - **Who may decide an approval task**: while the Tasks application setting `PreventSelfApproval` is `true`, a decision on an approval-type task is accepted only from one of its active assignees, recorded as their own decision, and never from the person who created the task.
  - **Exempt roles**: holders of a role listed in the `SelfApprovalExemptRole` setting may decide a task they created, as long as they are an assignee. The value is one role name or several, comma-separated (`CEO Approver,CFO`); names match trimmed and case-insensitively, so a role name cannot contain a comma. Empty exempts nobody; a listed name that is not a role exempts nobody and is logged.
