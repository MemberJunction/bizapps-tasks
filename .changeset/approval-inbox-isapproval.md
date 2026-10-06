---
"@mj-biz-apps/tasks-ng": minor
"@mj-biz-apps/tasks-entities": minor
---

The approvals inbox lists tasks of every task type flagged `IsApproval`, so an app's own approval type appears on the Approvals page. `ApprovalTypeName` now defaults to null; set it to list a single named type, as before. The seeded Approval Request type is flagged `IsApproval` in `metadata/task-types/`.
