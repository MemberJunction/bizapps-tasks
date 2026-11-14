---
"@mj-biz-apps/tasks-entities-server": patch
"@mj-biz-apps/tasks-server": patch
"@mj-biz-apps/tasks-core": patch
---

Security hardening: escape single quotes in IDs interpolated into RunView `ExtraFilter` literals. Two of these sites were reachable with caller-controlled strings before any FK validation — `TaskEntityServer.loadDefaultTaskTypeStatus` (a new task's `TypeID`, read pre-save) and `TaskNotificationHandler.getPersonName` (a `TaskAssignment.AssigneeRecordID`, which is free text with no FK) — allowing SQL filter breakout; the remaining sites in the core services are hardened in the same pass.
