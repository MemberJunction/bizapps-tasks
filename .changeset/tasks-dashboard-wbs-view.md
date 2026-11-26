---
"@mj-biz-apps/tasks-ng-widgets": minor
"@mj-biz-apps/tasks-ng": minor
---

Wire `<mjt-wbs-tree>` (`TaskWbsTreeComponent`) and `<mjt-wbs-summary-strip>` into the standalone Tasks App (`TasksDashboardPageComponent` as the default `WBS` view mode alongside `List`, `Board`, and `Timeline`, and `MyTasksPageComponent` with a `List | WBS` view toggle), including `TasksEngineBase` + batched `RunViews` loading for tasks/assignees/dependencies, ancestor-preserving filtering across all active page filters, inline quick-add, status ring toggle, subtask creation, slide-over detail drawer wiring, and `<mjt-bulk-action-dock>` multi-select support.
