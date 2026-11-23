---
"@mj-biz-apps/tasks-actions": minor
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-ng": minor
---

Mark legacy `PRIORITY_OBJECTIVE` and `KEY_RESULT` task types inactive in dual-dialect SQL migrations (`migrations/` and `migrations-pg/`) while preserving all existing OKR columns on `Task`, add `IsActiveSelectableTaskType` / `FilterActiveSelectableTaskTypes` helpers, and block creating or bulk-assigning inactive/legacy OKR task types across Actions, remote operations, and Angular filter selectors while keeping historical records readable.
