---
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-actions": minor
"@mj-biz-apps/tasks-server": minor
"@mj-biz-apps/tasks-ng": patch
---

Harden approval authorization across actions, entity servers, and services with typed `ApprovalAuthorizationError` and cross-organization isolation; add dual-dialect LIKE escaping (`BuildLikeClause`/`EscapeLikePattern`) and `TelemetryManager` (`RouteScrubber`-redacted) approval latency tracking; replace recurring-close text markers with an additive dual-dialect filtered unique index (`UX_Task_RecurringPlaybook_Org_Period`) registered edge-only in `release-lines.json`; seed `APPROVAL_REQUEST` approve-then-act hook metadata (`Process Approval Request Outcome`) and add automated end-to-end `AGENT_TASK` dispatch and concurrency tests.
