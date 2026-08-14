# @mj-biz-apps/tasks-actions

## 1.2.3

## 1.2.2

### Patch Changes

- 4a0fba5: Upgrade MemberJunction from 5.x to 6.1.0-edge.1.

  The whole workspace moves together because `BaseEntity` became generic in 6.x (`BaseEntity<unknown>`),
  so a package on 5.x consuming an entity class built against 6.x fails to compile. Leaving any one
  repo behind produced exactly that error.

## 1.2.1

## 1.2.0

### Minor Changes

- d540e69: "PG Canonical Backfill"

## 1.1.2

## 1.1.1

### Patch Changes

- fc7918b: Narrowed RunView types to remove any; converted manifest dependencies to object.

## 1.1.0

## 1.0.1
