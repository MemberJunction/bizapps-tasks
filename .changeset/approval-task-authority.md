---
"@mj-biz-apps/tasks-entities-server": patch
"@mj-biz-apps/tasks-core": patch
"@mj-biz-apps/tasks-server": patch
---

Closes three ways around who may decide an approval task (bizapps-tasks#209). On a task whose type has `IsApproval` set, the server now checks these writes, whoever makes them:

- **Adding an assignee.** Creating a Task Assignment was never checked, so a user could add themselves to an approval and then decide it. Now the person recorded as the task's creator names its approvers while the request is open; anyone else needs the reassign right (`ApprovalReassignRoles`, which everyone holds while the setting is empty) and can never add themselves, as a person, as a user or through a role they hold. Changing an assignment to a role the user holds is refused the same way.
- **Closing the task.** `Completed` follows an approving decision and `Cancelled` a rejecting one. With no such decision, only someone who could record the decision can complete the task. A cancel is a withdrawal: the creator, an active assignee or a holder of the reassign right can make it, and it never approves a timesheet part, a workflow step or an agent's request. An approval task's type can no longer be changed to a type that is not an approval.
- **Naming the creator.** A new task's `CreatedByPersonID` must be one of the saving user's own People, on every task type, and a user cannot record a creator on a task that was saved without one.

A refused save returns `false` with the reason in `LatestResult.CompleteMessage`.

Server code that decides these itself vouches for one save of one record with `SanctionOnBehalfCreator(task)`, `SanctionApprovalAssignment(assignment)` or `SanctionApprovalWithdrawal(task)` from `@mj-biz-apps/tasks-entities-server`. `TaskOrchestrationService.CreateTask` and `CreateApprovalRequest` take a `BeforeSave` callback, and `TaskAssignmentService.assignToTask` a `beforeSave` one, so a caller can vouch through the services. The MJ system user needs no vouching for these three. Nothing vouches for completing an approval.

What an app built on Tasks has to change:

- A flow that creates a task for someone other than the user running it, as a user who is not the system user, passes `BeforeSave: SanctionOnBehalfCreator`.
- A flow that adds an assignee to an approval task someone else created, or cancels one, on an install that names roles in `ApprovalReassignRoles`, vouches for that save or runs as a user who holds one of the roles.
- A flow that completes an approval task by setting its status, with no decision recorded, now needs the saving user to be one of its active assignees and not its creator. Record the decision (`TaskOrchestrationService.RecordDecision`) instead.

Also: the Tasks human-task provider records no creator on a task raised for an agent's question to the user who ran the agent, so that user can answer it; and `MeetingNotesService.acceptProposedTask` records the accepting user as the task's creator instead of falling back to the note's author.
