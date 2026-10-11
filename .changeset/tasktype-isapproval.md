---
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-server": minor
"@mj-biz-apps/tasks-ng": minor
---

Collected migrations: `TaskType.IsApproval` (`BIT NOT NULL`, default 0) marks the task types whose tasks are approvals, so the approvals inbox can list every such type instead of only the seeded Approval Request. Includes the CodeGen output for the column: entity field, `vwTaskTypes`, the TaskType CRUD procedures, the entity class, GraphQL types and the TaskType form.
