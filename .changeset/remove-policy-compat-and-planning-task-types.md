---
"@mj-biz-apps/tasks-actions": patch
"@mj-biz-apps/tasks-entities": patch
"@mj-biz-apps/tasks-entities-server": patch
---

Remove temporary `ai-policy-compat` shims now that CI builds directly against MJ `next`, and remove `metadata/task-types-planning/` so Planning owns the `PRIORITY` task-type `ExtensionEntity` metadata directly.
