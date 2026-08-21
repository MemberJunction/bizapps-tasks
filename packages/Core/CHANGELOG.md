# @mj-biz-apps/tasks-core

## 1.3.0

### Patch Changes

- 3431e79: Declare BUSL-1.1 in mj-app.json. The LICENSE file and every package
  already state BUSL-1.1; the app manifest still said ISC, so anything
  reading the manifest saw the wrong license.
- Updated dependencies [90418c2]
- Updated dependencies [178cced]
- Updated dependencies [f2a41f2]
- Updated dependencies [3431e79]
- Updated dependencies [52e9d2d]
  - @mj-biz-apps/tasks-entities@1.3.0

## 1.2.3

### Patch Changes

- Updated dependencies [256fea5]
  - @mj-biz-apps/tasks-entities@1.2.3

## 1.2.2

### Patch Changes

- 3f6aa3d: Make the task decision outcomes a runtime table, so consuming apps stop hand-copying them.

  `TaskDecisionOutcomeCode` was a bare union. Consumers need two runtime answers a type cannot give —
  "do I accept this code?" and "does it mean approved?" — so bizapps-accounting answered both by
  copying the literals into its own `Set`s. A `Set` holding a subset of a union is a legal value, so
  widening the union here produced no error there: `tsc` returned 0 while the accounting approval gate
  would have stopped counting a new approving outcome as approved, on the path that sends a journal
  entry batch to the ERP.

  Adds `TaskDecisionOutcomes` (the table), `TaskDecisionOutcomeCodes`, `IsTaskDecisionOutcomeCode`
  (a narrowing guard for unvalidated input) and `IsApprovalOutcome`. `TaskDecisionOutcomeCode` is now
  derived from the table, so it stays exactly what it was. `statusForOutcome` reads the table instead
  of a `switch` that silently returned `undefined` for any outcome added later.

  Additive — no existing caller changes. Adding an outcome now requires a seeded `TaskDecisionOutcome`
  row alongside it, since `resolveOutcome` looks the code up in the database.

- 4a0fba5: Upgrade MemberJunction from 5.x to 6.1.0-edge.1.

  The whole workspace moves together because `BaseEntity` became generic in 6.x (`BaseEntity<unknown>`),
  so a package on 5.x consuming an entity class built against 6.x fails to compile. Leaving any one
  repo behind produced exactly that error.

- Updated dependencies [4a0fba5]
- Updated dependencies [835d116]
  - @mj-biz-apps/tasks-entities@1.2.2

## 1.2.1

### Patch Changes

- Updated dependencies [8487cf1]
  - @mj-biz-apps/tasks-entities@1.2.1

## 1.2.0

### Minor Changes

- d540e69: "PG Canonical Backfill"

### Patch Changes

- Updated dependencies [d540e69]
  - @mj-biz-apps/tasks-entities@1.2.0

## 1.1.2

### Patch Changes

- 290772b: fix(tasks): lowercase PostgreSQL app schema name in migrations to match physical
  - @mj-biz-apps/tasks-entities@1.1.2

## 1.1.1

### Patch Changes

- fc7918b: Narrowed RunView types to remove any; converted manifest dependencies to object.
- Updated dependencies [fc7918b]
  - @mj-biz-apps/tasks-entities@1.1.1

## 1.1.0

### Minor Changes

- 160cf67: Approval/decision workflow primitives for tasks, plus MJ-token theming.

### Patch Changes

- Updated dependencies [160cf67]
  - @mj-biz-apps/tasks-entities@1.1.0

## 1.0.1

### Patch Changes

- @mj-biz-apps/tasks-entities@1.0.1
