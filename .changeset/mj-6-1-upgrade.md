---
"@mj-biz-apps/tasks-entities": minor
"@mj-biz-apps/tasks-core": minor
"@mj-biz-apps/tasks-entities-server": minor
"@mj-biz-apps/tasks-server": minor
"@mj-biz-apps/tasks-actions": minor
"@mj-biz-apps/tasks-ng": minor
---

Upgrade MemberJunction from 5.x to 6.1.0-edge.1.

The whole workspace moves together because `BaseEntity` became generic in 6.x (`BaseEntity<unknown>`),
so a package on 5.x consuming an entity class built against 6.x fails to compile. Leaving any one
repo behind produced exactly that error.
