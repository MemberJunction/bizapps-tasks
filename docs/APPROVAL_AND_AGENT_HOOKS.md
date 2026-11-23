# Approval & Agent Lifecycle Hooks Guide

This guide documents how MemberJunction BizApps Tasks registers, triggers, and authorizes **`AGENT_TASK`** workflow dispatch and **`APPROVAL_REQUEST`** approve-then-act lifecycle hooks.

---

## 1. Hook Registration & Metadata

Lifecycle hooks are declared in two metadata collections under [`metadata/`](../metadata):

1. **Action definitions** in [`metadata/actions/.tasks-actions.json`](../metadata/actions/.tasks-actions.json):
   - **`Execute Assigned Agent`** (`DriverClass: "Tasks.ExecuteAssignedAgent"`, `Type: "Custom"`) — executes an assigned AI Agent asynchronously and records run results.
   - **`Process Approval Request Outcome`** (`DriverClass: "Tasks.ProcessApprovalOutcomeHook"`, `Type: "Custom"`) — executes approve-then-act follow-on checks and downstream unblocking/audit when an `APPROVAL_REQUEST` closes.
2. **Task Type bindings** in [`metadata/task-types/.task-types.json`](../metadata/task-types/.task-types.json):
   - **`AGENT_TASK`**: binds `OnAssignActionID` -> `@lookup:MJ: Actions.Name=Execute Assigned Agent`.
   - **`APPROVAL_REQUEST`**: binds `OnCompleteActionID`, `OnRejectActionID`, and `OnCancelActionID` -> `@lookup:MJ: Actions.Name=Process Approval Request Outcome` (or a domain-specific action overriding any of those columns).
   - **`TIMESHEET_APPROVAL`**: sets `IsApproval: true` and `RequiresAssigneeDecision: true`; synchronous settlement runs in [`TimesheetApprovalOutcome.ts`](../packages/EntitiesServer/src/TimesheetApprovalOutcome.ts).

---

## 2. Universal Hook Payload Contract

### 2.1 Lifecycle Hooks (`OnCreate`, `OnStatusChange`, `OnEnterStatus`, `OnExitStatus`, `OnComplete`, `OnReject`, `OnCancel`, `OnPercentChange`)

When [`TaskEntityServer.invokeAction`](../packages/EntitiesServer/src/TaskEntityServer.ts) dispatches a hook post-commit, it passes these `ActionParam` inputs:

| Parameter | Type | Description |
|---|---|---|
| `TaskID` / `RecordID` | `string` | UUID of the `Task` record |
| `TaskName` | `string` | Task title |
| `TaskTypeCode` | `string` | Code on `MJ_BizApps_Tasks: Task Types` (e.g. `APPROVAL_REQUEST`, `AGENT_TASK`) |
| `TaskTypeStatusID` | `string \| null` | Current custom `TaskTypeStatus` ID |
| `TaskTypeStatusCode` | `string` | Code on `TaskTypeStatus` (e.g. `REJECTED`, or empty string) |
| `Status` | `string` | Macro status after save (`Open`, `InProgress`, `Blocked`, `Completed`, `Cancelled`) |
| `PreviousStatus` | `string` | Macro status prior to save |
| `PercentComplete` | `number` | Updated completion percentage (`0`–`100`) |
| `Priority` | `string` | Task priority |
| `DueAt` | `Date \| null` | Task due timestamp |
| `TaskRecord` | `Record` | Full entity column snapshot via `this.GetAll()` |
| `Payload` | `string (JSON)` | Serialized envelope containing `{ taskID, taskName, taskTypeCode, taskTypeStatusID, taskTypeStatusCode, status, previousStatus, percentComplete, priority, dueAt, record }` |

### 2.2 Assignment Hook (`OnAssign`)

When a `TaskAssignment` is created or reassigned, [`handleAssignmentSave`](../packages/Server/src/event-handlers/TaskNotificationHandler.ts) resolves `TaskType.OnAssignActionID` and dispatches the action with:

| Parameter | Description |
|---|---|
| `TaskID` | Target task UUID |
| `AssigneeEntityID` / `AssigneeRecordID` | Polymorphic assignee (`MJ_BizApps_Common: People`, `MJ: Users`, `MJ: Roles`, or `MJ: AI Agents`) |
| `AgentID` | Populated directly when `AssigneeEntityID` points to `MJ: AI Agents` (nullable otherwise) |
| `AssigneePersonID` | Resolved Person ID for human assignees (`null` for Role/Agent assignees) |
| `AssigneeName` | Resolved display name of the Person, Role, or AI Agent |
| `Async` | `'true'` for AI Agent assignments so HTTP save requests return immediately |

