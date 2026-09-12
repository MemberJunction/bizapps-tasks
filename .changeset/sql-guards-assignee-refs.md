---
'@mj-biz-apps/tasks-core': patch
'@mj-biz-apps/tasks-entities-server': patch
'@mj-biz-apps/tasks-server': patch
---

Security: close a stored SQL injection through `TaskAssignment.AssigneeRecordID`. The column is a deliberately FK-less polymorphic reference, so the database never validates its shape — but the notification handlers and the nightly overdue job read stored values back into `ExtraFilter` strings. Assignments now reject non-UUID `AssigneeRecordID` at save time, every read site shape-validates before interpolating (malformed values are skipped and logged), and `TaskEntityServer`'s pre-save status sync no longer queries with an unvalidated `TypeID`/`TaskTypeStatusID`. Adds shared `IsUUID`/`RequireUUID`/`UuidInList` guards to `@mj-biz-apps/tasks-core`.
