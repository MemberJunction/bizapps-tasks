---
"@mj-biz-apps/tasks-entities-server": minor
---

Add an optional server-side check on who may decide an approval task (bc-aidp-next-golive#320 §3). A new `TaskDecisionEntityServer` refuses a Task Decision on an approval-type task (`TaskType.IsApproval`) unless the signed-in user is one of the task's assignees (through a linked Person, or assigned as the user directly), the decision is attributed to their own Person or to nobody, a named `TaskAssignmentID` is their own, and they did not create the task. Holders of the role named by the new `SelfApprovalExemptRole` setting may decide a task they created, as an assignee. Controlled by the new Tasks application setting `PreventSelfApproval`, which is off by default, so existing installs behave as before. Adds `TasksSettings`, a typed façade over MJ application settings for the Tasks app, and the two setting rows in `metadata/application-settings`.
