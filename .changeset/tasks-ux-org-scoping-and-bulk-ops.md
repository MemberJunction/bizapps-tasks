---
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-server": minor
"@mj-biz-apps/tasks-ng-widgets": minor
"@mj-biz-apps/tasks-ng": minor
---

Golden Hybrid Tasks UX redesign with canonical Organization scoping (`OrganizationID` on aggregate roots `Task`, `TaskCategory`, `TaskTemplate` + server parent-org inheritance in `TaskEntityServer`), unified Assignee / Due Date / Organization filters and indicators across Tree List, Smart Board (including Group by Organization / Company), and Gantt Timeline (`Assignee` & `Organization` columns), and authoritative server-side Remotable Operations (`BizAppsTasks.BulkUpdateTasks` for Asana-grade multi-field bulk editing and `BizAppsTasks.InstantiateTemplate` for hierarchical playbook launch).
