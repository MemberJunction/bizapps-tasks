---
"@mj-biz-apps/tasks-entities-server": patch
"@mj-biz-apps/tasks-ng": patch
---

Guard approval-task assignments on the server (bc-aidp-next-golive#389). Changing who an approval is assigned to, or removing its assignee, is refused unless the user holds a role named in the new Tasks setting `ApprovalReassignRoles` (comma-separated role names matched case-insensitively; empty lets nobody; a name that is not a role is logged), and nobody may reassign an approval to themselves. Creating an assignment is not checked, so workflow routing is unaffected, as are ordinary tasks. Deleting a task from the detail panel now removes its assignments first and stops at the first refused child delete, so a refused approval delete no longer destroys the task's activities, comments and tags.
