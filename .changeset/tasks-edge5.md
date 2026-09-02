---
'@mj-biz-apps/tasks-entities': patch
---

Move to MJ `6.1.0-edge.5` and drop the exact `ng-hierarchy-tree` pin.

37 `@memberjunction/*` dependencies move to `^6.1.0-edge.5`, one of which was pinned **exactly** at
`6.1.0-edge.3` — `ng-hierarchy-tree`, the same pin bizapps-orders removed because it *"forced two MJ
copies into consumers' Explorer trees and split the ClassFactory registry"*. Caret, never exact.

`@mj-biz-apps/common-entities` also moves to `>=5.37.0`, matching what is published.

This matters to consumers: `tasks-*@1.4.1` publishes with `@memberjunction/*` at `^6.1.0-edge.3`, so
anything installing bizapps-tasks beside an edge.5 app resolves two MJ trees.

Verified after a clean install: a single `@memberjunction/core` at edge.5, zero packages at edge.2/3/4.
