---
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-server": minor
"@mj-biz-apps/tasks-ng": minor
---

feat(tasks): TaskType Code, dynamic TaskTypeStatus, and workflow action triggers

- Adds unique `Code` and event-driven action triggers (`OnCreateActionID`, `OnStatusChangeActionID`) to `TaskType`.
- Introduces `TaskTypeStatus` entity for customizable per-type task stages with `OnEnterActionID` and `OnExitActionID` lifecycle hooks.
- Extends `TaskEntityServer` with automated `TaskTypeStatus` synchronization and universal payload action execution for downstream workflows and AI Flow Agents.
