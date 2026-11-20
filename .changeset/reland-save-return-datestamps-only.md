---
"@mj-biz-apps/tasks-entities": minor
---

Re-enable `SaveReturnMode: 'datestamps_only'` (and `TrackRecordChanges: false`) on `MJ_BizApps_Tasks: Task Activities` and `MJ_BizApps_Tasks: Task Notification Logs` with paired SQL Server and PostgreSQL migrations now that MJ 6.2.1 ships full runtime and CodeGen support, and restore integration benchmark check `task-action-hooks.AH4`.
