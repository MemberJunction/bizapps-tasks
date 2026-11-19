---
"@mj-biz-apps/tasks-server": patch
"@mj-biz-apps/tasks-entities-server": patch
---

A workflow's Human step can now be answered as a Tasks task. Name `provider: 'BizAppsTasks'` on the step and, when the workflow reaches it, Tasks raises an approval task (assignees, the record it is about, a due date) linked to the step. Deciding the task completes the step and writes the decision into the workflow payload under `approval` (`Outcome`, `Approved`, `Notes`, `DecidedByPersonID`), so the workflow can branch on it. Only a recorded decision approves; a task closed without one completes the step with `Approved: false`. Links to workflow steps can be created only by the workflow itself.

Requires a MemberJunction release that carries waiting steps and human-task providers (6.3 edge or later) for `@memberjunction/task-graph`.
