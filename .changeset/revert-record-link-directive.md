---
"@mj-biz-apps/tasks-ng": patch
---

Revert the `[mjRecordLink]` directive in the task detail panel, task overview and task header. The directive ships in MemberJunction 6.2; tasks tracks the 6.1 LTS line, where it does not exist, so `tasks-ng` failed to build and the release was blocked. The panels return to their previous record-link handling.
