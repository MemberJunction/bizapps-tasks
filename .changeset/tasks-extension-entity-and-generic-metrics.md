---
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-ng": minor
"@mj-biz-apps/tasks-server": minor
---

Prepare `bizapps-tasks` for BizApps Planning's IS-A `Priority Tasks` extension: rewrite Task metric and check-in metadata descriptions and TypeScript JSDoc to document generic measurable task usage without DDL changes, configure `ExtensionEntity: "MJ_BizApps_Planning: Priority Tasks"` on the `PRIORITY` task type (`metadata/task-types-planning/`, gated by `@env:MJ_BIZAPPS_PLANNING_INSTALLED`), mark legacy `PRIORITY_OBJECTIVE` and `KEY_RESULT` task types inactive, export generic task-type filtering helpers, filter Planning-owned and inactive OKR task types out of generic Tasks creation and bulk-reassignment menus, and restore workspace links in `pnpm-lock.yaml`.
