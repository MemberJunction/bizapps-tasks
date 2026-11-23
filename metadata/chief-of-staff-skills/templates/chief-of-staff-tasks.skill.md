# Chief of Staff Tasks & To-dos

Use this skill whenever the user asks about personal to-dos, operational tasks, assignments, blockers, follow-ups, or task status updates — or during `tasks-daily-triage` and `tasks-weekly-review` wakes.

## 1. Typed Tools Only (Never Generic CRUD or Raw SQL)

Always use the strongly typed BizApps Tasks tools bundled with this skill. Identity ("me") is resolved automatically from the signed-in user inside every tool — never guess or pass your own `PersonID` or `UserID`.

- **`Find Tasks`**: Search and filter operational tasks (`Scope`: `Mine`, `AssignedToMe`, `CreatedByMe`, `DelegatedByMe`, `Team`; optional `Status`, `Priority`, `CategoryID`, `TaskType`, `OrganizationID`, `OrganizationName`, `DueBefore`, `DueAfter`, `IncludeCompleted`, `SearchText`, `MaxRows`). By default, strategic planning types (`Priority Objective`, `Key Result`, `Priority`) are excluded so operational lists stay crisp. Each returned task includes its canonical `OrganizationID` and `Organization` name.
- **`Get Task`**: Load one task's full context — details, organization, assignees, blocking/blocked-by dependencies, recent comments, recent check-ins, linked records, and sub-tasks.
- **`Create Task`**: Create a new operational task with optional `AssigneeEmail` / `AssigneeName` / `AssigneePersonID`, `DueAt`, `Priority`, `TaskTypeName`, `CategoryID`, `OrganizationID` or `OrganizationName`, `ParentTaskID`, and an idempotent `ClientRequestKey` so retried wakes never duplicate tasks.
- **`Update Task`**: Update specific fields (`Name`, `Description`, `Status`, `Priority`, `DueAt`, `StartedAt`, `PercentComplete`, `BlockedReason`, `CategoryID`, `OrganizationID`, `HealthStatus`, `ConfidenceScore`).
- **`Mark Task Complete`**: Mark a task `Completed` (`PercentComplete = 100`), optionally record a `CompletionNote`, and automatically check downstream dependencies so newly unblocked assignees' Chiefs of Staff are notified.
- **`Assign Task`**: Assign a task to a person (`AssigneeEmail` / `AssigneeName` / `AssigneePersonID`), an MJ Role (`AssigneeRoleName` / `AssigneeRoleID`), or an AI Agent (`AgentName` / `AgentID`), with optional `Role` (`Primary`/`Owner`/`Assignee`, `Reviewer`, `Observer`/`Watcher`) and `ReplaceExisting`.
- **`Add Task Update`**: Post a progress comment (`Content`) or structured check-in (`HealthStatus`, `ConfidenceScore`, `PercentComplete`, `Blockers`, `NextSteps`) on a task.
- **`Find Similar Tasks`**: Check open and recently updated tasks (default 30-day window) by lexical + semantic similarity before creating tasks from notes, emails, or meeting transcripts.

*(Note: `Get My Tasks Briefing` runs automatically during `Assemble My Briefing` — and supports optional `OrganizationID` / `OrganizationName` scoping — so you do not need to call it manually unless assembling a focused organization briefing.)*

## 2. Bulk Operations & Recurring Close Playbooks

- **Multi-task edits (2–500 tasks):** When the user asks to bulk-reassign, bulk-redate/shift due dates, change status/priority/category/organization, or add/remove tags across multiple tasks, prefer **`BizAppsTasks.BulkUpdateTasks`** instead of looping `Update Task` one record at a time.
- **Single-entity playbooks & templates:** When launching a repeatable checklist or multi-step workflow from a Task Template for one organization, prefer **`BizAppsTasks.InstantiateTemplate`** instead of manually creating each subtask.
- **Multi-entity recurring close rollovers (`BizAppsTasks.RunRecurringPlaybooks` / `Run Recurring Playbooks`):** When rolling out a recurring playbook (such as Month-End or Quarter-End Financial Close) across one or more organizations or all mirrored companies for a `PeriodKey`:
  1. **Always preview first with `DryRun: true`** to verify target organizations, which periods will launch, and which will be skipped idempotently.
  2. **Always present the dry-run summary and get explicit user confirmation** before executing with `DryRun: false` (bulk and rollover mutations are policy-guarded and may require approval under `RequireApprovalForDestructiveActions`).

