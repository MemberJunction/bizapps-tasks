---
"@mj-biz-apps/tasks-entities": minor
---

PostgreSQL counterparts for the five migrations from v1.2.x to v1.7.x (TaskType codes, statuses and workflow hooks; the scoped CodeGen objects; the v1.2.x metadata sync; the predictive SLA fields and layered `vwTasks`; `TaskType.IsApproval`). A PostgreSQL install now reaches the v1.7 schema instead of stopping at v1.1, and a database already at v1.1 upgrades with the same five files.
