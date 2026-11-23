---
"@mj-biz-apps/tasks-actions": minor
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-ng": minor
"@mj-biz-apps/tasks-ng-widgets": minor
"@mj-biz-apps/tasks-server": minor
---

Add the v1.15.x `Metadata_Sync` migration (SQL Server and PostgreSQL). It seeds nothing: the release's only metadata change, SaveReturnMode `datestamps_only` on Task Activities and Task Notification Logs, is already applied together with its stored procedures by the `SaveReturnMode_DatestampsOnly_StoredProcedures` migration.
