---
"@mj-biz-apps/tasks-entities-server": minor
---

The Tasks setting `SelfApprovalExemptRole` now takes a comma-separated list of role names (`CEO Approver,CFO`); holders of any listed role may decide an approval task they created, as an assignee, while `PreventSelfApproval` is on. A single role name works as before. Names match trimmed and case-insensitively, and listed names that are not roles are logged. `TasksSettings.SelfApprovalExemptRole()` is replaced by `TasksSettings.SelfApprovalExemptRoles()`, which returns the list. The setting's comment in `metadata/application-settings` describes the list format.
