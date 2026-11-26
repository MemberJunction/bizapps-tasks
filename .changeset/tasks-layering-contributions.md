---
"@mj-biz-apps/tasks-ng": minor
---

Enforce clean upstream/downstream layering in BizApps Tasks and introduce a generic Task Detail Inspector contribution seam:

- Remove the hardcoded **OKRs & Help** button, `'help'` drawer mode, `GoalsViewComponent`, and all hardcoded BizApps Planning UI references from `TasksDashboardPageComponent` and `TaskEditPanelComponent`.
- Add `BaseTaskDetailContribution`, `DiscoverTaskDetailContributions`, `TASK_DETAIL_CONTRIBUTION_SURFACE`, and `<bizapps-task-detail-contributions>` inside `TaskDetailPanelComponent` so downstream Open Apps can register contextual cards via `MJGlobal.Instance.ClassFactory` (extending either `BaseFormPanel` or `BaseTaskDetailContribution`) that mount dynamically when a Task is tied to their entities.
