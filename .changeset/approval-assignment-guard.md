---
"@mj-biz-apps/tasks-entities-server": patch
---

Guard approval-task assignments on the server (bc-aidp-next-golive#389). Nobody may assign an approval task to themselves, and changing who an approval is assigned to, or removing its assignee, is refused unless the user holds a role named in the new Tasks setting `ApprovalReassignRoles` (comma-separated role names; empty lets nobody). Workflows that create approval assignments for someone else are unaffected, as are ordinary tasks.
