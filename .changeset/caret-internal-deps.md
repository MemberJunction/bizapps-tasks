---
'@mj-biz-apps/tasks-ng': patch
'@mj-biz-apps/tasks-core': patch
'@mj-biz-apps/tasks-entities-server': patch
'@mj-biz-apps/tasks-server': patch
---

The packages' dependencies on each other are caret ranges (`^1.7.1`) instead of exact versions. A host that pins or overrides one package of this app at a later compatible version no longer forces an exact-match copy of its siblings. Changesets keeps the caret and moves its floor on each release.
