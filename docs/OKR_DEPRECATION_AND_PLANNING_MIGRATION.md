# OKR Task Types 1.x Deprecation & Migration to BizApps Planning

## Summary

In BizApps Tasks `1.x`, strategic Objectives and Key Results (OKRs) are superseded by **BizApps Planning** (`MemberJunction/bizapps-planning`), which ships dedicated `Plan`, `PlanningPeriod`, `PriorityTask`, `CriticalNumber`, `CriticalNumberTarget`, and `PriorityKeyResult` entities and dashboards.

Following MemberJunction's **deprecate-then-remove** compatibility policy for `1.x` releases:

1. **Legacy OKR Task Types Deactivated (`IsActive = false`)**:
   - `PRIORITY_OBJECTIVE` (`8D42A1B9-3E71-4C5A-9F20-1B6E8D3A9C01`) and `KEY_RESULT` (`8D42A1B9-3E71-4C5A-9F20-1B6E8D3A9C02`) are marked `IsActive = false` in `metadata/task-types/.task-types.json` and in additive dual-dialect SQL migrations:
     - SQL Server: `migrations/V202611221800__v1.16.x__Deactivate_Legacy_OKR_TaskTypes.sql`
     - PostgreSQL: `migrations-pg/V202611221800__v1.16.x__Deactivate_Legacy_OKR_TaskTypes.pg.sql`
2. **Existing OKR Schema Columns Preserved in 1.x**:
   - No columns are dropped from `__mj_BizAppsTasks.Task` (`BaselineValue`, `TargetValue`, `CurrentValue`, `UnitOfMeasure`, `MetricDirection`, `PlanningPeriod`, `CheckInCadence`, `HealthStatus`, `ConfidenceScore`, `LastCheckInAt`, `NextCheckInDueAt`) or `TaskCheckIn` in `1.x`.
   - Existing `PRIORITY_OBJECTIVE` and `KEY_RESULT` task records remain safely readable across task views, detail panels, and forms until migrated.
   - Generic measurable tasks (`General`, `Deliverable`, `Action Item`, etc.) continue to support optional metric tracking via the `"Track measurable metric target & check-in cadence"` toggle.
3. **Active Selectors & Creation Paths Exclude Inactive/Legacy OKR Types**:
   - `IsActiveSelectableTaskType` / `FilterActiveSelectableTaskTypes` and `IsGenericCreatableTaskType` / `FilterGenericCreatableTaskTypes` (`@mj-biz-apps/tasks-entities`) exclude inactive and legacy OKR types from task creation menus, quick-add, quick-capture, bulk task-type updates, dashboard type filter dropdowns, and `CreateTaskAction` / `TasksBulkUpdateServerOperation`.
4. **UI, In-App Help & Chief of Staff Steering**:
   - The Angular Goals & OKR Migration view (`<bizapps-goals-view>`, also accessible via the **OKRs & Help** drawer on the **All Work** dashboard) displays a clear empty state and in-app help steering users to **BizApps Planning** and the **`Import Tasks OKRs`** action while safely listing any remaining legacy OKR tasks as read-only.
   - The **Chief of Staff Tasks & To-dos** skill (`metadata/chief-of-staff-skills/templates/chief-of-staff-tasks.skill.md`) explicitly routes OKR, Objective, and Key Result requests to **BizApps Planning** and documents **`Import Tasks OKRs`** for migration.

---

## Migrating Legacy OKR Tasks (`Import Tasks OKRs`)

When **BizApps Planning** is installed in the same environment, run the **`Import Tasks OKRs`** action to migrate historical `PRIORITY_OBJECTIVE` and `KEY_RESULT` tasks from BizApps Tasks into BizApps Planning:

1. **Preview First (`DryRun: true`)**:
   - Verify an active `Plan` and `PlanningPeriod` exist in BizApps Planning.
   - Invoke **`Import Tasks OKRs`** with `DryRun: true` to inspect the legacy `PRIORITY_OBJECTIVE` and `KEY_RESULT` tasks that will be converted into `PriorityTask`, `CriticalNumber`, `CriticalNumberTarget`, and `PriorityKeyResult` records.
2. **Confirm and Execute (`DryRun: false`)**:
   - Re-run **`Import Tasks OKRs`** with `DryRun: false` after confirming the preview counts. The import is idempotent and preserves traceability back to the source records.
