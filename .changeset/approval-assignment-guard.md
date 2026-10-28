---
"@mj-biz-apps/tasks-entities-server": patch
---

Guard approval-task assignments on the server (bc-aidp-next-golive#389). Changing who an approval is assigned to, or removing its assignee, is refused unless the user holds a role named in the new Tasks setting `ApprovalReassignRoles` (comma-separated role names; empty lets nobody), and nobody may reassign an approval to themselves. Creating an assignment is not checked, so workflow routing is unaffected, as are ordinary tasks.
