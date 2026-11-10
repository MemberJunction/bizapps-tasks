---
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-ng": minor
---

Guard approval-task assignments on the server (bc-aidp-next-golive#389). When the new Tasks setting `ApprovalReassignRoles` names roles (comma-separated role names matched case-insensitively; a name that is not a role is logged), changing who an approval is assigned to, or removing its assignee, is refused unless the user holds one of them. Empty, the default, switches that rule off, so installing this release changes nothing until a host sets a value. Nobody may reassign an approval to themselves, whatever the setting. Creating an assignment is not checked, so workflow routing is unaffected, as are ordinary tasks. Deleting a task from the detail panel now removes its assignments first and stops at the first refused child delete, so a refused approval delete no longer destroys the task's activities, comments and tags.
