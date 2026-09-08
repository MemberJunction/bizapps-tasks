---
"@mj-biz-apps/tasks-core": patch
"@mj-biz-apps/tasks-ng": patch
---

security: enforce approver identity and assignment on task decisions

`TaskOrchestrationService.RecordDecision` no longer trusts the client-supplied
`DecidedByPersonID`. The decider is now derived from the authenticated caller's
linked Person, and the caller must hold an active approver assignment on the
target task before a decision is recorded or the task is transitioned — closing
an approval-forgery / broken-non-repudiation hole. The Angular approval panel and
inbox stop passing a client-chosen decider identity.
