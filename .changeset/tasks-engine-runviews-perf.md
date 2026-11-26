---
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-ng": minor
---

Add `TasksEngineBase` (`BaseEngine` + `BaseSingleton`) with impersonation-safe `ProviderToUse`, `CanRead`-gated taxonomy caching (`Task Types`, `Task Type Status`, `Task Categories`, `Task Roles`, `Task Tags`), incremental `People`/`Organizations` directory helpers, and `ConversationEngine`-style bounded `LoadProjectSubtree(rootTaskId)` caching; refactor Angular components and pages to read taxonomy/directory data from `TasksEngineBase` and batch dynamic queries via single `rv.RunViews([...])` requests.
