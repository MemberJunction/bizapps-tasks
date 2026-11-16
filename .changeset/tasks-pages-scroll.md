---
"@mj-biz-apps/tasks-ng": patch
---

The Tasks dashboard, My Tasks, Approvals and Templates pages now scroll. Each sized itself to the shell's content pane, which clips what overflows, and declared no scroll container, so rows past the first screen could not be reached. Each page now hides overflow on its host and scrolls the layout inside it, the same pattern as the Accounting and Orders dashboards (bc-aidp-next-golive#392).
