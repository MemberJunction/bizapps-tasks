---
"@mj-biz-apps/tasks-entities": patch
---

Unify every `@memberjunction/*` range at the estate-wide floor `^6.1.0-edge.2`,
replacing the `^6.1.0-edge.1` ranges this repo published in 1.2.2.

A `patch`: the convention reserves `minor` for migration and metadata changes, and this
carries neither — only dependency ranges move, and no application source changed.

**Why this matters beyond tidiness.** Two of the ranges are declared on
`@mj-biz-apps/tasks-ng` as *peer* dependencies — `@memberjunction/ng-gantt` and
`@memberjunction/ng-kanban` — so they are part of this package's published contract, not a
private implementation detail. While they say `^6.1.0-edge.1`, every downstream consumer
that installs `tasks-ng` resolves an edge.1 tree even when the consumer itself has moved to
edge.2. In `bizapps-issues` that materialised ~244 `@memberjunction` packages at
`6.1.0-edge.1` sitting alongside the edge.2 set, which is the duplicate-copy condition the
one-copy census exists to catch. Bumping the consumer cannot fix it; the range has to move
here and be republished.
