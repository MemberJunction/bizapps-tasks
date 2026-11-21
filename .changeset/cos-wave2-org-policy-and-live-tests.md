---
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-actions": minor
"@mj-biz-apps/tasks-ng": minor
---

Wave 2 Chief of Staff integration hardening for BizApps Tasks:

- Enforce `AgentUserPolicyEngine` and `TypedActionPolicyGuard` on all 3 Tasks Remotable Operations (`BizAppsTasks.BulkUpdateTasks`, `BizAppsTasks.InstantiateTemplate`, `BizAppsTasks.RunRecurringPlaybooks`) and `RunRecurringPlaybooksAction`, preserving zero-overhead pass-through for direct human UI calls while enforcing `ReadOnly`, `EntityAccessRules`, and `RequireApprovalForDestructiveActions` inside executing agent contexts.
- Add canonical `OrganizationID` and case-insensitive `OrganizationName` scoping (covering both external organizations and mirrored `LinkedCompanyID` internal companies) to `Find Tasks`, `Create Task`, and `Get My Tasks Briefing`, and rename `Complete Task` to `Mark Task Complete` (preserving UUID and `CompleteTaskAction` driver class) to prevent tool-name collision with MJ's reserved native control tool `complete_task`.
- Fix ref-counted re-entrancy in `composite-graph-scope.ts` (`WorkReportEntityServer.Save()` -> `ValidateAsync()`), set `RequestedAt` on supervisor review `AI Agent Requests` in `WorkReportService`, and add missing `UI` role permissions for `Task Check Ins` and `Task Links`.
- Enrich `TSK-00` Task World with persistent CoS sample data (Organizations, Monthly Financial Close playbook template, submitted 15Five Weekly Work Report, and completed meeting with WebVTT transcript) and add deterministic `TSK-09` (`task-cos-typed-skills`) and live-LLM `TSK-10` (`task-cos-live`) integration suites.
- Polish `ChiefOfStaffWorkReportsComponent` Calm-UX styling (remove decorative callout stripe and ensure 80px bottom scroll clearance).
