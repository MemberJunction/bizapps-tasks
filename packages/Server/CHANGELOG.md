# @mj-biz-apps/tasks-server

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
  - @mj-biz-apps/tasks-entities-server@1.2.2
  - @mj-biz-apps/tasks-actions@1.2.2

## 1.2.1

### Patch Changes

- Updated dependencies [8487cf1]
  - @mj-biz-apps/tasks-entities@1.2.1
  - @mj-biz-apps/tasks-core@1.2.1
  - @mj-biz-apps/tasks-entities-server@1.2.1
  - @mj-biz-apps/tasks-actions@1.2.1

## 1.2.0

### Minor Changes

- d540e69: "PG Canonical Backfill"

### Patch Changes

- Updated dependencies [d540e69]
  - @mj-biz-apps/tasks-entities-server@1.2.0
  - @mj-biz-apps/tasks-entities@1.2.0
  - @mj-biz-apps/tasks-actions@1.2.0
  - @mj-biz-apps/tasks-core@1.2.0

## 1.1.2

### Patch Changes

- Updated dependencies [290772b]
  - @mj-biz-apps/tasks-core@1.1.2
  - @mj-biz-apps/tasks-entities-server@1.1.2
  - @mj-biz-apps/tasks-actions@1.1.2
  - @mj-biz-apps/tasks-entities@1.1.2

## 1.1.1

### Patch Changes

- fc7918b: Narrowed RunView types to remove any; converted manifest dependencies to object.
- Updated dependencies [fc7918b]
  - @mj-biz-apps/tasks-entities-server@1.1.1
  - @mj-biz-apps/tasks-entities@1.1.1
  - @mj-biz-apps/tasks-actions@1.1.1
  - @mj-biz-apps/tasks-core@1.1.1

## 1.1.0

### Minor Changes

- 160cf67: Approval/decision workflow primitives for tasks, plus MJ-token theming.

### Patch Changes

- Updated dependencies [160cf67]
  - @mj-biz-apps/tasks-entities@1.1.0
  - @mj-biz-apps/tasks-core@1.1.0
  - @mj-biz-apps/tasks-entities-server@1.1.0
  - @mj-biz-apps/tasks-actions@1.1.0

## 1.0.1

### Patch Changes

- @mj-biz-apps/tasks-actions@1.0.1
- @mj-biz-apps/tasks-core@1.0.1
- @mj-biz-apps/tasks-entities@1.0.1
- @mj-biz-apps/tasks-entities-server@1.0.1
