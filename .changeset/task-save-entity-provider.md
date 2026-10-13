---
"@mj-biz-apps/tasks-entities-server": patch
"@mj-biz-apps/tasks-core": patch
---

Task saves now do all their reads and writes on the provider the Task was created on, not the process-global one. Lifecycle action hooks and the parent-progress rollup run after the caller's transaction commits (MJ 6.1.3+) and are dropped if it rolls back, so another caller's transaction on the global provider can no longer make them fail silently.
