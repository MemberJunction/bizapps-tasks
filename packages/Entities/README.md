# @mj-biz-apps/tasks-entities

Strongly-typed entity models and validation classes for BizApps Tasks.

## Entities

- `TaskEntity` (`MJ_BizApps_Tasks: Tasks`) — Primary task entity with cycle detection and status transition validation.
- `TaskTypeEntity` (`MJ_BizApps_Tasks: Task Types`) — Work item classification with unique `Code` and lifecycle action hooks (`OnCreateActionID`, `OnStatusChangeActionID`).
- `TaskTypeStatusEntity` (`MJ_BizApps_Tasks: Task Type Status`) — Dynamic domain stages per task type with `MacroStatus`, `Sequence`, `IsDefault`, `IsTerminal`, and stage action hooks (`OnEnterActionID`, `OnExitActionID`).
- `TaskCategoryEntity` (`MJ_BizApps_Tasks: Task Categories`) — Hierarchical task categories.
- `TaskAssignmentEntity` (`MJ_BizApps_Tasks: Task Assignments`) — Polymorphic task assignment.
- `TaskDependencyEntity` (`MJ_BizApps_Tasks: Task Dependencies`) — Graph edges between tasks with cycle validation.
- `TaskDecisionEntity` (`MJ_BizApps_Tasks: Task Decisions`) — Approval and decision outcomes.
- `TaskTemplateEntity` (`MJ_BizApps_Tasks: Task Templates`) — Reusable task structures.
- `TaskActivityEntity` (`MJ_BizApps_Tasks: Task Activities`) — Automatic audit log.
