---
"@mj-biz-apps/tasks-actions": minor
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-ng": minor
"@mj-biz-apps/tasks-ng-widgets": minor
"@mj-biz-apps/tasks-server": minor
---

Removes the unreleased, statement-free 1.15 Metadata_Sync placeholder (V202611231320). A database that already ran it keeps a history row for a file that no longer exists; Skyway still migrates it.
