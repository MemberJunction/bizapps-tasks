---
"@mj-biz-apps/tasks-core": patch
"@mj-biz-apps/tasks-server": patch
---

Replace copied `@memberjunction/core` limits types and runtime reflection shims in `TasksLimits.ts` with direct imports of `LimitsConfigResolver`, `MJLimitsConfig`, and `MJLimitsOverride` from `@memberjunction/core@6.3.0-edge.2`, convert `TasksLimitsResolver` to extend `BaseSingleton<TasksLimitsResolver>`, bump `@memberjunction/*` pins to `6.3.0-edge.2`, and add a deterministic dual-dialect relational RLS integration test verifying Software Factory work items remain visible to the factory's `run-as` user under `Team` visibility RLS.
