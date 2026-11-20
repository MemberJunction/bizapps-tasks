---
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-server": minor
"@mj-biz-apps/tasks-ng": minor
---

Declare 15 database-backed `RelatedRecordCollection` metadata relationships and strongly-typed `DeclareRelatedRecords` accessors across `Tasks`, `Task Types`, `Task Templates`, `Task Template Items`, and `Work Reports`; harden server transactional boundaries (`TransactionGroup` activity attachment, `BeginEntityTransaction()` around standalone check-in sync and template instantiation, single-owner lifecycle hook dispatch in `TaskEntityServer` with fixed `OnReject` vs `OnCancel` classification, composite-graph coordination for `Task.CheckIns` and `WorkReport.Items`, portable ISO timestamps in `OverdueTaskNotificationJob`); modernize core services (`WorkReportService`, `TaskOrchestrationService`, `TaskTemplateService`, `TaskAssignmentService`, `TaskService`) to use atomic composite saves and batched `IncludeRelatedRecords` loading; and fix Angular UX bugs (`TaskHeaderPanel` typed hours fields, atomic `TaskEditPanel`/`TaskList`/`TaskDetailPanel` graph saves/deletes, and scoped `People` queries).
