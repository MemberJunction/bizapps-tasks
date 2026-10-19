---
"@mj-biz-apps/tasks-core": patch
---

`TaskAssignmentService.assignToTask` throws when the assignment does not save, with the save's message, and logs no activity for it. It used to return the unsaved entity, so a caller recorded an assignment that had no row and the task was assigned to no one. `CreateApprovalRequest` passes the error on, so a refused approver assignment now fails the request instead of leaving an approval task nobody holds.
