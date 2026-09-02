---
'@mj-biz-apps/tasks-entities': patch
---

Release 1.4.1 to align the open-app set.

There is no functional change since 1.4.0. The only commit on `next` since the v1.4.0 tag is
the lockfile catch-up that the 1.4.0 publish itself back-merged (internal workspace
self-references 1.3.0 -> 1.4.0), so the shipped `dist` output is unchanged.

This version exists so every open app AIDP consumes moves together and the platform
manifest can state one coherent floor across the set, rather than pinning tasks a release
behind its siblings.
