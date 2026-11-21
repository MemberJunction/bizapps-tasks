---
"@mj-biz-apps/tasks-server": patch
"@mj-biz-apps/tasks-entities-server": patch
---

Workflow Human steps and agents' questions can now be answered as Tasks tasks.

- **Workflow steps.** Name `provider: 'BizAppsTasks'` on a Human step and, when the workflow reaches it, Tasks raises an approval task (assignees, the record it is about, a due date) linked to the step. Deciding the task completes the step and writes the decision into the workflow payload under `approval` (`Outcome`, `Approved`, `Notes`, `DecidedByPersonID`), so the workflow can branch on it. Only a recorded decision approves; a task closed without one completes the step with `Approved: false`.
- **The install's default.** The provider declares `CanBeDefault`, so an install that sets `humanTasks.defaultProvider: 'BizAppsTasks'` in `mj.config.cjs` sends it every Human step that names no provider, and every agent's question (a Chat step's feedback request). Without that setting nothing changes.
- **Agents' questions.** The task goes to the user the request names, else the user who ran the agent, and is linked to the `MJ: AI Agent Requests` row. Deciding it answers the request through MJ (`AnswerAgentRequestFromProvider`), which resumes the agent: an approving decision approves, a rejecting one rejects, a task completed without a decision responds with its completion notes. A task cancelled without a decision leaves the question open in MJ's inbox. Answering in MJ first cancels the task.
- **Links.** A task can be linked to a workflow step or an agent request only by the provider that raised it.

Requires a MemberJunction release that carries human-task providers in `@memberjunction/ai-core-plus` and `AnswerAgentRequestFromProvider` in `@memberjunction/ai-agents` (6.3 edge or later).
