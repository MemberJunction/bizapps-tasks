---
"@mj-biz-apps/tasks-actions": patch
"@mj-biz-apps/tasks-core": patch
"@mj-biz-apps/tasks-entities": patch
"@mj-biz-apps/tasks-entities-server": patch
"@mj-biz-apps/tasks-ng": patch
"@mj-biz-apps/tasks-server": patch
---

MemberJunction and other BizApps packages are peer dependencies with caret ranges (nothing in `dependencies`), so a host keeps one copy of each. `@memberjunction/ng-hierarchy-tree` moved from `tasks-ng`'s `dependencies` to `peerDependencies`; every MemberJunction peer has an exact `devDependencies` anchor for local builds. Adds `check-dependency-model` to CI.
