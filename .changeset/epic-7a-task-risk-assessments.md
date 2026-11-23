---
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-ng": minor
"@mj-biz-apps/tasks-server": minor
---

Add additive dual-dialect SQL Server and PostgreSQL migrations for `MJ_BizApps_Tasks: Task Risk Assessments` and `Task.ForecastCompletionDate`, strongly typed `TaskRiskAssessmentEntity` (`TaskRiskItem` JSON helpers) and `TaskRiskAssessmentEntityServer` (atomic root project task `HealthStatus`, `ConfidenceScore`, and `ForecastCompletionDate` synchronization guarded by latest `AssessedAt`), GraphQL schema support, and Angular Dual Form Registration Parity (`mjBizAppsTasksTaskRiskAssessmentFormComponent` + `TaskRiskAssessmentRisksPanel`).
