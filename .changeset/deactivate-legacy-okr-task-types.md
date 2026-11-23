---
"@mj-biz-apps/tasks-actions": minor
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-ng": minor
---

Mark legacy `PRIORITY_OBJECTIVE` and `KEY_RESULT` task types inactive (`IsActive = false`) in dual-dialect SQL migrations (`migrations/` and `migrations-pg/`) while preserving all existing OKR columns on `Task`, exclude inactive/legacy OKR types from active task type selectors and creation paths while keeping historical records readable, add the `GoalsViewComponent` empty state and in-app help text, and update `README.md`, `docs/`, guides, and the Chief of Staff Tasks skill to steer OKR workflows to **BizApps Planning** and reference the **`Import Tasks OKRs`** migration action.