---

## 3. Execution Lifecycle

### 3.1 `APPROVAL_REQUEST` Approve-Then-Act Lifecycle

1. **Authorization Gate (`ValidateAsync`)**:
   - [`TaskDecisionEntityServer`](../packages/EntitiesServer/src/TaskDecisionEntityServer.ts) verifies the actor is signed in, belongs to `Task.OrganizationID` (when set), holds an active assignment on the open approval task (direct Person, `MJ: Users`, or `MJ: Roles` queue), and is not the requester (unless holding `SelfApprovalExemptRole`).
   - [`TaskEntityServer`](../packages/EntitiesServer/src/TaskEntityServer.ts) blocks direct `Completed` / `Cancelled` transitions or `OrganizationID` tampering without valid decision/withdrawal standing.
   - [`TaskOrchestrationService.RecordDecision`](../packages/Core/src/services/TaskOrchestrationService.ts) composes the `TaskDecision`, `TaskActivity`, and terminal status transition atomically in a single `task.Save()` transaction and emits scrubbed latency metrics to `TelemetryManager.Instance`.
2. **Post-Commit Hook Routing (`runAfterCommit`)**:
   - Once the database transaction commits, `TaskEntityServer.dispatchLifecycleActionHooks` invokes:
     - `OnCompleteActionID` when `Status === 'Completed'`
     - `OnRejectActionID` (exclusively, never `OnCancelActionID`) when `Status === 'Cancelled'` AND either `TaskTypeStatus.Code === 'REJECTED'` or a `Rejected` `TaskDecision` exists
     - `OnCancelActionID` when `Status === 'Cancelled'` without a rejection signal (plain withdrawal)
3. **Approve-Then-Act Execution (`ApprovalOutcomeHookAction`)**:
   - Re-verifies a standing approving `TaskDecision` before acting on `OnComplete` (`ResultCode: 'UNAUTHORIZED'` if absent), writes a structured `TaskActivity` audit row, inspects `Task Links` and dependent downstream tasks, and wakes the Chief of Staff registry when downstream tasks are ready.

### 3.2 `AGENT_TASK` Workflow Dispatch Lifecycle

1. A task of type `AGENT_TASK` (`665697FE-9B18-4691-B40C-BE849FE60216`) is assigned to an `MJ: AI Agents` record via `TaskAssignment`.
2. `TaskNotificationHandler.handleAssignmentSave` detects `AssigneeEntityID === MJ: AI Agents`, skips human notification lookups, and invokes `Execute Assigned Agent` with `Async = 'true'`.
3. `ExecuteAssignedAgentAction` transitions the task to `InProgress`, tracks the promise in `ExecuteAssignedAgentAction.pendingExecutions` (flushable in tests via `FlushPendingExecutions()`), runs the agent under the assigner's `ContextUser` via `AgentRunner`, links the `AIAgentRun` (`Link Agent Run to Task`), posts a summary `TaskComment`, and wakes the assigner's Chief of Staff inbox.

---

## 4. Organization-Grouped Approval Inbox & Latency Visibility

- [`ApprovalsPageComponent`](../packages/Angular/src/lib/pages/approvals.page.ts) and [`ApprovalInboxComponent`](../packages/Angular/src/lib/components/approval-inbox/approval-inbox.component.ts) group pending approval tasks by `Task.OrganizationID` using [`approval-inbox-grouping.ts`](../packages/Angular/src/lib/components/approval-inbox/approval-inbox-grouping.ts).
- Organization headers display item counts and aggregate wait-latency indicators (`Avg` / `Max` wait since `Task.__mj_CreatedAt`) while individual cards surface per-task wait-latency tiers (`normal`, `elevated`, `overdue`) and Markdown-stripped plain-text excerpts.
- Grouping, sort order (`due`, `latency`, `priority`), and per-organization collapse preferences persist via `UserInfoEngine.Instance` (`mj.tasks.approvalInbox.prefs.v1`) without browser `localStorage`/`sessionStorage`, styled strictly with `--mj-*` semantic design tokens and `ChangeDetectionStrategy.OnPush`.
- All pending approval, authorization, latency reporting, and workflow dispatch queries run without decision-truncating `MaxRows` / `TOP` / `LIMIT` row caps (enforced by [`no-decision-row-caps.test.ts`](../packages/Core/src/services/__tests__/no-decision-row-caps.test.ts)).
