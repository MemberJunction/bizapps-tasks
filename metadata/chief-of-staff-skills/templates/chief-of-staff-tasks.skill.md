# Chief of Staff Tasks & To-dos

Use this skill whenever the user asks about personal to-dos, operational tasks, assignments, blockers, follow-ups, or task status updates — or during `tasks-daily-triage` and `tasks-weekly-review` wakes.

## 1. Typed Tools Only (Never Generic CRUD or Raw SQL)

Always use the strongly typed BizApps Tasks tools bundled with this skill. Identity ("me") is resolved automatically from the signed-in user inside every tool — never guess or pass your own `PersonID` or `UserID`.

- **`Find Tasks`**: Search and filter operational tasks (`Scope`: `Mine`, `AssignedToMe`, `CreatedByMe`, `DelegatedByMe`, `Team`; optional `Status`, `Priority`, `CategoryID`, `TaskType`, `OrganizationID`, `DueBefore`, `DueAfter`, `IncludeCompleted`, `SearchText`, `MaxRows`). By default, strategic planning types (`Priority Objective`, `Key Result`, `Priority`) are excluded so operational lists stay crisp.
- **`Get Task`**: Load one task's full context — details, assignees, blocking/blocked-by dependencies, recent comments, recent check-ins, linked records, and sub-tasks.
- **`Create Task`**: Create a new operational task with optional `AssigneeEmail` / `AssigneeName` / `AssigneePersonID`, `DueAt`, `Priority`, `TaskTypeName`, `CategoryID`, `OrganizationID`, `ParentTaskID`, and an idempotent `ClientRequestKey` so retried wakes never duplicate tasks.
- **`Update Task`**: Update specific fields (`Name`, `Description`, `Status`, `Priority`, `DueAt`, `StartedAt`, `PercentComplete`, `BlockedReason`, `CategoryID`, `OrganizationID`, `HealthStatus`, `ConfidenceScore`).
- **`Complete Task`**: Mark a task `Completed` (`PercentComplete = 100`), optionally record a `CompletionNote`, and automatically check downstream dependencies so newly unblocked assignees' Chiefs of Staff are notified.
- **`Assign Task`**: Assign a task to a person (`AssigneeEmail` / `AssigneeName` / `AssigneePersonID`), an MJ Role (`AssigneeRoleName` / `AssigneeRoleID`), or an AI Agent (`AgentName` / `AgentID`), with optional `Role` (`Primary`/`Owner`/`Assignee`, `Reviewer`, `Observer`/`Watcher`) and `ReplaceExisting`.
- **`Add Task Update`**: Post a progress comment (`Content`) or structured check-in (`HealthStatus`, `ConfidenceScore`, `PercentComplete`, `Blockers`, `NextSteps`) on a task.
- **`Find Similar Tasks`**: Check open and recently updated tasks (default 30-day window) by lexical + semantic similarity before creating tasks from notes, emails, or meeting transcripts.

*(Note: `Get My Tasks Briefing` runs automatically during `Assemble My Briefing` — you do not need to call it manually.)*

## 2. Bulk Operations & Playbooks

- **Multi-task edits (2–500 tasks):** When the user asks to bulk-reassign, bulk-redate/shift due dates, change status/priority/category/organization, or add/remove tags across multiple tasks, prefer **`BizAppsTasks.BulkUpdateTasks`** instead of looping `Update Task` one record at a time.
- **Playbooks & templates:** When launching a repeatable checklist or multi-step workflow from a Task Template, prefer **`BizAppsTasks.InstantiateTemplate`** instead of manually creating each subtask.

## 3. Organization & Company Scoping

- Scope company, subsidiary, or client work using **`MJ_BizApps_Common: Organizations`** (`OrganizationID`) rather than referencing `MJ: Companies` directly.
- Internal legal entities and operating companies mirror `MJ: Companies` into `MJ_BizApps_Common: Organizations` via `LinkedCompanyID` (kept in sync by `BizAppsCommon.SyncCompaniesToOrganizations`), so one `OrganizationID` covers both internal entities and external clients/partners consistently.

## 4. Deduplication & Loop Closing

- Before creating a task captured from notes, emails, or chat messages, always call **`Find Similar Tasks`** with the proposed title/description.
  - If `HasLikelyDuplicate` is true (or a strong match exists), surface the existing task and offer to update or add a comment via **`Add Task Update`** instead of creating a duplicate.
  - When creating a task during an automated wake, always supply a deterministic **`ClientRequestKey`** (for example `email-<messageId>-1` or `meeting-<meetingId>-p1`).

## 5. Coexistence With Strategic Planning

- When BizApps Planning is installed, defer questions about quarterly/annual strategic priorities, OKRs, key results, critical numbers, and huddles to the Planning skill's tools.
- Use this skill for operational execution tasks, personal to-dos, follow-ups, approvals, and deliverables.

## 6. Handling Canonical Result Codes

- **`NO_PERSON_RECORD`**: Explain clearly that the user's account is not yet linked to an active `People` record and ask an administrator to link it before creating/tracking personal tasks.
- **`AMBIGUOUS`**: Present the returned `Candidates` list (name + email) and ask the user which person, role, or agent they meant before retrying.
- **`ALREADY_COMPLETED`**: Confirm the task was already marked complete — do not retry.
- **`POLICY_DENIED` / `POLICY_DEFERRED` / `APPROVAL_REQUIRED`**: Respect the user's Agent User Policy strictly; explain the restriction clearly without attempting workarounds.
- **`NOT_FOUND` / `PERMISSION_DENIED`**: Tell the user the task or assignee was not found or is outside their visibility scope.
