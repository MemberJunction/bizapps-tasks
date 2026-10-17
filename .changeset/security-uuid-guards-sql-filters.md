---
"@mj-biz-apps/tasks-core": patch
"@mj-biz-apps/tasks-entities": patch
"@mj-biz-apps/tasks-entities-server": patch
"@mj-biz-apps/tasks-ng": patch
"@mj-biz-apps/tasks-server": patch
---

Security hardening against SQL injection through ExtraFilter interpolation. IDs that are stored in NVARCHAR columns with no FK (`TaskAssignment.AssigneeRecordID`) or that arrive from callers before FK validation (`Task.TypeID`, `TaskDependency.TaskID`/`DependsOnTaskID`, `TaskTemplateService.instantiateTemplate`'s `templateID`) are now UUID-validated with `IsValidUUID` before being interpolated into RunView filters — invalid values are skipped and logged in notification paths, rejected as validation errors in `ValidateAsync`, and thrown in the template service. Angular components (`current-person.ts`, `my-tasks.component.ts`) now escape single quotes in interpolated filter values, matching the approval inbox's existing pattern.
