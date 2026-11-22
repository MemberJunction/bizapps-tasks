---
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-actions": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-server": minor
---

Centralize all BizApps Tasks backend runaway guards, resource guards, briefing bounds, and tuning constants behind the strongly-typed `TasksLimitsResolver` and `BriefingLimitsHelper` in `@mj-biz-apps/tasks-core`, route all Core/Actions/EntitiesServer/Server limit sites through it, add the deterministic classified limits sweep (`scripts/sweep-limits.mjs`) and static standards/limits guard (`scripts/check-standards.mjs`, `npm run check:standards`) enforced in CI, and add comprehensive Vitest unit tests covering limits override propagation and standards validation.
