# Tasks ExtensionEntity Support & Generic Measurable Task Fields

- **Epic**: `4BAD779C-3FF1-400E-815F-CDF7E541EF15`
- **Plan**: `3B50751E-B420-456B-B77B-6EC3387223A0`
- **Repository**: `MemberJunction/bizapps-tasks`

## 1. Generic Measurable Task Fields & Check-Ins

All 13 metric and check-in columns and relationships on `MJ_BizApps_Tasks: Tasks` and `MJ_BizApps_Tasks: Task Check Ins` remain intact without DDL changes:

- `BaselineValue`, `TargetValue`, `CurrentValue`, `UnitOfMeasure`, `MetricDirection`
- `PlanningPeriod`, `HealthStatus`, `ConfidenceScore`, `RollupWeight`
- `Task Check Ins` (`Tasks.CheckIns` collection and `TaskCheckIn.TaskID`)
- `CheckInCadence`, `LastCheckInAt`, `NextCheckInDueAt`

Field descriptions in `metadata/entities/.entities.json` (`AutoUpdateDescription: false`), JSDoc comments in `@mj-biz-apps/tasks-entities`, Zod schema descriptions, and GraphQL field descriptions document generic measurable task usage rather than OKR-only usage.

## 2. `PRIORITY` Task Type `ExtensionEntity` & Standalone Compatibility

- `metadata/task-types-planning/.planning-task-types.json` defines `PRIORITY` (`7E100001-0000-0000-0000-000000000001`) with `ExtensionEntity: "MJ_BizApps_Planning: Priority Tasks"` so `Priority Tasks` in `bizapps-planning` operates as a declared IS-A child of `MJ_BizApps_Tasks: Tasks` via `SubtypeSelector` (`TypeID.ExtensionEntity`).
- `metadata/task-types-planning/.mj-sync.json` uses `"pushWhen": "@env:MJ_BIZAPPS_PLANNING_INSTALLED"` so standalone `bizapps-tasks` environments (without `bizapps-planning`) skip pushing the Planning-only `PRIORITY` `ExtensionEntity` link and pass `BaseEntity` subtype validation cleanly.
- Legacy OKR task types (`PRIORITY_OBJECTIVE`, `KEY_RESULT`) in `metadata/task-types/.task-types.json` are marked `"IsActive": false`.

## 3. Generic Task Creation Type Filtering Helpers

`@mj-biz-apps/tasks-entities` exports strictly-typed predicates (and `@mj-biz-apps/tasks-core` re-exports their TypeScript types):

- `IsPlanningExtensionEntity` / `IsPlanningOwnedTaskType` / `IsLegacyOkrTaskType`
- `IsGenericCreatableTaskType` / `FilterGenericCreatableTaskTypes`
- `IsTaskTypeExtensionEntityAvailable` (safely verifies whether a Task Type's IS-A `ExtensionEntity` is registered in the current metadata provider)
