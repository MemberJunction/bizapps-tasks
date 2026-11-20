---
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-server": minor
---

Security hardening across Tasks entities, core services, server subclasses, notification handler, overdue scheduled job, and approval defaults:

- **Secure-by-default `PreventSelfApproval`**: flipped the seeded default in `metadata/application-settings/.tasks-settings.json` and the `TasksSettings.PreventSelfApproval` code fallback from `false` to `true`, and hardened `asBoolean` so empty or unrecognized values retain the secure fallback rather than silently disabling the guard. Only an explicit `false` setting turns the guard off.
- **Single lifecycle hook dispatch & corrected `OnReject`/`OnCancel` routing**: removed duplicate `OnComplete`/`OnCancel`/`OnReject` action invocations from `TaskNotificationHandler` so lifecycle hooks dispatch solely from `TaskEntityServer` on actual status transitions (preventing double execution and post-completion replays). Fixed `TaskEntityServer` so `Blocked` never fires `OnReject`, and `Cancelled` fires at most one hook — `OnReject` when landing on a `REJECTED` stage or when a `Rejected` `TaskDecision` exists, otherwise `OnCancel`.
- **Unified UUID/SQL filter validation (`GuidLiteral` / `IsValidUUID`)**: exported a single shared `GuidLiteral` helper from `@mj-biz-apps/tasks-core` and routed interpolated `RunView` filter IDs through strict UUID validation across `TaskEntityServer` (including pre-save `loadDefaultTaskTypeStatus`), `TaskDependencyEntitySubclass` (with `ContextCurrentUser` threaded into cycle checks), `TaskService`, `TaskAssignmentService`, `TaskTemplateService`, `TaskNotificationHandler` (including polymorphic `AssigneeRecordID` guards), and `OverdueTaskNotificationJob`.
- **Checked entity saves**: `TaskService.rollupParentProgress`, `TaskService.logActivity`, and `TaskAssignmentService.assignToTask` log `LatestResult.CompleteMessage` on failed saves (stopping parent rollup recursion on save failure).
