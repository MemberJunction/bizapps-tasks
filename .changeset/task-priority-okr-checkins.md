---
"@mj-biz-apps/tasks-ng": minor
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-server": minor
---

Add Priority/OKR tracking columns on `Task` (`HealthStatus`, `ConfidenceScore`, `BaselineValue`, `TargetValue`, `CurrentValue`, `UnitOfMeasure`, `MetricDirection`, `RollupWeight`, `PlanningPeriod`, `CheckInCadence`, `LastCheckInAt`, `NextCheckInDueAt`), the `TaskCheckIn` entity, and weighted health/confidence rollup in `TaskCheckInEntityServer` and `TaskService`.
