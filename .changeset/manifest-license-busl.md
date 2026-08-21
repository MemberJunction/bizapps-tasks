---
"@mj-biz-apps/tasks-actions": patch
"@mj-biz-apps/tasks-core": patch
"@mj-biz-apps/tasks-entities": patch
"@mj-biz-apps/tasks-entities-server": patch
"@mj-biz-apps/tasks-ng": patch
"@mj-biz-apps/tasks-server": patch
---

Declare BUSL-1.1 in mj-app.json. The LICENSE file and every package
already state BUSL-1.1; the app manifest still said ISC, so anything
reading the manifest saw the wrong license.
