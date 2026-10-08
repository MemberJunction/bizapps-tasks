---
"@mj-biz-apps/tasks-actions": minor
"@mj-biz-apps/tasks-server": minor
---

A task type can post each new assignment to a Microsoft Teams channel.

- New action **Post Task Assignment to Teams** (`Tasks.PostAssignmentToTeams`). Set it as a Task Type's `OnAssignActionID`. It posts an Adaptive Card with the task, the assignee and, when the credential has an `explorerUrl`, a link to the task.
- The webhook URL lives in a credential of the new **Teams Channel Webhook** type. The action uses the credential named in `CredentialName`, else the one named after the task type's `Code`, else the type's default. Office 365 connector and Power Automate Workflows webhook URLs are both accepted. A fallback to the default credential is logged. A `TaskTypeID` that is not a UUID fails with `INVALID_TASK_TYPE`. Task, type and assignee names are markdown-escaped on the card.
- The OnAssign hook now also passes `TaskTypeID`, `AssigneePersonID` and `AssigneeName`. It runs whether or not the assignee has a linked MJ user, and when the in-app notification throws. Before, an assignee without one got neither the in-app notification nor the hook.
- Metadata adds the `Tasks` action category, the action and the credential type. `mj sync push` orders them before the folders that reference them.
