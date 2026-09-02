# @mj-biz-apps/tasks-entities-server

## 1.4.2

### Patch Changes

- Updated dependencies [a49f88a]
  - @mj-biz-apps/tasks-entities@1.4.2
  - @mj-biz-apps/tasks-core@1.4.2

## 1.4.1

### Patch Changes

- Updated dependencies [c2969c4]
  - @mj-biz-apps/tasks-entities@1.4.1
  - @mj-biz-apps/tasks-core@1.4.1

## 1.4.0

### Patch Changes

- Updated dependencies [0064e26]
- Updated dependencies [0592ecc]
  - @mj-biz-apps/tasks-entities@1.4.0
  - @mj-biz-apps/tasks-core@1.4.0

## 1.3.0

### Minor Changes

- 52e9d2d: feat(tasks): TaskType Code, dynamic TaskTypeStatus, and workflow action triggers

  - Adds unique `Code` and event-driven action triggers (`OnCreateActionID`, `OnStatusChangeActionID`) to `TaskType`.
  - Introduces `TaskTypeStatus` entity for customizable per-type task stages with `OnEnterActionID` and `OnExitActionID` lifecycle hooks.
  - Extends `TaskEntityServer` with automated `TaskTypeStatus` synchronization and universal payload action execution for downstream workflows and AI Flow Agents.

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
  - @mj-biz-apps/tasks-core@1.3.0

## 1.2.3

### Patch Changes

- Updated dependencies [256fea5]
  - @mj-biz-apps/tasks-entities@1.2.3
  - @mj-biz-apps/tasks-core@1.2.3

## 1.2.2

### Patch Changes

- 4a0fba5: Upgrade MemberJunction from 5.x to 6.1.0-edge.1.

  The whole workspace moves together because `BaseEntity` became generic in 6.x (`BaseEntity<unknown>`),
  so a package on 5.x consuming an entity class built against 6.x fails to compile. Leaving any one
  repo behind produced exactly that error.

- Updated dependencies [3f6aa3d]
- Updated dependencies [4a0fba5]
- Updated dependencies [835d116]
  - @mj-biz-apps/tasks-core@1.2.2
  - @mj-biz-apps/tasks-entities@1.2.2

## 1.2.1

### Patch Changes

- Updated dependencies [8487cf1]
  - @mj-biz-apps/tasks-entities@1.2.1
  - @mj-biz-apps/tasks-core@1.2.1

## 1.2.0

### Minor Changes

- d540e69: "PG Canonical Backfill"

### Patch Changes

- Updated dependencies [d540e69]
  - @mj-biz-apps/tasks-entities@1.2.0
  - @mj-biz-apps/tasks-core@1.2.0

## 1.1.2

### Patch Changes

- Updated dependencies [290772b]
  - @mj-biz-apps/tasks-core@1.1.2
  - @mj-biz-apps/tasks-entities@1.1.2

## 1.1.1

### Patch Changes

- fc7918b: Narrowed RunView types to remove any; converted manifest dependencies to object.
- Updated dependencies [fc7918b]
  - @mj-biz-apps/tasks-entities@1.1.1
  - @mj-biz-apps/tasks-core@1.1.1

## 1.1.0

### Patch Changes

- Updated dependencies [160cf67]
  - @mj-biz-apps/tasks-entities@1.1.0
  - @mj-biz-apps/tasks-core@1.1.0

## 1.0.1

### Patch Changes

- @mj-biz-apps/tasks-core@1.0.1
- @mj-biz-apps/tasks-entities@1.0.1
