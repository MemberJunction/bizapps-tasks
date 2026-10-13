---
"@mj-biz-apps/tasks-entities-server": patch
"@mj-biz-apps/tasks-core": patch
"@mj-biz-apps/tasks-server": patch
---

Task saves, assignments, orchestration verbs (`CreateTask`, `CreateApprovalRequest`, `TransitionStatus`, `RecordDecision`), and activity rows now read and write on the provider passed or attached to the entity rather than the process-global provider. Lifecycle action hooks, parent-progress rollup, and task/assignment/comment notifications (`OnAssign`, `OnComplete`, `OnReject`, `OnCancel`) are scheduled via `RunAfterCommit` so they run after the caller's transaction commits and are dropped on rollback.
