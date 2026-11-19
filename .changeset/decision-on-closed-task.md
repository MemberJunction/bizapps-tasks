---
"@mj-biz-apps/tasks-core": patch
"@mj-biz-apps/tasks-ng": patch
---

`TaskOrchestrationService.RecordDecision` now refuses a decision on a Task that is already Completed or Cancelled. It throws `TaskClosedError` before any TaskDecision row or activity is written, so the Task keeps its status. Before, an approval panel opened before the Task was closed could still record a decision, and an approval turned a Cancelled Task into Completed.

`approval-decision-panel` shows the refusal and emits a new `TaskClosed` output with the task ID; `approval-inbox` reloads its list on that event so the closed Task drops out. `IsClosedTaskStatus` and `ClosedTaskStatuses` are exported from tasks-core for callers that want to check first.