## 3. Canonical Organization & Company Scoping

- Scope company, subsidiary, or client work using canonical **`MJ_BizApps_Common: Organizations`** (`OrganizationID` or `OrganizationName`) on `Find Tasks`, `Create Task`, and `Get My Tasks Briefing` rather than referencing `MJ: Companies` directly.
- Internal legal entities and operating companies mirror `MJ: Companies` into `MJ_BizApps_Common: Organizations` via `LinkedCompanyID` (kept in sync by `BizAppsCommon.SyncCompaniesToOrganizations`), so one `OrganizationID` / `OrganizationName` parameter covers both internal operating companies and external clients/partners consistently.
- When the user names a company or client (for example *"Acme Enterprise Corp"* or *"Apex Cloud Systems"*), pass `OrganizationName` directly — if multiple active organizations match a prefix, the tool returns `AMBIGUOUS` with `Candidates` so you can clarify before retrying.

## 4. Deduplication & Loop Closing

- Before creating a task captured from notes, emails, or chat messages, always call **`Find Similar Tasks`** with the proposed title/description.
  - If `HasLikelyDuplicate` is true (or a strong match exists), surface the existing task and offer to update or add a comment via **`Add Task Update`** instead of creating a duplicate.
  - When creating a task during an automated wake, always supply a deterministic **`ClientRequestKey`** (for example `email-<messageId>-1` or `meeting-<meetingId>-p1`).

## 5. Strategic Planning, OKRs & Auto-Mirrored Dependencies

- **Always steer OKR, Objective, and Key Result requests to BizApps Planning**: Legacy `PRIORITY_OBJECTIVE` and `KEY_RESULT` task types are inactive (`IsActive = false`) in BizApps Tasks `1.x`. Whenever a user asks to create, view, track, update, or manage OKRs, Objectives, Key Results, quarterly/annual strategic priorities, critical numbers, or huddles, direct them to **BizApps Planning** (and use the Planning skill tools when installed — never create OKRs or Key Results as Tasks).
- **Migrating legacy OKR tasks (`Import Tasks OKRs`)**: If the user has historical `PRIORITY_OBJECTIVE` or `KEY_RESULT` tasks in BizApps Tasks to move into BizApps Planning, instruct them to run the **`Import Tasks OKRs`** action (previewing with `DryRun: true` first).
- Use this skill for operational execution tasks, personal to-dos, follow-ups, approvals, and deliverables.
- **Do NOT manually duplicate `TaskDependency` rows between two `PriorityTask` records.** Strategic dependencies managed in BizApps Planning (`MJ_BizApps_Planning: Priority Dependencies`) automatically mirror into `MJ_BizApps_Tasks: Task Dependencies` via `PriorityDependencyEntityServer` — creating a duplicate `TaskDependency` edge manually will conflict with or double-count the mirrored link.

## 6. Handling Canonical Result Codes

- **`NO_PERSON_RECORD`**: Explain clearly that the user's account is not yet linked to an active `People` record and ask an administrator to link it before creating/tracking personal tasks.
- **`AMBIGUOUS`**: Present the returned `Candidates` list (name + email) and ask the user which person, role, or agent they meant before retrying.
- **`ALREADY_COMPLETED`**: Confirm the task was already marked complete — do not retry.
- **`POLICY_DENIED` / `POLICY_DEFERRED` / `APPROVAL_REQUIRED`**: Respect the user's Agent User Policy strictly; explain the restriction clearly without attempting workarounds.
- **`NOT_FOUND` / `PERMISSION_DENIED`**: Tell the user the task or assignee was not found or is outside their visibility scope.
