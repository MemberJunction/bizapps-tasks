---
"@mj-biz-apps/tasks-entities": minor
---

Upgrade to MemberJunction 6.1.0-edge.1.

Every `@memberjunction/*` dependency, devDependency, and peer range moves from
5.44.0 to the exact `6.1.0-edge.1` prerelease, and the Open App manifest's
`mjVersionRange` becomes `>=6.1.0-edge.1 <7.0.0`. **Hosts must be on a
MemberJunction 6.x environment** — this is why the bump is minor rather than
patch, even though no application source changed.

`@mj-biz-apps/common-*` moves to 5.33.1, the first bizapps-common build that
peers on the MJ 6.x line; anything older would pull a second MJ major into the
tree.

No source changes were required. Nothing between 5.44.0 and 5.51.0 was breaking,
and 6.x's sole documented breaking change — removing the 36 vendor connectors
from `@memberjunction/integration-connectors` — touches a package this app does
not depend on.
